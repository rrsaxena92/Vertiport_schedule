
Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'d','e','f','g','h', 'i'};
Nodes.TLOF  = {'R1'};
Nodes.OVF   = {'Y'};
Nodes.dir   = {'W','S'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'g-G4', 'e-G2', 'd-G1', 'f-G3'};
Edges.taxi = {'i-f', 'f-g', 'h-d', 'd-e'};
Edges.TLOF = {'R1-i', 'R1-h'};
Edges.OVF  = {'Y-R1'};
Edges.dir  = {'W-Y', 'S-Y'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes={
    {'W','Y','R1','h','d','G1'}
    {'S','Y','R1','h','d','G1'}
    {'W','Y','R1','h','d','e','G2'}
    {'S','Y','R1','h','d','e','G2'}
    {'W','Y','R1','i','f','G3'}
    {'S','Y','R1','i','f','G3'}
    {'W','Y','R1','i','f','g','G4'}
    {'S','Y','R1','i','f','g','G4'}
    };

flight_path_edges={
    {'W-Y','Y-R1','R1-h','h-d','d-G1'}
    {'S-Y','Y-R1','R1-h','h-d','d-G1'}
    {'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'}
    {'S-Y','Y-R1','R1-h', 'h-d', 'd-e','e-G2'}
    {'W-Y','Y-R1','R1-i','i-f','f-G3'}
    {'S-Y','Y-R1','R1-i','i-f','f-G3'}
    {'W-Y','Y-R1','R1-i','i-f','f-g','g-G4'}
    {'S-Y','Y-R1','R1-i','i-f','f-g','g-G4'}
    };

