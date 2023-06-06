Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N','E'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'a-G1', 'a-G3', 'b-G2', 'b-G4'};
Edges.taxi = {'a-b','b-c', 'b-a', 'c-b'};
Edges.TLOF = {'c-R2', 'R2-c'};
Edges.OVF  = {'R2-X', 'X-R2'};
Edges.dir  = {'X-N', 'N-X','X-E','E-X'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes={
{'G1','a','b','c','R2','X','N'};
{'G1','a','b','c','R2','X','E'};
{'G3','a','b','c','R2','X','N'};
{'G3','a','b','c','R2','X','E'};
{'G2','b','c','R2','X','N'};
{'G2','b','c','R2','X','E'};
{'G4','b','c','R2','X','N'};
{'G4','b','c','R2','X','E'};
{'N','X','R2','c','b','a','G1'};
{'E','X','R2','c','b','a','G1'};
{'N','X','R2','c','b','a','G3'};
{'E','X','R2','c','b','a','G3'};
{'N','X','R2','c','b','G2'};
{'E','X','R2','c','b','G2'};
{'N','X','R2','c','b','G4'};
{'E','X','R2','c','b','G4'};
};

flight_path_edges={
{'G1-a','a-b','b-c','c-R2','R2-X','X-N'};
{'G1-a','a-b','b-c','c-R2','R2-X','X-E'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-N'};
{'G3-a','a-b','b-c','c-R2','R2-X','X-E'};
{'G2-b','b-c','c-R2','R2-X','X-N'};
{'G2-b','b-c','c-R2','R2-X','X-E'};
{'G4-b','b-c','c-R2','R2-X','X-N'};
{'G4-b','b-c','c-R2','R2-X','X-E'};
{'N-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'E-X','X-R2','R2-c','c-b','b-a','a-G1'};
{'N-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'E-X','X-R2','R2-c','c-b','b-a','a-G3'};
{'N-X','X-R2','R2-c','c-b','b-G2'};
{'E-X','X-R2','R2-c','c-b','b-G2'};
{'N-X','X-R2','R2-c','c-b','b-G4'};
{'E-X','X-R2','R2-c','c-b','b-G4'};
};
