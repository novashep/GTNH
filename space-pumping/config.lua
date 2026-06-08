-- config.lua
-- Comprehensive Space Elevator Fleet Management Configuration Matrix
-- Compiled directly from GTNH Master Mining Calculators, Asteroid Registry, and Optimization Sheets.
-- Ready for deployment, modular job runner integration, and version control check-in.

local config = {}

--------------------------------------------------------------------------------
-- 1. HARDWARE KEY REGISTRY
--------------------------------------------------------------------------------
config.drones = {
  lv  = "LV Mining Drone",  mv  = "MV Mining Drone",  hv  = "HV Mining Drone",
  ev  = "EV Mining Drone",  iv  = "IV Mining Drone",  luv = "LuV Mining Drone",
  zpm = "ZPM Mining Drone", uv  = "UV Mining Drone",  uhv = "UHV Mining Drone",
  uev = "UEV Mining Drone", uiv = "UIV Mining Drone", umv = "UMV Mining Drone",
  uxv = "UXV Mining Drone"
}

config.drills = {
  steel         = "Steel Drill Head",
  titanium      = "Titanium Drill Head",
  tungstensteel = "Tungstensteel Drill Head",
  naquadah      = "Naquadah Drill Head",
  orichalcum    = "Orichalcum Drill Head",
  neutronium    = "Neutronium Drill Head"
}

