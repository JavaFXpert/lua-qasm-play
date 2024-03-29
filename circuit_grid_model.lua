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
            retval = retval .. tostring(self.nodes[wire_num][column_num].node_type) .. ':' .. tostring(self.nodes[wire_num][column_num].ctrl_a) .. ', ' 
            -- retval = retval .. tostring(self.nodes[wire_num][column_num].node_type) .. ', ' 
            -- retval = retval .. tostring(self.get_node_gate_part(self, wire_num, column_num)) .. ', ' 
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


function CircuitGridModel:get_nodes_in_column (column_num)
    self.nodes_in_column = {}

    for row_num=1, self.max_wires do
        self.nodes_in_column[row_num] = self.nodes[row_num][column_num]
    end
    return self.nodes_in_column
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
        local nodes_in_column = self:get_nodes_in_column(column_num)
        for idx = 1, self.max_wires do
            if idx ~= wire_num then
                local other_node = nodes_in_column[idx]
                if other_node then
                    if other_node.ctrl_a == wire_num or other_node.ctrl_b == wire_num then
                        return CircuitNodeTypes.CTRL
                    elseif other_node.swap == wire_num then
                        return CircuitNodeTypes.SWAP
                    end
                end
            end
        end
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

function CircuitGridModel:get_gate_wire_for_control_node(control_wire_num, column_num)
    -- TODO: Test this function
    -- Get wire for gate that belongs to a control node on the given wire
    local gate_wire_num = -1
    local nodes_in_column = self:get_nodes_in_column(column_num)
    for wire_idx = 1, self.max_wires do
        if wire_idx ~= control_wire_num then
            other_node = nodes_in_column[wire_idx]
            if other_node then
                if other_node.ctrl_a == control_wire_num or other_node.ctrl_b == control_wire_num then
                    gate_wire_num = wire_idx
                end
            end
        end
    end
end


function CircuitGridModel:get_rotation_gate_nodes()
    -- TODO: Implement following lines
    --[[
        rot_gate_nodes = []
        for column_num in range(self.max_columns):
            for wire_num in range(self.max_wires):
                node = self.nodes[wire_num][column_num]
                if node and node.ctrl_a == -1:
                    if node.node_type == node_types.X or \
                            node.node_type == node_types.Y or \
                            node.node_type == node_types.Z:
                        rot_gate_nodes.append(node)
        return rot_gate_nodes
    --]]
end


function CircuitGridModel:compute_circuit()
    local qasm_str = 'OPENQASM 2.0;\ninclude "qelib1.inc";\n'
    qasm_str = qasm_str .. 'qreg q[' .. tostring(self.max_wires) .. '];\n'
    qasm_str = qasm_str .. 'creg q[' .. tostring(self.max_wires) .. '];\n'
    
    -- Add a column of identity gates to protect simulators from an empty circuit
    qasm_str = qasm_str .. 'id q;\n'
    
    for column_num = 1, self.max_columns do
        for wire_num = 1, self.max_wires do
            local node = self.nodes[wire_num][column_num]
            if node then
                if node.node_type == CircuitNodeTypes.IDEN then
                    -- Identity gate
                    qasm_str = qasm_str .. 'id q[' .. tostring(wire_num) .. '];\n'
                elseif node.node_type == CircuitNodeTypes.X then
                    if node.radians == 0 then
                        if node.ctrl_a ~= -1 then
                            if node.ctrl_b ~= -1 then
                                -- Toffoli gate
                                qasm_str = qasm_str .. 'ccx q[' .. tostring(node.ctrl_a) .. '],'
                                qasm_str = qasm_str .. 'q[' .. tostring(node.ctrl_b) .. '],'
                                qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                            else
                                -- Controlled X gate
                                qasm_str = qasm_str .. 'cx q[' .. tostring(node.ctrl_a) .. '],'
                                qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                            end
                        else
                            -- Pauli-X gate
                            qasm_str = qasm_str .. 'x q[' .. tostring(wire_num) .. '];\n'
                        end
                    else
                        -- Rotation around X axis
                        qasm_str = qasm_str .. 'rx(' .. tostring(node.radians) .. ') '
                        qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                    end
                elseif node.node_type == CircuitNodeTypes.Y then
                    if node.radians == 0 then
                        if node.ctrl_a ~= -1 then
                            -- Controlled Y gate
                            qasm_str = qasm_str .. 'cy q[' .. tostring(node.ctrl_a) .. '],'
                            qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                        else
                            -- Pauli-Y gate
                            qasm_str = qasm_str .. 'y q[' .. tostring(wire_num) .. '];\n'
                        end
                    else
                        -- Rotation around Y axis
                        qasm_str = qasm_str .. 'ry(' .. tostring(node.radians) .. ') '
                        qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                    end
                elseif node.node_type == CircuitNodeTypes.Z then
                    if node.radians == 0 then
                        if node.ctrl_a ~= -1 then
                            -- Controlled Z gate
                            qasm_str = qasm_str .. 'cz q[' .. tostring(node.ctrl_a) .. '],'
                            qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                        else
                            -- Pauli-Z gate
                            qasm_str = qasm_str .. 'z q[' .. tostring(wire_num) .. '];\n'
                        end
                    else
                        if node.ctrl_a ~= -1 then
                            -- Controlled rotation around the Z axis
                            qasm_str = qasm_str .. 'crz(' .. tostring(node.radians) .. ') '
                            qasm_str = qasm_str .. 'q[' .. tostring(node.ctrl_a) .. '],'
                            qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                        else
                            -- Rotation around Z axis
                            qasm_str = qasm_str .. 'rz(' .. tostring(node.radians) .. ') '
                            qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                        end
                    end
                elseif node.node_type == CircuitNodeTypes.S then
                    -- S gate
                    qasm_str = qasm_str .. 's q[' .. tostring(wire_num) .. '];\n'
                elseif node.node_type == CircuitNodeTypes.SDG then
                    -- S dagger gate
                    qasm_str = qasm_str .. 'sdg q[' .. tostring(wire_num) .. '];\n'
                elseif node.node_type == CircuitNodeTypes.T then
                    -- T gate
                    qasm_str = qasm_str .. 't q[' .. tostring(wire_num) .. '];\n'
                elseif node.node_type == CircuitNodeTypes.TDG then
                    -- T dagger gate
                    qasm_str = qasm_str .. 'tdg q[' .. tostring(wire_num) .. '];\n'
                elseif node.node_type == CircuitNodeTypes.H then
                    if node.ctrl_a ~= -1 then
                        -- Controlled Hadamard
                        qasm_str = qasm_str .. 'ch q[' .. tostring(node.ctrl_a) .. '],'
                        qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '];\n'
                    else
                        -- Hadamard gate
                        qasm_str = qasm_str .. 'h q[' .. tostring(wire_num) .. '];\n'
                    end
                elseif node.node_type == CircuitNodeTypes.SWAP then
                    if node.ctrl_a ~= -1 then
                        -- Controlled Swap
                        qasm_str = qasm_str .. 'cswap q[' .. tostring(node.ctrl_a) .. '],'
                        qasm_str = qasm_str .. 'q[' .. tostring(wire_num) .. '],'
                        qasm_str = qasm_str .. 'q[' .. tostring(node.swap) .. '];\n'
                    else
                        -- Swap gate
                        qasm_str = qasm_str .. 'swap q[' .. tostring(wire_num) .. '],'
                        qasm_str = qasm_str .. 'q[' .. tostring(node.swap) .. '];\n'
                    end
                else
                    print("Unknown gate!")
                end
            end
         end
     end
     
    return qasm_str
    
    
    
    -- TODO: Implement following lines
    --[[

                    elif node.node_type == node_types.SWAP:
                        if node.ctrl_a != -1:
                            # Controlled Swap
                            qc.cswap(qr[node.ctrl_a], qr[wire_num], qr[node.swap])
                        else:
                            # Swap gate
                            qc.swap(qr[wire_num], qr[node.swap])

        self.latest_computed_circuit = qc
        return qc
    --]]
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

