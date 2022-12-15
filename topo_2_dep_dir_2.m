
Nodes.gates = {'G1'};
Nodes.taxi  = {'a','b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N','E'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1-a'};
Edges.taxi = {'a-b','b-c'};
Edges.TLOF = {'c-R2'};
Edges.OVF  = {'R2-X'};
Edges.dir  = {'X-N','X-E'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];


flight_path_nodes={
{'G1','a','b','c','R2','X','N'};...
{'G1','a','b','c','R2','X','E'};...
    };

flight_path_edges={
{'G1-a','a-b','b-c','c-R2','R2-X','X-N'};...
{'G1-a','a-b','b-c','c-R2','R2-X','X-E'};...
};