--------------------------------------------------------------------------------
-- 2. EXHAUSTIVE ORE-TO-ASTEROID TARGETING DICTIONARY
-- Maps 100% of material names, variants, and byproducts back to their optimized origin lanes.
--------------------------------------------------------------------------------
config.dustTargets = {
  -- === SUPER-COMPLEX & ALLOY CELESTIALS ===
  ["Mysterious Crystal Dust"]  = { asteroid = "Mysterious Crystal",  priority = 1  },
  ["Cosmic Neutronium Dust"]   = { asteroid = "Cosmic",              priority = 1  },
  ["Draconium Dust"]           = { asteroid = "Draconic",            priority = 1  },
  ["Awakened Draconium Dust"]  = { asteroid = "Draconic",            priority = 2  },
  ["Fluxed Electrum Dust"]     = { asteroid = "Cosmic",              priority = 2  },
  ["Neutronium Dust"]          = { asteroid = "Cosmic",              priority = 3  },
  ["Bedrockium Dust"]          = { asteroid = "Cosmic",              priority = 4  },
  ["Black Plutonium Dust"]     = { asteroid = "Cosmic",              priority = 5  },
  ["Infinity Catalyst Dust"]   = { asteroid = "Infinity Catalyst",   priority = 1  },
  ["Staballoy Dust"]           = { asteroid = "Everglades",          priority = 11 },
  ["Kleinite Dust"]            = { asteroid = "Draconic",            priority = 3  },

  -- === THE ACTINIDE & LANTHANIDE ELEMENT GROUPS ===
  ["Trinium Dust"]             = { asteroid = "Lanthanum",           priority = 1  },
  ["Lanthanum Dust"]           = { asteroid = "Lanthanum",           priority = 2  },
  ["Cerium Dust"]              = { asteroid = "Aluminium-LanthLine", priority = 3  },
  ["Praseodymium Dust"]        = { asteroid = "Lanthanum",           priority = 3  },
  ["Neodymium Dust"]           = { asteroid = "Aluminium-LanthLine", priority = 4  },
  ["Promethium Dust"]          = { asteroid = "Lanthanum",           priority = 4  },
  ["Samarium Dust"]            = { asteroid = "Holmium/Samarium",    priority = 1  },
  ["Europium Dust"]            = { asteroid = "Europium",            priority = 3  },
  ["Gadolinium Dust"]          = { asteroid = "Everglades",          priority = 5  },
  ["Terbium Dust"]             = { asteroid = "Everglades",          priority = 6  },
  ["Dysprosium Dust"]          = { asteroid = "Holmium/Samarium",    priority = 3  },
  ["Holmium Dust"]             = { asteroid = "Holmium/Samarium",    priority = 2  },
  ["Erbium Dust"]              = { asteroid = "Holmium/Samarium",    priority = 4  },
  ["Thulium Dust"]             = { asteroid = "Holmium/Samarium",    priority = 5  },
  ["Ytterbium Dust"]           = { asteroid = "Holmium/Samarium",    priority = 6  },
  ["Lutetium Dust"]            = { asteroid = "Lutetium",            priority = 1  },

  -- === INTERMEDIATE BULK PROCESSING ORES ===
  ["Rare Earth I Dust"]        = { asteroid = "Aluminium-LanthLine", priority = 2  },
  ["Rare Earth II Dust"]       = { asteroid = "Holmium/Samarium",    priority = 2  },
  ["Rare Earth III Dust"]      = { asteroid = "Everglades",          priority = 3  },
  ["Rare Earth I Ore"]         = { asteroid = "Aluminium-LanthLine", priority = 2  },
  ["Rare Earth II Ore"]        = { asteroid = "Holmium/Samarium",    priority = 2  },
  ["Rare Earth III Ore"]       = { asteroid = "Everglades",          priority = 3  },

  -- === BASE, HEAVY & PRECIOUS METALS ===
  ["Adamantium Dust"]          = { asteroid = "Adamantium",          priority = 1  },
  ["Bismuth Dust"]             = { asteroid = "Adamantium",          priority = 2  },
  ["Antimony Dust"]            = { asteroid = "Adamantium",          priority = 3  },
  ["Gallium Dust"]             = { asteroid = "Adamantium",          priority = 4  },
  ["Lithium Dust"]             = { asteroid = "Adamantium",          priority = 5  },
  ["Aluminium Dust"]           = { asteroid = "Aluminium",           priority = 1  },
  ["Bauxite Dust"]             = { asteroid = "Aluminium",           priority = 2  },
  ["Rutile Dust"]              = { asteroid = "Aluminium",           priority = 3  },
  ["Crushed Monazite Ore"]     = { asteroid = "Aluminium-LanthLine", priority = 1  },
  ["Crushed Bastnasite Ore"]   = { asteroid = "Aluminium-LanthLine", priority = 2  },
  ["Cobalt Dust"]              = { asteroid = "Ardite/Cobalt",       priority = 1  },
  ["Ardite Dust"]              = { asteroid = "Ardite/Cobalt",       priority = 2  },
  ["Manyullyn Dust"]           = { asteroid = "Ardite/Cobalt",       priority = 3  },
  ["Chrome Dust"]              = { asteroid = "Chrome",              priority = 1  },
  ["Ruby Dust"]                = { asteroid = "Chrome",              priority = 2  },
  ["Copper Dust"]              = { asteroid = "Copper",              priority = 1  },
  ["Nickel Dust"]              = { asteroid = "Nickel",              priority = 1  },
  ["Iron Dust"]                = { asteroid = "Iron",                priority = 1  },
  ["Lead Dust"]                = { asteroid = "Lead",                priority = 1  },
  ["Tin Dust"]                 = { asteroid = "Tin",                 priority = 1  },
  ["Zinc Dust"]                = { asteroid = "Copper",              priority = 2  },
  ["Invar Dust"]               = { asteroid = "Nickel",              priority = 2  },
  ["Platinum Ore"]             = { asteroid = "PlatLine Ore",        priority = 1  },
  ["Palladium Dust"]           = { asteroid = "PlatLine Ore",        priority = 2  },
  ["Osmium Dust"]              = { asteroid = "PlatLine Ore",        priority = 3  },
  ["Iridium Dust"]             = { asteroid = "PlatLine Ore",        priority = 4  },
  ["Galena Dust"]              = { asteroid = "Lead",                priority = 4  },
  ["Sphalerite Dust"]          = { asteroid = "Copper",              priority = 3  },
  ["Pyrite Dust"]              = { asteroid = "Iron",                priority = 2  },
  ["Bauxite Ore"]              = { asteroid = "Aluminium",           priority = 2  },
  ["Monazite Ore"]             = { asteroid = "Aluminium-LanthLine", priority = 1  },
  ["Bastnasite Ore"]           = { asteroid = "Aluminium-LanthLine", priority = 2  },
  ["Soldering Alloy Dust"]     = { asteroid = "Lead",                priority = 2  },
  ["Battery Alloy Dust"]       = { asteroid = "Lead",                priority = 3  },

  -- === AUTOMATION COMMODITIES & GEMS ===
  ["Clay Block"]               = { asteroid = "Clay",                priority = 1  },
  ["Magnesium Dust"]           = { asteroid = "Magnesium",           priority = 1  },
  ["Niobium Dust"]             = { asteroid = "Niobium",             priority = 1  },
  ["Phosphate Dust"]           = { asteroid = "Phosophate",          priority = 1  },
  ["Quartz Dust"]              = { asteroid = "Quartz",              priority = 1  },
  ["Salt Dust"]                = { asteroid = "Salt",                priority = 1  },
  ["Silicon Dust"]             = { asteroid = "Silicon",             priority = 1  },
  ["Thaumium Dust"]            = { asteroid = "Thaumium Dust",       priority = 1  },
  ["Tungsten Dust"]            = { asteroid = "Tungsten-Titanium",   priority = 1  },
  ["Manganese Dust"]           = { asteroid = "Tungsten-Titanium",   priority = 2  },
  ["Titanium Dust"]            = { asteroid = "Tungsten-Titanium",   priority = 3  },
  ["Coal Dust"]                = { asteroid = "Coal",                priority = 1  },
  ["Graphite Dust"]            = { asteroid = "Coal",                priority = 2  },
  ["Graphene Dust"]            = { asteroid = "Coal",                priority = 3  },
  ["Diamond Dust"]             = { asteroid = "Gem Ores",            priority = 1  },
  ["Emerald Dust"]             = { asteroid = "Gem Ores",            priority = 2  },
  ["Certus Quartz Dust"]       = { asteroid = "Gem Ores",            priority = 3  },
  ["Nether Quartz Dust"]       = { asteroid = "Gem Ores",            priority = 4  },
  ["Sapphire Dust"]            = { asteroid = "Gem Ores",            priority = 5  },
  ["Green Sapphire Dust"]      = { asteroid = "Gem Ores",            priority = 6  },
  ["Olivine Dust"]             = { asteroid = "Gem Ores",            priority = 7  },
  ["Ledox Dust"]               = { asteroid = "Europium",            priority = 1  },
  ["Callisto Ice Dust"]        = { asteroid = "Europium",            priority = 2  },
  ["Borax Dust"]               = { asteroid = "Europium",            priority = 4  },

  -- === NUCLEAR & FUELS ===
  ["Uranium-235 Dust"]         = { asteroid = "Uranium-Plutonium",   priority = 2  },
  ["Uranium-238 Dust"]         = { asteroid = "Uranium-Plutonium",   priority = 1  },
  ["Plutonium-239 Dust"]       = { asteroid = "Uranium-Plutonium",   priority = 3  },
  ["Thorium Dust"]             = { asteroid = "Uranium-Plutonium",   priority = 4  },
  ["Naquadah Dust"]            = { asteroid = "Naquadah",            priority = 1  },
  ["Enriched Naquadah Dust"]   = { asteroid = "Naquadah",            priority = 2  },
  ["Naquadria Dust"]           = { asteroid = "Naquadah",            priority = 3  }
}

