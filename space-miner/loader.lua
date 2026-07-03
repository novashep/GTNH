-- =============================================================================
-- MEDINA LOADER  (v2.0 — GTNH 2.9 compatible)
-- Loads one mining module's consumables (drone + drill tip + drill rod) from the
-- ME network into its input bus. Designed to run as a scheduler TASK, so six of
-- these can be in flight at once without freezing the broker.
--
-- HARDWARE MODEL (this is why the code looks the way it does):
--   - Each module has its OWN ME interface adapter, transposer, and input bus.
--     Those steps are fully parallel-safe across modules.
--   - ONE shared database component holds item fingerprints, partitioned by slot:
--     M1 -> 1/2/3, M2 -> 4/5/6, ...  Slots never overlap between modules.
--
-- GTNH 2.9 FIX:
--   iface.store() is broken in 2.9 — it returns true but writes nothing.
--   We now use db.set(slot, registryName, damage) which writes fingerprints
--   directly and synchronously. Registry names come from config.droneRegistry
--   and config.drillRegistry (populated via scan_items.lua).
-- =============================================================================

local component       = require("component")
local sched           = dofile("/home/scheduler.lua")

local loader          = {}

-- Tunables (all in real seconds, all honest — no tick/second mixing).
local ARRIVE_TIMEOUT  = 15  -- max wait for items to arrive in interface buffer
local POLL_INTERVAL   = 0.2 -- how often to re-check while awaiting

-- Map a module index to its three dedicated database slots.
local function dbSlotsFor(modIndex)
  local base = (modIndex - 1) * 3
  return base + 1, base + 2, base + 3
end

-- Poll a predicate every POLL_INTERVAL until true or timeout. Returns
-- (ok, iterations). `iterations` is how many checks it took — our diagnostic.
-- Each iteration is ~POLL_INTERVAL apart, so iterations * POLL_INTERVAL is the
-- approximate wait time. Low counts => store()/ME are fast on this setup.
local function pollUntil(predicate, timeout)
  local iterations = 0
  local met = sched.await(function()
    iterations = iterations + 1
    return predicate()
  end, timeout, POLL_INTERVAL)
  return met, iterations
end

-- Write a fingerprint into a db slot using the GTNH 2.9 db.set() API.
-- Returns true if the fingerprint was written and verified, false + error otherwise.
local function writeFingerprint(db, slot, regName, regDamage)
  local ok = db.set(slot, regName, regDamage)
  if not ok then
    return false, "db.set returned false for slot " .. slot .. " (" .. regName .. ":" .. regDamage .. ")"
  end
  -- Verify it landed (synchronous, but check anyway for safety)
  local stack = db.get(slot)
  if not stack then
    return false, "db.get returned nil after db.set for slot " .. slot
  end
  return true
end

-- Clear the input bus back into the ME interface buffer (recover stale items).
local function clearInputBus(mod)
  local busSize = mod.transposer.getInventorySize(mod.conf.inputBusSide) or 16
  for slot = 1, busSize do
    local size = mod.transposer.getSlotStackSize(mod.conf.inputBusSide, slot) or 0
    if size > 0 then
      mod.transposer.transferItem(mod.conf.inputBusSide, mod.conf.interfaceSide, size, slot)
    end
  end
end

local function clearInterfaceSlots(mod)
  mod.iface.setInterfaceConfiguration(1)
  mod.iface.setInterfaceConfiguration(2)
  mod.iface.setInterfaceConfiguration(3)
end

