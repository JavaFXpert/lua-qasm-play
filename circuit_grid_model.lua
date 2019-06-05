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
            --retval = retval .. tostring(self.nodes[wire_num][column_num].node_type) .. ', ' 
            retval = retval .. tostring(self.get_node_gate_part(self, wire_num, column_num)) .. ', ' 
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

function CircuitGridModel:get_node_gate_part (wire_num, column_num)
    local requested_node = self.nodes[wire_num][column_num]
    if requested_node and requested_node.node_type ~= CircuitNodeTypes.EMPTY then
        -- Node is occupied so return its gate
        return requested_node.node_type
    else
        --print("TODO: Handle if node is EMPTY")
        -- Check for control nodes from gates in other nodes in this column
        --[[ TODO: make next lines work
        local nodes_in_column = self.nodes[:, column_num]
            for idx in range(self.max_wires):
                if idx != wire_num:
                    other_node = nodes_in_column[idx]
                    if other_node:
                        if other_node.ctrl_a == wire_num or other_node.ctrl_b == wire_num:
                            return node_types.CTRL
                        elif other_node.swap == wire_num:
                            return node_types.SWAP
        --]]
    end
    return CircuitNodeTypes.EMPTY   
end

--[[
x    def get_node_gate_part(self, wire_num, column_num):
x        requested_node = self.nodes[wire_num][column_num]
x        if requested_node and requested_node.node_type != node_types.EMPTY:
x            # Node is occupied so return its gate
x            return requested_node.node_type
x        else:
x            # Check for control nodes from gates in other nodes in this column
x            nodes_in_column = self.nodes[:, column_num]
            for idx in range(self.max_wires):
                if idx != wire_num:
                    other_node = nodes_in_column[idx]
                    if other_node:
                        if other_node.ctrl_a == wire_num or other_node.ctrl_b == wire_num:
                            return node_types.CTRL
                        elif other_node.swap == wire_num:
                            return node_types.SWAP

        return node_types.EMPTY

--]]

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
circuit_grid_model = CircuitGridModel:new{max_wires = 3, max_columns = 13}

circuit_grid_model:set_node(1, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.X, math.pi/8})
circuit_grid_model:set_node(2, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.Y, math.pi/6})
circuit_grid_model:set_node(3, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, math.pi/4})

circuit_grid_model:set_node(1, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.X})
circuit_grid_model:set_node(2, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.Y})
circuit_grid_model:set_node(3, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.Z})

circuit_grid_model:set_node(1, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.S})
circuit_grid_model:set_node(2, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.T})
circuit_grid_model:set_node(3, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.H})

circuit_grid_model:set_node(1, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.SDG})
circuit_grid_model:set_node(2, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.TDG})
circuit_grid_model:set_node(3, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(3, 5, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 0, 0})
circuit_grid_model:set_node(2, 5, CircuitGridNode:new{node_type = CircuitNodeTypes.TRACE})

circuit_grid_model:set_node(1, 6, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})
circuit_grid_model:set_node(3, 6, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, math.pi/4, 1})

circuit_grid_model:set_node(3, 7, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 0, 0, 1})

circuit_grid_model:set_node(2, 8, CircuitGridNode:new{node_type = CircuitNodeTypes.H, 0, 2})
circuit_grid_model:set_node(1, 8, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(2, 9, CircuitGridNode:new{node_type = CircuitNodeTypes.Y, 0, 0})
circuit_grid_model:set_node(3, 9, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(3, 10, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, 0, 0})
circuit_grid_model:set_node(2, 10, CircuitGridNode:new{node_type = CircuitNodeTypes.TRACE})

circuit_grid_model:set_node(1, 11, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(3, 12, CircuitGridNode:new{node_type = CircuitNodeTypes.SWAP, 0, 1, -1, 0})

circuit_grid_model:set_node(1, 13, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 0, 1, 2})

print(circuit_grid_model:to_string())