--------------------------------------------------------------------------------
-- 3. CORE GLOBAL ASTEROID INDEX REGISTRY
-- Maps baseline limits, min modules, power budgets, and hard locks.
--------------------------------------------------------------------------------
config.asteroids = {
  ["Adamantium"]          = { ID = 0,  minModule = 1, distance = 5,   drone = "uhv", drill = "orichalcum"   },
  ["Aluminium"]           = { ID = 1,  minModule = 1, distance = 13,  drone = "mv",  drill = "titanium"     },
  ["Aluminium-LanthLine"] = { ID = 2,  minModule = 1, distance = 101, drone = "mv",  drill = "titanium"     },
  ["Ardite/Cobalt"]       = { ID = 3,  minModule = 1, distance = 30,  drone = "uhv", drill = "neutronium"   },
  ["Basic Magic"]         = { ID = 4,  minModule = 1, distance = 8,   drone = "ev",  drill = "tungstensteel" },
  ["Blue"]                = { ID = 5,  minModule = 1, distance = 20,  drone = "zpm", drill = "orichalcum"   },
  ["Cheese"]              = { ID = 6,  minModule = 1, distance = 121, drone = "uhv", drill = "neutronium"   },
  ["Chrome"]              = { ID = 7,  minModule = 1, distance = 13,  drone = "mv",  drill = "titanium"     },
  ["Clay"]                = { ID = 8,  minModule = 1, distance = 41,  drone = "lv",  drill = "titanium"     },
  ["Coal"]                = { ID = 9,  minModule = 1, distance = 1,   drone = "uhv", drill = "orichalcum"   },
  ["Copper"]              = { ID = 10, minModule = 1, distance = 3,   drone = "ev",  drill = "tungstensteel" },
  ["Cosmic"]              = { ID = 11, minModule = 3, distance = 61,  drone = "uhv", drill = "neutronium"   },
  ["Draconic"]            = { ID = 12, minModule = 1, distance = 161, drone = "uhv", drill = "neutronium"   },
  ["Draconic Core"]       = { ID = 13, minModule = 1, distance = -1,  drone = "none",drill = "none"         }, -- Hard Locked
  ["Europium"]            = { ID = 14, minModule = 2, distance = 40,  drone = "uhv", drill = "neutronium"   },
  ["Gem Ores"]            = { ID = 15, minModule = 1, distance = 17,  drone = "lv",  drill = "titanium"     },
  ["Everglades"]          = { ID = 16, minModule = 1, distance = 201, drone = "uhv", drill = "orichalcum"   },
  ["Holmium/Samarium"]    = { ID = 17, minModule = 1, distance = 40,  drone = "uhv", drill = "neutronium"   },
  ["Ichorium"]            = { ID = 18, minModule = 1, distance = -1,  drone = "none",drill = "none"         }, -- Hard Locked
  ["Indium"]              = { ID = 19, minModule = 1, distance = 50,  drone = "uhv", drill = "neutronium"   },
  ["Infinity Catalyst"]   = { ID = 20, minModule = 1, distance = 91,  drone = "uhv", drill = "neutronium"   },
  ["Iron"]                = { ID = 21, minModule = 1, distance = 1,   drone = "uhv", drill = "orichalcum"   },
  ["Lanthanum"]           = { ID = 22, minModule = 1, distance = 201, drone = "uhv", drill = "neutronium"   },
  ["Lead"]                = { ID = 23, minModule = 1, distance = 5,   drone = "zpm", drill = "orichalcum"   },
  ["Lutetium"]            = { ID = 24, minModule = 1, distance = 231, drone = "uhv", drill = "neutronium"   },
  ["Magnesium"]           = { ID = 25, minModule = 1, distance = 10,  drone = "uhv", drill = "neutronium"   },
  ["Mysterious Crystal"]  = { ID = 26, minModule = 1, distance = 101, drone = "uhv", drill = "neutronium"   },
  ["Naquadah"]            = { ID = 27, minModule = 1, distance = 121, drone = "zpm", drill = "orichalcum"   },
  ["Nickel"]              = { ID = 28, minModule = 1, distance = 13,  drone = "lv",  drill = "titanium"     },
  ["Niobium"]             = { ID = 29, minModule = 1, distance = 30,  drone = "uhv", drill = "neutronium"   },
  ["Phosophate"]          = { ID = 30, minModule = 1, distance = 241, drone = "uhv", drill = "orichalcum"   },
  ["PlatLine Dust"]       = { ID = 31, minModule = 1, distance = -1,  drone = "none",drill = "none"         }, -- Hard Locked
  ["PlatLine Ore"]        = { ID = 32, minModule = 1, distance = 10,  drone = "uhv", drill = "orichalcum"   },
  ["Quartz"]              = { ID = 33, minModule = 1, distance = 101, drone = "mv",  drill = "titanium"     },
  ["Salt"]                = { ID = 34, minModule = 1, distance = 201, drone = "lv",  drill = "titanium"     },
  ["Silicon"]             = { ID = 35, minModule = 1, distance = 241, drone = "ev",  drill = "tungstensteel" },
  ["Tengam"]              = { ID = 36, minModule = 1, distance = -1,  drone = "none",drill = "none"         }, -- Hard Locked
  ["Thaumium Dust"]       = { ID = 37, minModule = 1, distance = 13,  drone = "ev",  drill = "tungstensteel" },
  ["Tin"]                 = { ID = 38, minModule = 1, distance = 2,   drone = "lv",  drill = "titanium"     },
  ["Tungsten-Titanium"]   = { ID = 39, minModule = 1, distance = 181, drone = "lv",  drill = "titanium"     },
  ["Uranium-Plutonium"]   = { ID = 40, minModule = 1, distance = 30,  drone = "uhv", drill = "orichalcum"   }
}

