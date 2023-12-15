Nodes.gates = {'G1'};
Nodes.taxi  = {'b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N','E', 'W'};
Nodes.gateC = {'G1c0','G1c1'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.gateC], [Nodes.OVF], [Nodes.dir]];

gateCapacity = 1;

Edges.gate = {'G1-b','b-G1'};
Edges.taxi = {'b-c', 'c-b'};
Edges.TLOF = {'c-R2', 'R2-c'};
Edges.OVF  = {'R2-X', 'X-R2'};
Edges.dir  = {'X-N', 'N-X','X-E','E-X', 'X-W','W-X'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];

flight_path_nodes_arr={
{'N','X','R2','c','b','G1'};
{'E','X','R2','c','b','G1'};
{'W','X','R2','c','b','G1'};
};

flight_path_nodes_dep={
{'G1','b','c','R2','X','N'};
{'G1','b','c','R2','X','E'};
{'G1','b','c','R2','X','W'};
};

flight_path_edges_dep={
{'G1-b','b-c','c-R2','R2-X','X-N'};
{'G1-b','b-c','c-R2','R2-X','X-E'};
{'G1-b','b-c','c-R2','R2-X','X-W'};
};


flight_path_edges_arr={
{'N-X','X-R2','R2-c','c-b','b-G1'};
{'E-X','X-R2','R2-c','c-b','b-G1'};
{'W-X','X-R2','R2-c','c-b','b-G1'};
};