-- function CircuitGridNode:to_string ()
--     return tostring(self.node_type) .. ':' .. tostring(self.ctrl_a) 
-- end

----------------------------------------
-- Main
homeDir = os.getenv("HOME")
dofile (homeDir.."/PycharmProjects/lua-qasm-play/circuit_node_types.lua")

math.randomseed(os.time())
circuit_grid_model = CircuitGridModel:new{max_wires = 3, max_columns = 13}

circuit_grid_model:set_node(1, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 
        radians = math.pi/8})
circuit_grid_model:set_node(2, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.Y, 
        radians = math.pi/6})
circuit_grid_model:set_node(3, 1, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, 
        radians = math.pi/4})

circuit_grid_model:set_node(1, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.X})
circuit_grid_model:set_node(2, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.Y})
circuit_grid_model:set_node(3, 2, CircuitGridNode:new{node_type = CircuitNodeTypes.Z})

circuit_grid_model:set_node(1, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.S})
circuit_grid_model:set_node(2, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.T})
circuit_grid_model:set_node(3, 3, CircuitGridNode:new{node_type = CircuitNodeTypes.H})

circuit_grid_model:set_node(1, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.SDG})
circuit_grid_model:set_node(2, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.TDG})
circuit_grid_model:set_node(3, 4, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(3, 5, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 
        radians = 0, ctrl_a = 1})
circuit_grid_model:set_node(2, 5, CircuitGridNode:new{node_type = CircuitNodeTypes.TRACE})

circuit_grid_model:set_node(1, 6, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})
circuit_grid_model:set_node(3, 6, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, 
        radians = math.pi/4, ctrl_a = 2})

circuit_grid_model:set_node(3, 7, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 
        radians = 0, ctrl_a = 1, ctrl_b = 2})

circuit_grid_model:set_node(2, 8, CircuitGridNode:new{node_type = CircuitNodeTypes.H, 
        radians = 0, ctrl_a = 3})
circuit_grid_model:set_node(1, 8, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(2, 9, CircuitGridNode:new{node_type = CircuitNodeTypes.Y, 
        radians = 0, ctrl_a = 1})
circuit_grid_model:set_node(3, 9, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})

circuit_grid_model:set_node(3, 10, CircuitGridNode:new{node_type = CircuitNodeTypes.Z, 
        radians = 0, ctrl_a = 1})
circuit_grid_model:set_node(2, 10, CircuitGridNode:new{node_type = CircuitNodeTypes.TRACE})

circuit_grid_model:set_node(1, 11, CircuitGridNode:new{node_type = CircuitNodeTypes.IDEN})
circuit_grid_model:set_node(2, 11, CircuitGridNode:new{node_type = CircuitNodeTypes.SWAP, 
        radians = 0, ctrl_a = -1, ctrl_b = -1, swap = 3})

circuit_grid_model:set_node(3, 12, CircuitGridNode:new{node_type = CircuitNodeTypes.SWAP, 
        radians = 0, ctrl_a = 2, ctrl_b = -1, swap = 1})

circuit_grid_model:set_node(1, 13, CircuitGridNode:new{node_type = CircuitNodeTypes.X, 
        radians = 0, ctrl_a = 2, ctrl_b = 3})


print(circuit_grid_model:to_string())

print(circuit_grid_model:get_nodes_in_column(1))

print('-- START qasm --')
print(circuit_grid_model:compute_circuit())
print('-- END qasm --')