--------------------------------------------------------------------------------
-- 4. STEP-DOWN DISTANCE & CHANCE BREAKPOINT ENGINE
--------------------------------------------------------------------------------
config.optimizationMatrix = {
  ["MK-I"] = {
    ["Adamantium"]          = { iv = {101, 0.1111}, luv = {5, 0.1648}, zpm = {5, 0.2273} },
    ["Aluminium"]           = { mv = {13, 0.0569}, hv = {5, 0.0478}, ev = {5, 0.0427} },
    ["Aluminium-LanthLine"] = { mv = {101, 0.0569}, hv = {101, 0.0569}, ev = {101, 0.0569} },
    ["Clay"]                = { lv = {41, 0.0244} },
    ["Copper"]              = { ev = {3, 0.0427}, iv = {3, 0.1115} },
    ["Nickel"]              = { lv = {13, 0.0244}, mv = {13, 0.0569} },
    ["Tin"]                 = { lv = {2, 0.0244} }
  },
  ["MK-II"] = {
    ["Adamantium"]          = { iv = {101, 0.1111}, luv = {5, 0.1648}, zpm = {5, 0.2273}, uhv = {5, 0.4011} },
    ["Blue"]                = { zpm = {20, 0.2273}, uv = {20, 0.2273}, uhv = {20, 0.4011} },
    ["Chrome"]              = { mv = {13, 0.0569}, hv = {13, 0.0478}, ev = {13, 0.0427} },
    ["Europium"]            = { luv = {41, 0.0476}, uv = {41, 0.0476}, uhv = {40, 0.0958}, uiv = {31, 0.2353} },
    ["Everglades"]          = { zpm = {110, 0.2857}, uv = {110, 0.2857}, uhv = {30, 0.7826}, uiv = {30, 1.0000} },
    ["Naquadah"]            = { zpm = {121, 0.2273}, uv = {121, 0.2273}, uhv = {121, 0.4011} },
    ["Tungsten-Titanium"]   = { lv = {181, 0.0244}, mv = {181, 0.0569}, hv = {181, 0.0478} }
  },
  ["MK-III"] = {
    ["Cosmic"]              = { uv = {61, 0.0476}, uhv = {60, 0.0958}, uev = {60, 0.0958}, uiv = {41, 0.2353} },
    ["Draconic"]            = { uhv = {161, 0.4011}, uev = {161, 0.4011}, uiv = {161, 0.5512} },
    ["Europium"]            = { luv = {41, 0.0476}, uv = {41, 0.0476}, uhv = {40, 0.0958}, uiv = {31, 0.2353} },
    ["Everglades"]          = { zpm = {110, 0.2857}, uv = {110, 0.2857}, uhv = {30, 0.7826}, uiv = {30, 1.0000} },
    ["Lanthanum"]           = { uhv = {201, 0.4011}, uev = {201, 0.4011}, uiv = {201, 0.5512} },
    ["Lutetium"]            = { uhv = {231, 0.4011}, uev = {231, 0.4011}, uiv = {231, 0.5512} },
    ["Phosophate"]          = { uhv = {241, 0.4011}, uev = {241, 0.4011}, uiv = {241, 0.5512} },
    ["Silicon"]             = { ev = {241, 0.0427}, iv = {241, 0.1115}, luv = {241, 0.1648} }
  }
}