-- ---------------------------------------------------------------------------
-- THE LOAD SEQUENCE  (runs inside a task; yields freely)
--
-- Arguments:
--   mod    : the module table (index, conf, iface, transposer, adapter, ...)
--   job    : { droneKey, drillKey, parallels, ... }
--   deps   : { config = <config.lua>, logger = <logger>, db = <database proxy>,
--              dbAddr = <database address string> }
--
-- Returns (ok, errOrStats):
--   ok=true  -> stats table { confirmPolls = {drone,tip,rod}, arrivePolls = N }
--   ok=false -> error string
-- ---------------------------------------------------------------------------
function loader.run(mod, job, deps)
  local config     = deps.config
  local logger     = deps.logger
  local db         = deps.db
  local dbAddr     = deps.dbAddr

  local TIPS_PER   = config.tipsPerLoad or 64
  local RODS_PER   = config.rodsPerLoad or 64

  local droneName  = config.drones[job.droneKey]
  local drillEntry = config.drills[job.drillKey]
  local droneReg   = config.droneRegistry[job.droneKey]
  local drillReg   = config.drillRegistry[job.drillKey]

  if not droneName then return false, "bad droneKey: " .. tostring(job.droneKey) end
  if not drillEntry then return false, "bad drillKey: " .. tostring(job.drillKey) end
  if not droneReg then return false, "no droneRegistry for: " .. tostring(job.droneKey) end
  if not drillReg then return false, "no drillRegistry for: " .. tostring(job.drillKey) end

  local slotDrone, slotTip, slotRod = dbSlotsFor(mod.index)
  local stats = { confirmPolls = {}, arrivePolls = 0 }

  -- 1. Start clean: empty the input bus and wipe our db slots so we can't
  --    accidentally read a previous job's fingerprint.
  clearInputBus(mod)
  db.clear(slotDrone)
  db.clear(slotTip)
  db.clear(slotRod)

  -- Wait for the interface buffer slots we're about to use to actually drain
  -- back into the ME network. If a leftover item (e.g. a drill tip from the
  -- previous job, just pushed in by clearInputBus) is still sitting in slot 1,
  -- the fresh drone could end up in the wrong slot and a tip gets transferred
  -- as the "drone". Confirm slots 1-3 are empty before stocking fresh items.
  local drained = pollUntil(function()
    for s = 1, 3 do
      if (mod.transposer.getSlotStackSize(mod.conf.interfaceSide, s) or 0) > 0 then
        return false
      end
    end
    return true
  end, ARRIVE_TIMEOUT)
  if not drained then
    return false, "interface buffer did not drain before load (stale items stuck)"
  end

  -- 2. Write fingerprints using db.set (GTNH 2.9 fix — store() is broken).
  local items = {
    { slot = slotDrone, regName = droneReg.name, regDmg = droneReg.damage, tag = "drone" },
    { slot = slotTip,   regName = drillReg.tip.name, regDmg = drillReg.tip.damage, tag = "tip" },
    { slot = slotRod,   regName = drillReg.rod.name, regDmg = drillReg.rod.damage, tag = "rod" },
  }

  for _, it in ipairs(items) do
    local ok, err = writeFingerprint(db, it.slot, it.regName, it.regDmg)
    if not ok then
      return false, "fingerprint write failed for " .. it.tag .. ": " .. err
    end
  end

  -- 3. Tell the interface to stock items matching those fingerprints.
  mod.iface.setInterfaceConfiguration(1, dbAddr, slotDrone, 1)
  mod.iface.setInterfaceConfiguration(2, dbAddr, slotTip, TIPS_PER)
  mod.iface.setInterfaceConfiguration(3, dbAddr, slotRod, RODS_PER)

  -- 4. Wait for all three items to arrive in the interface buffer, identified by
  --    LABEL anywhere in the buffer (not pinned to a slot position). The
  --    interface may place items in slots other than 1/2/3, so we search by
  --    identity. The actual slot is resolved again at transfer time.
  local ibufSize = mod.transposer.getInventorySize(mod.conf.interfaceSide) or 9
  local function bufferHas(label, minSize)
    for s = 1, ibufSize do
      local stack = mod.transposer.getStackInSlot(mod.conf.interfaceSide, s)
      if stack and stack.label == label and (stack.size or 0) >= minSize then
        return true
      end
    end
    return false
  end

  local arrived, polls = pollUntil(function()
    return bufferHas(droneName, 1)
        and bufferHas(drillEntry.tip, TIPS_PER)
        and bufferHas(drillEntry.rod, RODS_PER)
  end, ARRIVE_TIMEOUT)
  stats.arrivePolls = polls

  if not arrived then
    clearInterfaceSlots(mod)
    return false, "items did not arrive: drone=" .. tostring(bufferHas(droneName, 1)) ..
        " tip=" .. tostring(bufferHas(drillEntry.tip, TIPS_PER)) ..
        " rod=" .. tostring(bufferHas(drillEntry.rod, RODS_PER))
  end

  -- 5. Move items into the input bus by IDENTITY, not by slot position.
  --    Root cause of the recurring "tip in the drone slot" error: we trusted
  --    that interface slot 1 held the drone and blindly transferred slot 1 -> bus
  --    slot 1. But the ME interface actively re-stocks its slots, and can shuffle
  --    what's in which buffer slot between our check and the transfer. So instead
  --    of trusting positions, we SCAN the buffer for the slot that actually holds
  --    each item and move that one. This is correct regardless of how the
  --    interface reorders slots or whether clearing drains them.
  local busSize = mod.transposer.getInventorySize(mod.conf.interfaceSide) or 9

  -- Find the buffer slot whose item matches `label` with at least `minSize`.
  local function findSlot(label, minSize)
    for s = 1, busSize do
      local stack = mod.transposer.getStackInSlot(mod.conf.interfaceSide, s)
      if stack and stack.label == label and (stack.size or 0) >= minSize then
        return s
      end
    end
    return nil
  end

  -- Move one matched item from the interface buffer to a specific bus slot.
  local function moveByIdentity(label, count, busSlot, tag)
    local src = findSlot(label, count)
    if not src then
      return false, tag .. " not found in interface buffer (" .. label .. ")"
    end
    local moved = mod.transposer.transferItem(
      mod.conf.interfaceSide, mod.conf.inputBusSide, count, src, busSlot)
    if (moved or 0) < count then
      return false, tag .. " transfer short: moved " .. tostring(moved) .. "/" .. count
    end
    return true
  end

  local okMove, moveErr
  okMove, moveErr = moveByIdentity(droneName, 1, 1, "drone"); if not okMove then
    clearInterfaceSlots(mod); return false, moveErr
  end
  okMove, moveErr = moveByIdentity(drillEntry.tip, TIPS_PER, 2, "tip"); if not okMove then
    clearInterfaceSlots(mod); return false, moveErr
  end
  okMove, moveErr = moveByIdentity(drillEntry.rod, RODS_PER, 3, "rod"); if not okMove then
    clearInterfaceSlots(mod); return false, moveErr
  end

  clearInterfaceSlots(mod)
  sched.sleep(0.2)

  -- 6. Verify the right drone landed in the bus (catches any cross-up).
  local droneStack = mod.transposer.getStackInSlot(mod.conf.inputBusSide, 1)
  local tipStack   = mod.transposer.getStackInSlot(mod.conf.inputBusSide, 2)
  local rodStack   = mod.transposer.getStackInSlot(mod.conf.inputBusSide, 3)

  if not droneStack or droneStack.label ~= droneName then
    return false, "drone mismatch in bus: expected " .. droneName ..
        ", got " .. (droneStack and droneStack.label or "empty")
  end
  if not tipStack or (tipStack.size or 0) < TIPS_PER then
    return false, "tip shortfall: got " .. (tipStack and tipStack.size or 0)
  end
  if not rodStack or (rodStack.size or 0) < RODS_PER then
    return false, "rod shortfall: got " .. (rodStack and rodStack.size or 0)
  end

  return true, stats
end

loader.dbSlotsFor = dbSlotsFor -- exported for the broker's UI/return logic

return loader
