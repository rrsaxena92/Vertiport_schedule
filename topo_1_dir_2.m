
Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c','d','e','f','g','h', 'i'};
Nodes.TLOF  = {'R1', 'R2'};
Nodes.OVF   = {'X','Y'};
Nodes.dir   = {'N','E','W','S'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'g-G4', 'e-G2', 'd-G1', 'f-G3'};
Edges.taxi = {'a-b','b-c','i-f', 'f-g', 'h-d', 'd-e'};
Edges.TLOF = {'c-R2', 'R1-i', 'R1-h'};
Edges.OVF  = {'R2-X', 'Y-R1'};
Edges.dir  = {'X-N','X-E', 'W-Y', 'S-Y'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];



flight_path_nodes={
    {'G1','a','b','c','R2','X','N'},{'G1','a','b','c','R2','X','E'},{'G3','a','b','c','R2','X','N'},{'G3','a','b','c','R2','X','E'},{'G2','b','c','R2','X','N'},{'G2','b','c','R2','X','E'},{'G4','b','c','R2','X','N'},{'G4','b','c','R2','X','E'}, ...
    {'W','Y','R1','i','f','G3'},{'W','Y','R1','i','f','g','G4'},{'W','Y','R1','h','d','G1'},{'W','Y','R1','h','d','e','G2'},{'S','Y','R1','i','f','G3'},{'S','Y','R1','i','f','g','G4'},{'S','Y','R1','h','d','G1'},{'S','Y','R1','h','d','e','G2'}...
    };

flight_path_edges={
    {'G1-a','a-b','b-c','c-R2','R2-X','X-N'},{'G1-a','a-b','b-c','c-R2','R2-X','X-E'},{'G3-a','a-b','b-c','c-R2','R2-X','X-N'},{'G3-a','a-b','b-c','c-R2','R2-X','X-E'},{'G2-b','b-c','c-R2','R2-X','X-N'},{'G2-b','b-c','c-R2','R2-X','X-E'},{'G4-b','b-c','c-R2','R2-X','X-N'},{'G4-b','b-c','c-R2','R2-X','X-E'},...
    {'W-Y','Y-R1','R1-i','i-f','f-G3'},{'W-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'W-Y','Y-R1','R1-h','h-d','d-G1'},{'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'},{'S-Y','Y-R1','R1-i','i-f','f-G3'},{'S-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'S-Y','Y-R1','R1-h','h-d','d-G1'},{'S-Y','Y-R1','R1-h', 'h-d', 'd-e','e-G2'}...
    };

