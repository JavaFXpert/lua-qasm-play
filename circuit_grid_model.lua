-- CircuitGridModel definitions
-- CircuitGridModel = {max_wires = 0, max_columns = 0}
CircuitGridModel = {}

function CircuitGridModel:new (o, max_wires, max_columns)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.max_wires = max_wires or 0
    self.max_columns = max_columns or 0
    return o
end

function CircuitGridModel:printSelf ()
    print("max_wires: ", self.max_wires, "max_columns: ", self.max_columns)
end

----------------------------------------
-- CircuitGridNode definitions
CircuitGridNode = {}

function CircuitGridNode:new (o, node_type, radians, ctrl_a, ctrl_b, swap)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.node_type = node_type
    self.radians = radians or 0.0
    self.ctrl_a = ctrl_a or -1
    self.ctrl_b = ctrl_b or -1
    self.swap = swap or -1
    self.wire_num = -1
    self.column_num = -1
    return o
end

----------------------------------------
-- Main
myCircuit = CircuitGridModel:new(nil,3, 7)

myCircuit:printSelf()

homeDir = os.getenv("HOME")
dofile (homeDir.."/PycharmProjects/lua-qasm-play/circuit_node_types.lua")
print (CircuitNodeTypes.Y)