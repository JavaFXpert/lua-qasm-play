-- CircuitGridModel definitions
-- CircuitGridModel = {max_wires = 0, max_columns = 0}
CircuitGridModel = {}

function CircuitGridModel:new (o, max_wires, max_columns)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.max_wires = max_wires or 0
    self.max_columns = max_columns or 0
    self.create_nodes_array(o)
    self.latest_computed_circuit = nil
    return o
end

function CircuitGridModel:to_string ()
    local retval = ''
    for wire_num = 1, self.max_wires do
        retval = retval .. '\n'
        for column_num = 1, self.max_columns do
            retval = retval .. tostring(self.nodes[wire_num][column_num].node_type) .. ', ' 
            -- TODO: use get_node_gate_part() instead
        end
    end
    return 'CircuitGridModel: ' .. retval
end

function CircuitGridModel:create_nodes_array ()
    self.nodes = {}

    for i=1, self.max_wires do
        self.nodes[i] = {}
    
        for j=1, self.max_columns do
            self.nodes[i][j] = CircuitGridNode:new{node_type = CircuitNodeTypes.EMPTY}
            
            --TODO: Why does the following form break things?
            --self.nodes[i][j] = CircuitGridNode:new(nil, CircuitNodeTypes.EMPTY) 
        end
    end
end


function CircuitGridModel:set_node (wire_num, column_num, circuit_grid_node)
    -- First, embed the wire and column locations in the node
    circuit_grid_node.wire_num = wire_num
    circuit_grid_node.column_num = column_num
    self.nodes[wire_num][column_num] = circuit_grid_node
end

function CircuitGridModel:get_node (wire_num, column_num)
    return self.nodes[wire_num][column_num]
end

----------------------------------------
-- CircuitGridNode definitions
CircuitGridNode = {}

function CircuitGridNode:new (o, node_type, radians, ctrl_a, ctrl_b, swap)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    self.node_type = node_type or CircuitNodeTypes.EMPTY
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
homeDir = os.getenv("HOME")
dofile (homeDir.."/PycharmProjects/lua-qasm-play/circuit_node_types.lua")

math.randomseed(os.time())
circuit_grid_model = CircuitGridModel:new{max_wires = 3, max_columns = 7}

print(circuit_grid_model:to_string())

circuit_grid_model:set_node(1, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, radians = math.pi})
print(circuit_grid_model:to_string())

