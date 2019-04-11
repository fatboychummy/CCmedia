--[[FATFILE
4
https://raw.githubusercontent.com/fatboychummy/CCmedia/master/helpfulthings/FatInventoryHandler.lua
]]

local meta = {}
local met = {}
local funcs = {}
meta.__index = met

-- Error handling functions
if not fs.exists("/FatFileSystem.lua") then
  error("FatFileSystem.lua was not found in the root directory.", -1)
end

local fileSystem = dofile("FatFileSystem.lua")
local fe = fileSystem.betterFind("FatErrors.lua")
if #fe == 1 then
  fe = fe[1]
  fe = dofile(fe)
elseif #fe > 1 then
  error("Multiple copies of FatErrors.lua exist!")
else
  error("FatErrors.lua does not exist anywhere!")
end

local bassert = fe.bassert
local er = fe.er
fe = nil
----


-- hidden functions

-- helper function for some functions
local function doCall(self, ...)
  local dat = {pcall(peripheral.call, self.attachmentName, ...)}
  -- call the function...
  bassert(dat[1], 2, -1, "findItem-doCall: " .. tostring(dat[2]))
  -- check if the function threw an error...
  return table.unpack(dat)
end

-- start of meta functions.


-- Sets this inventory to an inventory
function met.attach(self, inventoryName)
  bassert(type(self) == "table", 2, 1, 1, "table", self)
  bassert(self.__type == "inventory", 2, 0, self)
  -- if this is not an inventory...
  bassert(type(inventoryName) == "string", 2, 1, 2, "string",
        inventoryName)
  bassert(type(peripheral.call(inventoryName, "size")) == "number", 2,
        2, 2, inventoryName)
  -- is this inventory going to be valid?

  self.attachmentName = inventoryName

  return self
end

-- Removes the inventory
function met.detach(self)
  bassert(type(self) == "table", 2, 1, 1, "table", self)
  bassert(self.__type == "inventory", 2, 0, self)
  -- if this is an inventory...

  -- don't worry about checking if it's already valid.
  -- it's extra work that isn't needed, just set it to false anyways.
  -- worst case: it's already false.

  self.attachmentName = false

  return self
end


-- finds an item using it's mod:name and damage
function met.findItem(self, itemName, damage)
  bassert(type(self) == "table", 2, 1, 1, "table", self)
  bassert(self.__type == "inventory", 2, 0, self)
  -- if this is an inventory...
  bassert(type(self.attachmentName) == "string", 2, -1,
      "This inventory is not attached to anything.")
  -- is the inventory valid?
  bassert(type(itemName) == "string", 2, 1, 2, "string",
      itemName)
  -- is the name supplied valid?
  bassert(type(damage) == "number" or damage == nil, 2, 1, 1,
      "number or nil", damage)
  -- is the damage valid? (if it's nil, ignore damage values and grab the all
  -- which match.)

  local _, size = doCall(self, "size")
  local _, inv = doCall(self, "list")
  local itms = {}

  for i = 1, size do
    -- for each slot...
    if inv[i] then
      -- if there is an item...
      if inv[i].name == itemName then
        -- if the name matches...
        if not damage then
          -- if there was no damage supplied...
          local _, item = doCall(self, "getItem", i)
          itms[#itms + 1] = item
        elseif inv[i].damage == damage then
          -- if there was damage supplied, and the damage matches...
          local _, item = doCall(self, "getItem", i)
          itms[#itms + 1] = item
        end
      end
    end
  end

  if #itms > 0 then
    return itms
    -- if items were found... return them.
  end

  return false
end

-- finds an item via it's fancy looking Full Name
function met.findItemByDisplayName(self, itemName)
  bassert(type(self) == "table", 2, 1, 1, "table", self)
  bassert(self.__type == "inventory", 2, 0, self)
  -- if this is an inventory...
  bassert(type(self.attachmentName) == "string", 2, -1,
      "This inventory is not attached to anything.")
  -- is the inventory valid?
  bassert(type(itemName) == "string", 2, 1, 2, "string",
      itemName)
  -- is the name supplied valid?

  local _, size = doCall(self, "size")
  local _, inv = doCall(self, "list")
  local itms = {}

  for i = 1, size do
    -- for each slot...
    if inv[i] then
      -- if there is an item in slot i...
      local _, itm = doCall(self, "getItemMeta", i)
      if itm then
        -- if the item meta was retrieved successfully
        if itm.displayName == itemName then
          -- if the display name matches our search...
          itms[#itms + 1] = itm
        end
      end
    end
  end

  if #itms > 0 then
    return itms
    -- if items were found... return them.
  end

  return false
end

function met.destroy(self)
  setmetatable(self,nil)
  self = false
  -- if you set to nil it sets self to an empty table???
end

-- start of functions


-- creates a new inventory.
function funcs.new()
  local tb = {
    __type = "inventory",
    attachmentName = false
  }
  setmetatable(tb, meta)
  -- allow doing "inventory:functionName(...)"
  return tb
end

setmetatable(funcs, meta)
-- allow doing "inventoryHandler.functionName(inventory, ...)"

return funcs
