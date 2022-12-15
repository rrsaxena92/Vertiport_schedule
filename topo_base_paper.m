
Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c','d','e','f','g','h', 'i'};
Nodes.TLOF  = {'R1', 'R2'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF]];

Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'g-G4', 'e-G2', 'd-G1', 'f-G3'};
Edges.taxi = {'a-b','b-c','i-f', 'f-g', 'h-d', 'd-e'};
Edges.TLOF = {'c-R2', 'R1-i', 'R1-h'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF]];
Edges.len  = edge_length_before_TLOF;


flight_path_nodes={
    {'G1','a','b','c','R2'};
    {'G1','a','b','c','R2'};
    {'G3','a','b','c','R2'};
    {'G3','a','b','c','R2'};
    {'G2','b','c','R2'};
    {'G2','b','c','R2'};
    {'G4','b','c','R2'};
    {'G4','b','c','R2'};
    {'R1','i','f','G3'};
    {'R1','i','f','g','G4'};
    {'R1','h','d','G1'};
    {'R1','h','d','e','G2'};
    {'R1','i','f','G3'};
    {'R1','i','f','g','G4'};
    {'R1','h','d','G1'};
    {'R1','h','d','e','G2'};
    };

flight_path_edges={
    {'G1-a','a-b','b-c','c-R2'};
    {'G1-a','a-b','b-c','c-R2'};
    {'G3-a','a-b','b-c','c-R2'};
    {'G3-a','a-b','b-c','c-R2'};
    {'G2-b','b-c','c-R2'};
    {'G2-b','b-c','c-R2'};
    {'G4-b','b-c','c-R2'};
    {'G4-b','b-c','c-R2'},
    {'R1-i','i-f','f-G3'};
    {'R1-i','i-f','f-g','g-G4'};
    {'R1-h','h-d','d-G1'};
    {'R1-h','h-d', 'd-e','e-G2'};
    {'R1-i','i-f','f-G3'};
    {'R1-i','i-f','f-g','g-G4'};
    {'R1-h','h-d','d-G1'};
    {'R1-h', 'h-d', 'd-e','e-G2'};
    };

