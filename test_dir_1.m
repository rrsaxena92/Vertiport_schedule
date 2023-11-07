
% Nodes.gates = {'G1','G2','G3','G4'};
% Nodes.taxi  = {'a','b','c','d','e','f','g','h', 'i'};
% Nodes.TLOF  = {'R1', 'R2'};
% Nodes.OVF   = {'X','Y'};
% Nodes.dir   = {'N','E','W','S'};
% Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];
% 
% Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'g-G4', 'e-G2', 'd-G1', 'f-G3'};
% Edges.taxi = {'a-b','b-c','i-f', 'f-g', 'h-d', 'd-e'};
% Edges.TLOF = {'c-R2', 'R1-i', 'R1-h'};
% Edges.OVF  = {'R2-X', 'Y-R1'};
% Edges.dir  = {'X-N','X-E', 'W-Y', 'S-Y'};
% Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];

% Nodes.gates = {'G1','G2','G3','G4'};
% Nodes.taxi  = {'a','b','c'};
% Nodes.TLOF  = {'R2'};
% Nodes.OVF   = {'X'};
% Nodes.dir   = {'N','E'};
% Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];
% 
% Edges.gate = {'G1-a','G3-a','G2-b','G4-b'};
% Edges.taxi = {'a-b','b-c'};
% Edges.TLOF = {'c-R2'};
% Edges.OVF  = {'R2-X'};
% Edges.dir  = {'X-N', 'X-E'};
% Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];
% 
% flight_path_nodes={
%     {'G1','a','b','c','R2','X','N'},{'G1','a','b','c','R2','X','E'},{'G3','a','b','c','R2','X','N'},{'G3','a','b','c','R2','X','E'},{'G2','b','c','R2','X','N'},{'G2','b','c','R2','X','E'},{'G4','b','c','R2','X','N'},{'G4','b','c','R2','X','E'}, ...
% %     {'W','Y','R1','i','f','G3'},{'W','Y','R1','i','f','g','G4'},{'W','Y','R1','h','d','G1'},{'W','Y','R1','h','d','e','G2'},{'S','Y','R1','i','f','G3'},{'S','Y','R1','i','f','g','G4'},{'S','Y','R1','h','d','G1'},{'S','Y','R1','h','d','e','G2'}...
%     };
% 
% flight_path_edges={
%     {'G1-a','a-b','b-c','c-R2','R2-X','X-N'},{'G1-a','a-b','b-c','c-R2','R2-X','X-E'},{'G3-a','a-b','b-c','c-R2','R2-X','X-N'},{'G3-a','a-b','b-c','c-R2','R2-X','X-E'},{'G2-b','b-c','c-R2','R2-X','X-N'},{'G2-b','b-c','c-R2','R2-X','X-E'},{'G4-b','b-c','c-R2','R2-X','X-N'},{'G4-b','b-c','c-R2','R2-X','X-E'},...
% %     {'W-Y','Y-R1','R1-i','i-f','f-G3'},{'W-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'W-Y','Y-R1','R1-h','h-d','d-G1'},{'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'},{'S-Y','Y-R1','R1-i','i-f','f-G3'},{'S-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'S-Y','Y-R1','R1-h','h-d','d-G1'},{'S-Y','Y-R1','R1-h', 'h-d', 'd-e','e-G2'}...
%     };


% 
% flight_path_nodes = {
%     {'S', 'Y','R1','h','d','G1'};
% %     {'G2','b','c','R2','X','E'};
%     {'W', 'Y','R1','h','d','e','G2'};
% %     {'G2','b','c','R2','X','E'};
%     {'W', 'Y','R1','h','d','e','G2'}
%     };
% flight_path_edges = {
%     {'S-Y','Y-R1','R1-h','h-d', 'd-G1'};
% %     {'G2-b','b-c','c-R2','R2-X','X-E'};
%     {'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'};
% %     {'G2-b','b-c','c-R2','R2-X','X-E'};
%     {'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'}
%     };
% 
% flight_class = {
%     'Super';
% %     'Medium';
%     'Small';
% %     'Medium';
%     'Jumbo'
%     };
% 
% flight_req_time = [7,17,14];

% flight_path_nodes = {
% {'G4','b','c','R2','X','E'}
% {'G4','b','c','R2','X','E'}
% {'G2','b','c','R2','X','N'}
% {'G2','b','c','R2','X','N'}
% {'G1','a','b','c','R2','X','E'}
% {'G1','a','b','c','R2','X','N'}
% {'G4','b','c','R2','X','E'}
% {'G1','a','b','c','R2','X','E'}
% {'G2','b','c','R2','X','E'}
% {'G4','b','c','R2','X','N'}
% {'G3','a','b','c','R2','X','N'}
% {'G4','b','c','R2','X','N'}
% {'G4','b','c','R2','X','E'}
% {'G3','a','b','c','R2','X','N'}
% {'G3','a','b','c','R2','X','N'}
% };
% 
% 
% flight_path_edges = {
%     {'G4-b','b-c','c-R2','R2-X','X-E'}
% {'G4-b','b-c','c-R2','R2-X','X-E'}
% {'G2-b','b-c','c-R2','R2-X','X-N'}
% {'G2-b','b-c','c-R2','R2-X','X-N'}
% {'G1-a','a-b','b-c','c-R2','R2-X','X-E'}
% {'G1-a','a-b','b-c','c-R2','R2-X','X-N'}
% {'G4-b','b-c','c-R2','R2-X','X-E'}
% {'G1-a','a-b','b-c','c-R2','R2-X','X-E'}
% {'G2-b','b-c','c-R2','R2-X','X-E'}
% {'G4-b','b-c','c-R2','R2-X','X-N'}
% {'G3-a','a-b','b-c','c-R2','R2-X','X-N'}
% {'G4-b','b-c','c-R2','R2-X','X-N'}
% {'G4-b','b-c','c-R2','R2-X','X-E'}
% {'G3-a','a-b','b-c','c-R2','R2-X','X-N'}
% {'G3-a','a-b','b-c','c-R2','R2-X','X-N'}
% };






