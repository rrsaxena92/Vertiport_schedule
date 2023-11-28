Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b'};
Nodes.TLOFen = {'c'};
Nodes.TLOFex = {'c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N','E','W','S'};

capacityNodes = 1;

new_nodes = cell(1, length(Nodes.gates)*(capacityNodes));  % Pre-allocate new node cell array
count = 0;  % Initialize count

% Loop over gates
for g = 1:length(Nodes.gates)
    gate = Nodes.gates{g};
    % Loop over gate capacity
    for c = 0:capacityNodes
        count = count + 1;  % Increment count
        new_nodes{count} = sprintf('%s%c%d', gate, 'c', c);  % Create new node name and store in cell array
    end
end

Nodes.gateC = new_nodes;
Nodes.all   = unique([[Nodes.gates], [Nodes.gateC], [Nodes.taxi], [Nodes.TLOF], [Nodes.TLOFen], [Nodes.TLOFex], [Nodes.OVF], [Nodes.dir]]);

Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'a-G1', 'a-G3', 'b-G2', 'b-G4'};
Edges.taxi = {'a-b','b-c', 'b-a', 'c-b'};
Edges.TLOF = {'c-R2', 'R2-c'};
Edges.OVF  = {'R2-X', 'X-R2'};
Edges.dir  = {'X-N', 'N-X','X-E','E-X','X-W','W-X','X-S','S-X'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes_dep={
{'G1','a','b','c','R2','X','N'};
{'G1','a','b','c','R2','X','E'};
{'G1','a','b','c','R2','X','W'};
{'G1','a','b','c','R2','X','S'};
{'G3','a','b','c','R2','X','N'};
{'G3','a','b','c','R2','X','E'};
{'G3','a','b','c','R2','X','W'};
{'G3','a','b','c','R2','X','S'};
{'G2','b','c','R2','X','N'};
{'G2','b','c','R2','X','E'};
{'G2','b','c','R2','X','W'};
{'G2','b','c','R2','X','S'};
{'G4','b','c','R2','X','N'};
{'G4','b','c','R2','X','E'};
{'G4','b','c','R2','X','W'};
{'G4','b','c','R2','X','S'};
};

flight_path_nodes_arr={
{'N','X','R2','c','b','a','G1'};
{'E','X','R2','c','b','a','G1'};
{'W','X','R2','c','b','a','G1'};
{'S','X','R2','c','b','a','G1'};
{'N','X','R2','c','b','a','G3'};
{'E','X','R2','c','b','a','G3'};
{'W','X','R2','c','b','a','G3'};
{'S','X','R2','c','b','a','G3'};
{'N','X','R2','c','b','G2'};
{'E','X','R2','c','b','G2'};
{'W','X','R2','c','b','G2'};
{'S','X','R2','c','b','G2'};
{'N','X','R2','c','b','G4'};
{'E','X','R2','c','b','G4'};
{'W','X','R2','c','b','G4'};
{'S','X','R2','c','b','G4'};
};

flight_path_edges_dep={
{'G1-a','a-b','b-c','c-R2','R2-X','X-N'};
{'G1-a','a-b','b-c','c-R2','R2-X','X-E'};
{'G1-a','a-b','b-c','c-R2','R2-X','X-W'};
{'G1-a','a-b','b-c','c-R2','R2-X','X-S'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-N'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-E'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-W'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-S'};
{'G2-b','b-c','c-R2','R2-X','X-N'};
{'G2-b','b-c','c-R2','R2-X','X-E'};
{'G2-b','b-c','c-R2','R2-X','X-W'};
{'G2-b','b-c','c-R2','R2-X','X-S'};
{'G4-b','b-c','c-R2','R2-X','X-N'};
{'G4-b','b-c','c-R2','R2-X','X-E'};
{'G4-b','b-c','c-R2','R2-X','X-W'};
{'G4-b','b-c','c-R2','R2-X','X-S'};
};

flight_path_edges_arr={
{'N-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'E-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'W-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'S-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'N-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'E-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'W-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'S-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'N-X','X-R2','R2-c','c-b','b-G2'};
{'E-X','X-R2','R2-c','c-b','b-G2'};
{'W-X','X-R2','R2-c','c-b','b-G2'};
{'S-X','X-R2','R2-c','c-b','b-G2'};
{'N-X','X-R2','R2-c','c-b','b-G4'};
{'E-X','X-R2','R2-c','c-b','b-G4'};
{'W-X','X-R2','R2-c','c-b','b-G4'};
{'S-X','X-R2','R2-c','c-b','b-G4'};
};
