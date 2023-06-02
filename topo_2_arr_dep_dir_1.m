Nodes.gates = {'G1','G2','G3','G4'};
Nodes.gatesEn = cellfun(@(x) [x '_en'],Nodes.gates,'UniformOutput',false);
Nodes.gatesEx = cellfun(@(x) [x '_ex'],Nodes.gates,'UniformOutput',false);
Nodes.taxi  = {'a','b','d','e','f','g'};
Nodes.TLOF  = {'R1', 'R2'};
Nodes.TLOFen = {'c'};
Nodes.TLOFex = {'h','i'};
Nodes.OVF   = {'Y', 'X'};
Nodes.dir   = {'N', 'S'};

gateCapacity = 3;

new_nodes = cell(1, length(Nodes.gates)*(gateCapacity));  % Pre-allocate new node cell array
count = 0;  % Initialize count

% Loop over gates
for g = 1:length(Nodes.gates)
    gate = Nodes.gates{g};
    % Loop over gate capacity
    for c = 0:gateCapacity
        count = count + 1;  % Increment count
        new_nodes{count} = sprintf('%s%c%d', gate, 'c', c);  % Create new node name and store in cell array
    end
end

Nodes.gateC = new_nodes;
Nodes.all   = [[Nodes.gates], [Nodes.gatesEn], [Nodes.gateC], [Nodes.gatesEx], [Nodes.taxi], [Nodes.TLOF], [Nodes.TLOFen], [Nodes.TLOFex], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1_ex-a','G3_ex-a','G2_ex-b','G4_ex-b','g-G4_en', 'e-G2_en', 'd-G1_en', 'f-G3_en'};
Edges.taxi = {'a-b','b-c','i-f', 'f-g', 'h-d', 'd-e'};
Edges.TLOF = {'c-R2','R1-i', 'R1-h'};
Edges.OVF  = {'R2-X','Y-R1'};
Edges.dir  = {'X-N','S-Y'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];

flight_path_nodes_arr={
{'S','Y','R1','h','d','G1_en'}
{'S','Y','R1','h','d','e','G2_en'}    
{'S','Y','R1','i','f','G3_en'}
{'S','Y','R1','i','f','g','G4_en'}    
    };

flight_path_edges_arr={
{'S-Y','Y-R1','R1-h','h-d','d-G1_en'}
{'S-Y','Y-R1','R1-h','h-d', 'd-e','e-G2_en'}    
{'S-Y','Y-R1','R1-i','i-f','f-G3_en'}
{'S-Y','Y-R1','R1-i','i-f','f-g','g-G4_en'}
    };

flight_path_nodes_dep={
    {'G1_ex','a','b','c','R2','X','N'}
    {'G2_ex','b','c','R2','X','N'}
    {'G3_ex','a','b','c','R2','X','N'}
    {'G4_ex','b','c','R2','X','N'}
};

flight_path_edges_dep={
    {'G1_ex-a','a-b','b-c','c-R2','R2-X','X-N'}
    {'G2_ex-b','b-c','c-R2','R2-X','X-N'}
    {'G3_ex-a','a-b','b-c','c-R2','R2-X','X-N'}
    {'G4_ex-b','b-c','c-R2','R2-X','X-N'}
};