% flight_class = {'Super'};
% flight_class = {
% 'Ultra'	
% 'Super'	
% 'Small'	
% 'Super'	
% 'Small'	
% 'Jumbo'	
% 'Medium'
% 'Medium'
% 'Jumbo'	
% 'Ultra'	
% 'Jumbo'	
% 'Ultra'	
% 'Jumbo'	
% 'Ultra'	
% 'Medium'
% };



% operator = {
% 'xx'
% 'rr'
% 'rr'
% 'mm'
% 'nn'
% 'tt'
% 'rr'
% 'tt'
% 'mm'
% 'zz'
% 'nn'
% 'zz'
% 'zz'
% 'mm'
% 'nn'
% };

% flight_req_time = [11,12,12,17,17,17,19,30,32,33,45,46,47,48,53];

% Nodes.gates = {'G3', 'G4'};
% Nodes.taxi  = {'i','f','g'};
% Nodes.TLOF  = {'R1'};
% Nodes.OVF   = {'Y'};
% Nodes.dir   = {'S','W'};
% Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];
% 
% Edges.gate = {'g-G4','f-G3'};
% Edges.taxi = {'i-f','f-g'};
% Edges.TLOF = {'R1-i'};
% Edges.OVF  = {'Y-R1'};
% Edges.dir  = {'S-Y', 'W-Y'};
% Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];
% 
% flight_path_nodes={
% {'W','Y','R1','i','f','g','G4'}
%  {'W','Y','R1','i','f','G3'}
% };
% 
% flight_path_edges={
%     {'W-Y','Y-R1','R1-i','i-f','f-g','g-G4'}
%     {'W-Y','Y-R1','R1-i','i-f','f-G3'}
% };

% Nodes.gates = {'G1','G2','G3','G4'};
% Nodes.taxi  = {'a','b','c'};
% Nodes.TLOF  = {'R2'};
% Nodes.OVF   = {'X'};
% Nodes.dir   = {'N'};
% Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];
% 
% Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'a-G1', 'a-G3', 'b-G2', 'b-G4'};
% Edges.taxi = {'a-b','b-c', 'b-a', 'c-b'};
% Edges.TLOF = {'c-R2', 'R2-c'};
% Edges.OVF  = {'R2-X', 'X-R2'};
% Edges.dir  = {'X-N', 'N-X'};
% Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];
% 
% flight_path_nodes={
% % {'G1','a','b','c','R2','X','N'};
% % {'N','X','R2','c','b','a','G1'};
% % {'G3','a','b','c','R2','X','N'};
% {'N','X','R2','c','b','a','G3'};
% % {'G2','b','c','R2','X','N'};
% % {'N','X','R2','c','b','G2'};
% {'G4','b','c','R2','X','N'};
% % {'N','X','R2','c','b','G4'};
% };
% 
% flight_path_edges={
% % {'G1-a','a-b','b-c','c-R2','R2-X','X-N'};
% % {'N-X','X-R2','R2-c','c-b','b-a','a-G1'};
% % {'G3-a','a-b','b-c','c-R2','R2-X','X-N'};
% {'N-X','X-R2','R2-c','c-b','b-a','a-G3'};
% % {'G2-b','b-c','c-R2','R2-X','X-N'};
% % {'N-X','X-R2','R2-c','c-b','b-G2'};
% {'G4-b','b-c','c-R2','R2-X','X-N'};
% % {'N-X','X-R2','R2-c','c-b','b-G4'};
% };

Nodes.gates = {'G1'};
Nodes.taxi  = {'b','c'};
Nodes.TLOF  = {'R2'};
Nodes.OVF   = {'X'};
Nodes.dir   = {'N'};
Nodes.gateC = {'G1c0','G1c1'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.gateC], [Nodes.OVF], [Nodes.dir]];

gateCapacity = 1;

Edges.gate = {'G1-b','b-G1'};
Edges.taxi = {'b-c', 'c-b'};
Edges.TLOF = {'c-R2', 'R2-c'};
Edges.OVF  = {'R2-X', 'X-R2'};
Edges.dir  = {'X-N', 'N-X'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];

flight_path_nodes_arr={
{'N','X','R2','c','b','G1'};
};

flight_path_nodes_dep={
{'G1','b','c','R2','X','N'};
};

flight_path_edges_dep={
{'G1-b','b-c','c-R2','R2-X','X-N'};
};


flight_path_edges_arr={
{'N-X','X-R2','R2-c','c-b','b-G1'};
};
