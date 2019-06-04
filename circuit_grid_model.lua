-- CircuitGridModel definitions
CircuitGridModel = {maxWires = 0, maxColumns = 0}
-- CircuitGridModel = {}

function CircuitGridModel:new (o, maxWires, maxColumns)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.maxWires = maxWires or 0
    self.maxColumns = maxColumns or 0
    return o
end

function CircuitGridModel:printSelf ()
    print("maxWires: ", self.maxWires, "maxColumns: ", self.maxColumns)
end

----------------------------------------
-- CircuitGridNode definitions
CircuitGridNode = {}

function CircuitGridNode:new (o, maxWires, maxColumns)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.maxWires = maxWires or 0
    self.maxColumns = maxColumns or 0
    return o
end

--[[
--]]

----------------------------------------
-- Main
myCircuit = CircuitGridModel:new(nil,3, 5)

myCircuit:printSelf()

homeDir = os.getenv("HOME")
dofile (homeDir.."/PycharmProjects/lua-qasm-play/circuit_node_types.lua")
print (CircuitNodeTypes.Y)