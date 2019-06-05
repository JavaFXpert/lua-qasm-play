-- CircuitGridModel definitions
-- CircuitGridModel = {max_wires = 0, max_columns = 0}
CircuitGridModel = {nodes = nil}

function CircuitGridModel:new (o, max_wires, max_columns)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.max_wires = max_wires or 0
    self.max_columns = max_columns or 0
    self.create_nodes_array(o)
    self.latest_computed_circuit = None
    return o
end

function CircuitGridModel:to_string ()
    local retval = ''
    for wire_num = 1, self.max_wires do
        retval = retval .. '\n'
        for column_num = 1, self.max_columns do
            -- TODO: Convert this: retval += str(self.get_node_gate_part(wire_num, column_num)) + ', '
            retval = retval .. tostring(self.nodes[wire_num][column_num].node_type) .. ', ' 
        end
    end
    return 'CircuitGridModel: ' .. retval
end

function CircuitGridModel:create_nodes_array ()
  self.nodes = {}

  for i=1, self.max_wires do
     self.nodes[i] = {}
    
     for j=1, self.max_columns do
        self.nodes[i][j] = CircuitGridNode:new(nil)
        print("self.nodes[i][j]: ", self.nodes[i][j])
        print("self.nodes[i][j].node_type: ", self.nodes[i][j].node_type)
     end
    
  end
end


function CircuitGridModel:set_node (wire_num, column_num, circuit_grid_node)
  -- First, embed the wire and column locations in the node
    circuit_grid_node.wire_num = wire_num
    circuit_grid_node.column_num = column_num
    self.nodes[wire_num][column_num] = circuit_grid_node
  
end

----------------------------------------
-- CircuitGridNode definitions
CircuitGridNode = {}

function CircuitGridNode:new (o, node_type, radians, ctrl_a, ctrl_b, swap)
    local o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.node_type = node_type or -1 --TODO: Use CircuitNodeTypes EMPTY here
    self.radians = radians or 0.0
    self.ctrl_a = ctrl_a or -1
    self.ctrl_b = ctrl_b or -1
    self.swap = swap or -1
    self.wire_num = -1
    self.column_num = -1
    return o
end

function CircuitGridNode:to_string ()
    return tostring(self.node_type)
end

----------------------------------------
-- Main
circuit_grid_model = CircuitGridModel:new(nil,3, 7)

print(circuit_grid_model:to_string())

homeDir = os.getenv("HOME")
dofile (homeDir.."/PycharmProjects/lua-qasm-play/circuit_node_types.lua")

local my_node = CircuitGridNode:new(nil, CircuitNodeTypes.Y, math.pi)
--local my_node = CircuitGridNode:new(nil)
print("my_node: ", my_node)
print("my_node.node_type: ", my_node.node_type)
--print("my_node: ", my_node.to_string())
--circuit_grid_model.set_node(0, 0, my_node)
print (CircuitNodeTypes.Y)