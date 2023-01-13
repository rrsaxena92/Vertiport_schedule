
Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1-a','G3-a','G2-b','G4-b'};
Edges.taxi = {'a-b','b-c'};
Edges.TLOF = {'c-R2'};
Edges.OVF  = {'R2-X'};
Edges.dir  = {'X-N'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes={
{'G1','a','b','c','R2','X','N'};...
{'G3','a','b','c','R2','X','N'};...
{'G2','b','c','R2','X','N'};...
{'G4','b','c','R2','X','N'};...
};

flight_path_edges={
{'G1-a','a-b','b-c','c-R2','R2-X','X-N'};...
{'G3-a','a-b','b-c','c-R2','R2-X','X-N'};...
{'G2-b','b-c','c-R2','R2-X','X-N'};...
{'G4-b','b-c','c-R2','R2-X','X-N'};...
};
