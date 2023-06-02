Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'a-G1','a-G3','b-G2','b-G4'};
Edges.taxi = {'b-a','c-b'};
Edges.TLOF = {'R2-c'};
Edges.OVF  = {'X-R2'};
Edges.dir  = {'N-X'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes={
{'N','X','R2','c','b','a','G1'};...
{'N','X','R2','c','b','a','G3'};...
{'N','X','R2','c','b','G2'};...
{'N','X','R2','c','b','G4'};...
};

flight_path_edges={
{'N-X','X-R2','R2-c','c-b','b-a','a-G1'};...
{'N-X','X-R2','R2-c','c-b','b-a','a-G3'};...
{'N-X','X-R2','R2-c','c-b','b-G2'};...
{'N-X','X-R2','R2-c','c-b','b-G4'};...
};