--------------------------------------------------------------------------------
-- 5. STOCK QUANTITY MAINTENANCE MONITOR thresholds
--------------------------------------------------------------------------------
config.conditions = {
  { itemName = "Mysterious Crystal Dust", amountToMaintain = 10000,  ID = 26 },
  { itemName = "Cosmic Neutronium Dust",  amountToMaintain = 10000,  ID = 11 },
  { itemName = "Trinium Dust",            amountToMaintain = 10000,  ID = 22 },
  { itemName = "Adamantium Dust",         amountToMaintain = 15000,  ID = 0  },
  { itemName = "Aluminium Dust",          amountToMaintain = 100000, ID = 1  },
  { itemName = "Bauxite Dust",            amountToMaintain = 50000,  ID = 1  },
  { itemName = "Crushed Monazite Ore",    amountToMaintain = 20000,  ID = 2  },
  { itemName = "Cobalt Dust",             amountToMaintain = 30000,  ID = 3  },
  { itemName = "Ardite Dust",             amountToMaintain = 30000,  ID = 3  },
  { itemName = "Lapis Dust",              amountToMaintain = 40000,  ID = 5  },
  { itemName = "Chrome Dust",             amountToMaintain = 25000,  ID = 7  },
  { itemName = "Clay Block",              amountToMaintain = 5000,   ID = 8  },
  { itemName = "Copper Dust",             amountToMaintain = 150000, ID = 10 },
  { itemName = "Callisto Ice Dust",       amountToMaintain = 25000,  ID = 14 },
  { itemName = "Europium Dust",           amountToMaintain = 10000,  ID = 14 },
  { itemName = "Gadolinite-Y Dust",       amountToMaintain = 15000,  ID = 16 },
  { itemName = "Zircon Dust",             amountToMaintain = 15000,  ID = 16 },
  { itemName = "Lutetium Dust",           amountToMaintain = 10000,  ID = 24 },
  { itemName = "Naquadah Dust",           amountToMaintain = 20000,  ID = 27 },
  { itemName = "Nickel Dust",             amountToMaintain = 80000,  ID = 28 },
  { itemName = "Phosphate Dust",          amountToMaintain = 30000,  ID = 30 },
  { itemName = "Quartz Dust",             amountToMaintain = 60000,  ID = 33 },
  { itemName = "Salt Dust",               amountToMaintain = 15000,  ID = 34 },
  { itemName = "Silicon Dust",            amountToMaintain = 90000,  ID = 35 },
  { itemName = "Tin Dust",                amountToMaintain = 100000, ID = 38 },
  { itemName = "Tungsten Dust",           amountToMaintain = 40000,  ID = 39 },
  { itemName = "Uranium Dust",            amountToMaintain = 50000,  ID = 40 }
}

return config
