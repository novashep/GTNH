local component = require('component')
local config = require('config')
local sides = require('sides')

-- The side of the transposer the interface and the inputbus on the mining module is.
local interfaceSide = sides.west
local inputBusSide = sides.east

-- How many parallels the miner has
local parallelCount = 4

local interfaceMain = component.me_interface
local trapos = component.transposer
local spaceMiner = component.gt_machine
local database = component.database


local function checkConditions(interface)
  for i, condition in ipairs(config.conditions) do
    local itemStacks = interface.getItemsInNetwork({label=condition.itemName})
    local num = 0
    if (itemStacks ~= nil) and (itemStacks[1] ~= nil) and (itemStacks[1].size ~= nil) then
      num = itemStacks[1].size
    end
    if num < condition.amountToMaintain then
      print(num)
      return condition.ID
    end
  end
  return -1
end

local function sendMission(interface, trapos, spaceMiner, database, ID)
  asteriodParams = config.asteriods[ID+1]
  for a, b in pairs(asteriodParams) do print(a, b) end
  interface.setInterfaceConfiguration(1, database.address, asteriodParams.droneAddress, 1)
  interface.setInterfaceConfiguration(2, database.address, asteriodParams.drillRodAddress, parallelCount * 4)
  interface.setInterfaceConfiguration(3, database.address, asteriodParams.drillRodAddress+1, parallelCount * 4)
  local canContinue = false
  while not canContinue do
    canContinue = true
    if trapos.getSlotStackSize(interfaceSide, 1) ~= 1 then
      canContinue = false
    end
    if trapos.getSlotStackSize(interfaceSide, 2) ~= 16 then
      canContinue = false
    end
    if trapos.getSlotStackSize(interfaceSide, 3) ~= 16 then
      canContinue = false
    end
    os.sleep(2)
  end
  spaceMiner.setParameters(0,0,asteriodParams.distance)
  trapos.transferItem(interfaceSide,inputBusSide,1,1,1)
  trapos.transferItem(interfaceSide,inputBusSide,parallelCount * 4,2,2)
  trapos.transferItem(interfaceSide,inputBusSide,parallelCount * 4,3,3)
  -- if using a smaller database, the 81 may need to be lowered to the last address in the database
  interface.setInterfaceConfiguration(1, database.address, 81, 0)
  interface.setInterfaceConfiguration(2, database.address, 81, 0)
  interface.setInterfaceConfiguration(3, database.address, 81, 0)
  os.sleep(4)
  while spaceMiner.isMachineActive() do os.sleep(1) end
  trapos.transferItem(inputBusSide,interfaceSide,64)
end
while true do
  local toSend = checkConditions(interfaceMain)
  if toSend ~= -1 then
    sendMission(interfaceMain, trapos, spaceMiner, database, toSend)
  else
    os.sleep(1)
  end
end