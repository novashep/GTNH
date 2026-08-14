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

  -- 4. The DRONE is the load gate: wait only for it to arrive in the interface
  --    buffer. Tips/rods are handled by the patient fill in step 6 instead of
  --    being required up front. Under heavy ME contention (many modules loading
  --    at once) tips/rods trickle in slowly, and blocking on the full amount here
  --    was the cause of the recurring "items did not arrive" errors.
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

  local droneArrived, polls = pollUntil(function()
    return bufferHas(droneName, 1)
  end, ARRIVE_TIMEOUT)
  stats.arrivePolls = polls
  if not droneArrived then
    clearInterfaceSlots(mod)
    return false, "drone did not arrive: " .. droneName
  end

  -- 5. Move items by IDENTITY, not slot position (the ME interface re-stocks and
  --    can shuffle which buffer slot holds what between our check and transfer).
  local busSize = mod.transposer.getInventorySize(mod.conf.interfaceSide) or 9
  local function findSlot(label, minSize)
    for s = 1, busSize do
      local stack = mod.transposer.getStackInSlot(mod.conf.interfaceSide, s)
      if stack and stack.label == label and (stack.size or 0) >= minSize then
        return s
      end
    end
    return nil
  end

  -- Move the drone (exactly 1) into bus slot 1.
  local droneSrc = findSlot(droneName, 1)
  if not droneSrc then
    clearInterfaceSlots(mod); return false, "drone not found in interface buffer (" .. droneName .. ")"
  end
  local movedDrone = mod.transposer.transferItem(
    mod.conf.interfaceSide, mod.conf.inputBusSide, 1, droneSrc, 1)
  if (movedDrone or 0) < 1 then
    clearInterfaceSlots(mod); return false, "drone transfer failed"
  end

  -- 6. Fill tips (bus slot 2) and rods (bus slot 3) from the interface buffer,
  --    which the ME keeps restocked by fingerprint. Patient by design: it
  --    re-requests and retries so a slow/contended ME still completes instead of
  --    erroring. The drone (slot 1) isn't consumed and stays put.
  local function busCount(busSlot, label)
    local st = mod.transposer.getStackInSlot(mod.conf.inputBusSide, busSlot)
    if st and st.label == label then return st.size or 0 end
    return 0
  end

  local function fill(label, target, busSlot, dbSlot)
    for _ = 1, 10 do
      local have = busCount(busSlot, label)
      local deficit = target - have
      if deficit <= 0 then return true end
      mod.iface.setInterfaceConfiguration(busSlot, dbAddr, dbSlot, target)
      sched.await(function() return findSlot(label, 1) ~= nil end, 3, 0.2)
      local src = findSlot(label, 1)
      if src then
        mod.transposer.transferItem(
          mod.conf.interfaceSide, mod.conf.inputBusSide, deficit, src, busSlot)
      end
      sched.sleep(0.2)
    end
    return busCount(busSlot, label) >= target
  end

  -- Verify the drone landed correctly before committing tips/rods.
  local droneStack = mod.transposer.getStackInSlot(mod.conf.inputBusSide, 1)
  if not droneStack or droneStack.label ~= droneName then
    clearInterfaceSlots(mod)
    return false, "drone mismatch in bus: expected " .. droneName ..
        ", got " .. (droneStack and droneStack.label or "empty")
  end
  if not fill(drillEntry.tip, TIPS_PER, 2, slotTip) then
    clearInterfaceSlots(mod); return false, "tip shortfall: got " .. busCount(2, drillEntry.tip)
  end
  if not fill(drillEntry.rod, RODS_PER, 3, slotRod) then
    clearInterfaceSlots(mod); return false, "rod shortfall: got " .. busCount(3, drillEntry.rod)
  end

  clearInterfaceSlots(mod)
  return true, stats
end

loader.dbSlotsFor = dbSlotsFor -- exported for the broker's UI/return logic

return loader
