% TOPO GIMPO

Nodes.gates = {'G1','G2','G3','G4','G5','G6','G7','G8','G9','G10','G11','G12','G13','G14','G15','G16','G17','G18','G19','G20'};
Nodes.taxi  = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n'};
Nodes.TLOF  = {'T1','T2','T3','T4'};
Nodes.TLOFen = {'T1enx','T2enx','T3enx','T4enx'};
Nodes.TLOFex = {'T1enx','T2enx','T3enx','T4enx'};
Nodes.OVF    = {'O1','O2','O3','O4'};
Nodes.dir    = {'T1D1','T1D2','T2D1','T3D1','T4D1','T4D2','T4D3'};

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

ArrGate = {'e-G1','f-G2','g-G3','h-G4','i-G5','i-G6','i-G7','h-G8','g-G9','f-G10','j-G11','k-G12','l-G13','m-G14','n-G15','n-G16','m-G17','l-G18','k-G19','j-G20'};
DepGate = {'G1-e','G2-f','G3-g','G4-h','G5-i','G6-i','G7-i','G8-h','G9-g','G10-f','G11-j','G12-k','G13-l','G14-m','G15-n','G16-n','G17-m','G18-l','G19-k','G20-j'};
Edges.gate = [DepGate, ArrGate];
Edges.taxi = {'a-b', 'b-a', 'b-c', 'c-b', 'c-d', 'd-c', 'b-e', 'e-b', 'e-f', 'f-e', 'f-g', 'g-f', 'g-h', 'h-g', 'h-i', 'i-h', 'd-j', 'j-d', 'j-k', 'k-j', 'k-l','l-k','l-m', 'm-l', 'm-n','n-m','a-T1enx','a-T2enx','c-T3enx','d-T4enx', 'T1enx-a','T2enx-a','T3enx-c','T4enx-d'};
Edges.TLOF = {'T1-T1enx','T2-T2enx','T3-T3enx','T4-T4enx', 'T1enx-T1','T2enx-T2','T3enx-T3','T4enx-T4'};
Edges.OVF  = {'T1-O1', 'O1-T1', 'T2-O2', 'O2-T2', 'T3-O3', 'O3-T3', 'O4-T4', 'T4-O4'};
Edges.dir  = {'T1D1-O1','T1D2-O1','O1-T1D1','O1-T1D2', 'T2D1-O2', 'O2-T2D1', 'T3D1-O3', 'O3-T3D1','T4D1-O4','T4D2-O4','T4D3-O4','O4-T4D1','O4-T4D2','O4-T4D3'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];

[flight_path_nodes_arr, flight_path_edges_arr, flight_path_nodes_dep, flight_path_edges_dep] = generate_vert_path(Nodes, Edges);