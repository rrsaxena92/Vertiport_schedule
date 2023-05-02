clear
startTime = datetime; fprintf("Start time %s \n", startTime);
rng(26)
seedUsed = rng;
saveFile = 0;
if saveFile
    fprintf("File is going to be saved \n");
else
    fprintf("File NOT going to be saved \n");
end
%% Vertiport graph
d1 = 5;  %input("Enter the diagonal length of the Group 1 UAV in m");
d2 = 8;  %input("Enter the diagonal length of the Group 2 UAV in m");
d3 = 10; %input("Enter the diagonal length of the Group 3 UAV in m");
d4 = 12; %input("Enter the diagonal length of the Group 4 UAV in m");
d5 = 15; %input("Enter the diagonal length of the Group 5 UAV in m");


gate_edge_len = 2*d5;
edge_length_before_TLOF = 3*d5; %From gate to TLOF

edge_taxi_speed = 6;


vertical_climb_edge_length_above_TLOF=5*d5; %From TLOF pad to point X

vertical_climb_speed = 8; % 20km/hr is 6m/s which is speed on taxiways and vertical climb speed

inclination_climb_edge_length = 20*d5; %From point X to fixed direction
SlantClimbSpeed = 17;
%D is separation distance on taxi where rows are leading and columns are following
D_sep_taxi = [d1 d2 d3 d4 d5; d2 d2 d3 d4 d5; d3 d3 d3 d4 d5; d4 d4 d4 d4 d5; d5 d5 d5 d5 d5];

D_sep_fix = 15*D_sep_taxi;
% disp(D);

s = edge_taxi_speed;

%T is time seperation based on wake vortex in seconds
% disp("Wake vortex time seperation ");
Twake = [d1/s d2/s d3/s d4/s d5/s; d2/s d2/s d3/s d4/s d5/s; d3/s d3/s d3/s d4/s d5/s; d4/s d4/s d4/s d4/s d5/s; d5/s d5/s d5/s d5/s d5/s];
% disp(ceil(T));

% Table for separation distance on fix direction (same for climb and approach)

m=ceil(Twake(5,5)); % 60km/hr is 17m/s which is speed on fixed direction link
m1=3*m;
FDT=(inclination_climb_edge_length/m1);
% speed table for seperation
FT=[(FDT/5) (2*FDT/5) (3*FDT/5) (4*FDT/5) (FDT);2*FDT/5 2*FDT/5 3*FDT/5 4*FDT/5 FDT;3*FDT/5 3*FDT/5 3*FDT/5 4*FDT/5 FDT;4*FDT/5 4*FDT/5 4*FDT/5 4*FDT/5 FDT;FDT FDT FDT FDT FDT];
F=Twake.*FT;
% disp(ceil(F));

cooling_time=[2 4 6 8 10];
TAT = [90, 120, 150, 210, 300];

global Edges Nodes  flight_class operator descentDelay % flight_path_nodes flight_path_edges

topo_1_arr_dep_dir_1

Edges.len  = [gate_edge_len, edge_length_before_TLOF, vertical_climb_edge_length_above_TLOF, inclination_climb_edge_length];

%% FLight set

flight_class = {'Small','Medium','Jumbo','Super','Ultra'}; % Should be equal to value inside UAM_class function
operator = {'xx','zz','yy','ww','tt','mm','nn','rr'};

flight_set_struct = struct('name',[],'ArrReqTime',[],'DepReqTime',[],'ArrNodes',[],'ArrEdges', ...
    [],'ArrTLOF',[],'ArrFix_direction',[],'DepNodes',[],'DepEdges',[],'DepTLOF',[],'DepFix_direction', ...
    [],'gate',[], 'gateV', [], 'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'coolTime', [], 'TAT',[], 'nodes',[],'edges',[]);

num_flight = 5;
flight_req_time = randi(60,[num_flight,1])*10 + randi(10,[num_flight,1]);

flight_set(num_flight,1) = flight_set_struct;

for f = 1:num_flight
    q = randi(length(flight_class));
    x = randi(length(flight_path_nodes_arr));
    o = randi(length(operator));
    na = flight_path_nodes_arr{x};
    nd = flight_path_nodes_dep{x};

    if num_flight > 1
        flight.name = string(flight_class(q)) + '-' + string(operator(o))+'-'+f;
    else
        flight.name = {'Super-xx-1'};
    end

    flight.ArrReqTime = flight_req_time(f);
    flight.ArrNodes = flight_path_nodes_arr{x};
    flight.ArrEdges = flight_path_edges_arr{x};
    flight.ArrTLOF  = string(na{3});
    flight.ArrFix_direction = string(na{1});

    flight.gate = Nodes.gates{strcmp(flight.ArrNodes{end},Nodes.gatesEn)};
    flight.gateV = arrayfun(@(x) [flight.gate, 'c',num2str(x)], 0:gateCapacity, 'UniformOutput', false);

    flight.DepNodes = flight_path_nodes_dep{x};
    flight.DepEdges = flight_path_edges_dep{x};
    flight.DepTLOF  = string(nd{length(nd)-2});
    flight.DepFix_direction = string(nd{length(nd)});

    flight.taxi_speed = edge_taxi_speed;
    flight.vertical_climb_speed = vertical_climb_speed;
    flight.slant_climb_speed = SlantClimbSpeed;
    flight.class = UAM_class(flight);
    flight.coolTime = cooling_time(flight.class);
    flight.TAT = TAT(flight.class);

    flight.DepReqTime = calcDepReqTime(flight);

    flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
    flight.edges = union(flight.ArrEdges, flight.DepEdges);

    flight_set(f) = flight;

end

flight_name_set = [flight_set.name];

extraDelay = 12;

all_time_diff_met = false;
while ~all_time_diff_met
    all_time_diff_met = true; % Assume that all flights meet the time diff requirement

    for f1 = 1:length(flight_set)
        for f2 = 1:length(flight_set)
            if f1 ~= f2
                if strcmp(flight_set(f1).ArrFix_direction, flight_set(f2).ArrFix_direction)
                    % Calculate time difference between ArrReqTime values
                    time_diff = abs(flight_set(f1).ArrReqTime - flight_set(f2).ArrReqTime);
                    req_time_diff = D_sep_fix(flight_set(f1).class, flight_set(f2).class) / SlantClimbSpeed + extraDelay;
                    if 0 < round(req_time_diff - time_diff,2)
                        % Add time difference to the flight with higher ArrReqTime value
                        if flight_set(f2).ArrReqTime  > flight_set(f1).ArrReqTime
                            flight_set(f2).ArrReqTime = flight_set(f2).ArrReqTime + (req_time_diff - time_diff);
                            i = find(flight_name_set == flight_set(f2).name);
                            flight_set(i).ArrReqTime = flight_set(f2).ArrReqTime;
                        else
                            flight_set(f1).ArrReqTime = flight_set(f1).ArrReqTime + (req_time_diff - time_diff);
                            i = find(flight_name_set == flight_set(f1).name);
                            flight_set(i).ArrReqTime = flight_set(f1).ArrReqTime;
                        end
                        all_time_diff_met = false;
                    end
                end
            end
        end
    end
end




flight_0 = struct('name',"0-0-0",'ArrReqTime',0,'DepReqTime',0,'ArrNodes',{Nodes.all},'ArrEdges', ...
    [],'ArrTLOF',[],'ArrFix_direction',[],'DepNodes',[],'DepEdges',[],'DepTLOF',[],'DepFix_direction', ...
    [],'gate',[],'gateV', [], 'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'coolTime', [], 'TAT',[], 'nodes',[],'edges',[]);
a0 = flight_0.name;
flight_set_0 = [flight_0 ; flight_set];
flight_name_set_0 = [flight_0.name , flight_set.name];
fprintf("Num flights %d \n", num_flight)

%% Parameters

W_r  = 10;  % Weight for time spent on TLOF after landing
W_qg = 1;  % Weight for time spent on the GATE Q
W_qr = 10; % Weight for time spent on TLOF before takeoff
Wa_c = 7;  % Weight for time spent on fix direction by arrival flight
Wd_c = 7;  % Weight for time spent on fix direction by departure flight
W_g  = 2;  % Weight for time spent waiting on gate by departure flight
Wa_t = 8; % Weight for time spent waiting on taxiing by departure flight
Wd_t = 8; % Weight for time spent waiting on taxiing by arrival flight

global M
M = ceil(num_flight/10)*2000; % Till 10 flights its 2000, till 20 flights its 4000, till 30 flihts its 6000

inputs.Twake = Twake;
inputs.Edges = Edges;
inputs.Nodes = Nodes;
inputs.gateCap = gateCapacity;
%% Optimsation problem

vertiOpt = optimproblem;

% Decision variables

t_iu  = optimvar('t_iu', flight_name_set, Nodes.all, 'LowerBound',0);
y_uij = optimvar('y_uij', Nodes.all, [flight_set_0.name], [flight_set_0.name], 'LowerBound',0,'UpperBound',1, 'Type','integer');

% Arrivals
vertiIn = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    r = flight_set(f).ArrTLOF;
    vertiIn(i) = t_iu(i,r) - flight_set(f).ArrReqTime;
end

Wapproach = Wa_c*sum(vertiIn);

taxiTimeArr = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    ui1 = flight_set(f).ArrNodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    uiki = flight_set(f).ArrNodes(end); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    taxiTimeArr(i) = t_iu(i,uiki) - t_iu(i,ui1);
end

WtaxiTimeArr = Wa_t*sum(taxiTimeArr);

Landtime = optimexpr(1,flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    ui1 = flight_set(f).ArrNodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    r = flight_set(f).ArrTLOF;
    Landtime(i) = t_iu(i,ui1) - t_iu(i,r);
end

WLand = W_r*sum(Landtime);

gateQ = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    Gent = flight_set(f).ArrNodes(end);
    Gext = flight_set(f).DepNodes(1);
    gateQ(i) = t_iu(i,Gext) - t_iu(i,Gent);
end

Wtime = W_qg*sum(gateQ);

% Departures
taxiout = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    g = flight_set(f).DepNodes(1);
    taxiout(i) = t_iu(i,g) - flight_set(f).DepReqTime;
end

Wtaxiout = W_g*sum(taxiout);

taxiTimeDep = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    g = flight_set(f).DepNodes(1);
    uiki = flight_set(f).DepNodes(end-3); % Last node, LaunchpadNode, Climb_a, Climb_b
    taxiTimeDep(i) = t_iu(i,uiki) - t_iu(i,g);
end

WtaxiTimeDep = Wd_t*sum(taxiTimeDep);



climbTime = optimexpr(1,flight_name_set);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    r = flight_set(f).DepTLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    cb = flight_set(f).DepFix_direction;
    climbTime(i) = t_iu(i,cb) - t_iu(i,r);
end

WClimb = Wd_c*sum(climbTime);

takeOfftime = optimexpr(1,flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    uiki = flight_set(f).DepNodes(end-3); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    r = flight_set(f).DepTLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    takeOfftime(i) = t_iu(i,r) - t_iu(i,uiki);
end

WtakeOff = W_qr*sum(takeOfftime);

vertiOpt.Objective = (Wapproach + WLand + WtaxiTimeArr + Wtaxiout + Wtime + WtaxiTimeDep + WtakeOff + WClimb)/10;

%% Constraints
fprintf("Formulating constraints.....");

% ARAPR_i Arr C1
vertiOpt.Constraints.ARAPR_i = optimconstr(flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    cb = flight_set(f).ArrNodes(1);
    vertiOpt.Constraints.ARAPR_i(i) = t_iu(i,cb) == flight_set(f).ArrReqTime;
end

fprintf(" 0.1 ");


% Gate out C2

vertiOpt.Constraints.gateOutC1 = optimconstr(flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    g = flight_set(f).DepNodes(1);
    vertiOpt.Constraints.gateOutC1(i) = t_iu(i,g) >= flight_set(f).DepReqTime;
end

fprintf(" 0.2 ");

% Taxiing speed constraints C5 & C6
[vertiOpt.Constraints.minspeed ,vertiOpt.Constraints.maxspeed] =  SpeedConstr(Edges, flight_set, M, t_iu);
fprintf(" 1 ");

% Turnaround time TAT C7
vertiOpt.Constraints.TAT = optimconstr(flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    gen = flight_set(f).ArrNodes(end);
    gex = flight_set(f).DepNodes(1);
    vertiOpt.Constraints.TAT(i) = t_iu(i,gex) - t_iu(i,gen) >= flight_set(f).TAT;
end
fprintf(" 1.1 ");



% Deifinition of y^u_ij C9-C16

[vertiOpt.Constraints.ytime1,vertiOpt.Constraints.ytime2,vertiOpt.Constraints.ytime3] = YtimeConstr(setdiff(Nodes.all,Nodes.gates), flight_set, t_iu, y_uij, M, a0);

fprintf(" 2 ");

[vertiOpt.Constraints.y2,vertiOpt.Constraints.y3,vertiOpt.Constraints.y4,vertiOpt.Constraints.y5] = y2to5Constr(setdiff(Nodes.all,Nodes.gates),flight_set,y_uij,a0);

fprintf(" 3 ");

vertiOpt.Constraints.y7 = y7Constr(setdiff(Nodes.all,Nodes.gates),flight_set,y_uij);

fprintf(" 4 ");

% Overtake C18

vertiOpt.Constraints.Overtake = overtakeConstr(flight_set,Edges,y_uij);

fprintf(" 5 ");

% Collission C19

vertiOpt.Constraints.Collison = collisonConstr(string([Edges.taxi,Edges.dir]), flight_set, y_uij);

fprintf(" 6 ");

% Taxi & climb separation C20

vertiOpt.Constraints.taxiSeparation1 = taxiseparationConstr(string(union(Edges.taxi,Edges.gate)), flight_set, D_sep_taxi, y_uij, t_iu, M);
vertiOpt.Constraints.fixSeparation1  = fixseparationConstr(string(Edges.dir), flight_set, D_sep_fix, y_uij, t_iu, M);

fprintf(" 7 ");


% TLOF pad exit C21

vertiOpt.Constraints.TLOFexitArr = optimconstr(flight_name_set);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    r = flight_set(f).ArrTLOF;
    ui1 = flight_set(f).ArrNodes(4);% Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    Ticool = flight_set(f).coolTime;
    vertiOpt.Constraints.TLOFexitArr(i) = t_iu(i,ui1) >= t_iu(i,r) + Ticool;
end

fprintf(" 8 ");


% land approach Arr C26.2

vertiOpt.Constraints.TLOFClearArr = TLOFClearArrConstr(flight_set, y_uij, t_iu);

fprintf(" 9 ");


% TLOF pad entrance C21.1
vertiOpt.Constraints.TLOFenterDep = TLOFenterDepConstr(flight_set, t_iu);

fprintf(" 10 ");

% takeOff climb C26.1

vertiOpt.Constraints.TLOFenter2Dep = TLOFenter2DepConstr(flight_set, t_iu, y_uij);
fprintf(" 11 ");


% Wake vortex separation C22

vertiOpt.Constraints.wake = wakeConstr(flight_set, t_iu, y_uij,Twake);

fprintf(" 12 ");


% Conitinuity for gate entry exit and Q 
vertiOpt.Constraints.GateQ = optimconstr(flight_name_set,2);
for f = 1:length(flight_set)
    i = flight_set(f).name;
    gen = flight_set(f).ArrNodes(end);
    gex = flight_set(f).DepNodes(1);   
    g0  = strcat(flight_set(f).gate,'c',string(0));
    gcg = strcat(flight_set(f).gate,'c',string(gateCapacity));
    vertiOpt.Constraints.GateQ(i,1) = t_iu(i,gen) == t_iu(i,g0);
    vertiOpt.Constraints.GateQ(i,2) = t_iu(i,gex) == t_iu(i,gcg);
end

fprintf(" 13.1 ");
% Next slot time Qorder C17
vertiOpt.Constraints.Qorder = optimconstr(flight_name_set, gateCapacity);

for f = 1:length(flight_set)
    i = flight_set(f).name;
    for k = 0:(gateCapacity-1)
        gk = strcat(flight_set(f).gate,'c',string(k));
        gk1 = strcat(flight_set(f).gate,'c',string(k+1));
        vertiOpt.Constraints.Qorder(i,k+1) = t_iu(i,gk1) >= t_iu(i,gk);
    end
end

fprintf(" 13.2 ");

% FCFS order on gate  FCFS C17.1
vertiOpt.Constraints.FCFS = optimconstr(gateCapacity+1, flight_name_set,flight_name_set);
for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    g1 = flight_set(f1).ArrNodes(end);
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        g2 = flight_set(f2).ArrNodes(end);
        g = intersect(g1,g2);
        if (f1~=f2) && ~isempty(g)
            for k = 0:(gateCapacity-1)
                gk = strcat(flight_set(f1).gate,'c',string(k));
                gk1 = strcat(flight_set(f1).gate,'c',string(k+1));
                vertiOpt.Constraints.FCFS(k+1,i,j) = t_iu(j,gk) >= t_iu(i,gk1) - (1-y_uij(g,i,j))*M;
            end
        end
    end
end

fprintf(" 13.3 ");

fprintf(" \n ");
endTime = datetime;
fprintf(" End Time %s \n", endTime);
Formulationtime = endTime - startTime;
%% Problem solving

x0.t_iu  = zeros(length(flight_set), length(Nodes.all));
x0.y_uij = zeros(length(Nodes.all), length(flight_set_0), length(flight_set_0));

startTime = datetime; fprintf("Start time %s \n", startTime);
vertiOpt_sol = solve(vertiOpt, x0);
endTime = datetime;
fprintf(" End Time %s \n", endTime);
Solveruntime = endTime - startTime;

%% Result Analysis
if ~isempty(vertiOpt_sol.t_iu)
    %     startTime1 = datetime; fprintf("Start time %s \n", startTime1);
    flight_sol = validateOptSol_AD(vertiOpt_sol, flight_set_0, inputs);
    endTime = datetime;
    %     fprintf(" End Time %s \n", endTime);
    Validateruntime = endTime - startTime;
else
    fprintf(" SOLUTION NOT FOUND \n");
    flight_sol = [];
end
%% The End
if saveFile
    datefmt = datestr(startTime, "YYYY_mm_DD_HH_MM_SS");
    folder = "Results";
    if isempty(flight_sol)
        strctTbl = struct2table(flight_set);
        filename = "flight_set_" + num2str(num_flight) + '_' + datefmt + ".csv";
        filePath = folder + "//" + filename;
        writetable(strctTbl,filePath,'Delimiter',',');
    else
        strctTbl = struct2table(flight_sol.flight_sol_set);
        filename = "flight_sol_" + num2str(num_flight) + '_' + datefmt + ".csv";
        filePath = folder + "//" + filename;
        writetable(strctTbl,filePath,'Delimiter',',');
    end
    filename = "seed_" + num2str(num_flight) + '_' + datefmt + ".mat";
    filePath = folder + "//" + filename;
    save(filePath,'seedUsed');
end

fprintf("Formulation Time %s Solver time %s \n", Formulationtime, Solveruntime);
%% Functions
function t = timeonedge(flight,edge)

global Edges descentDelay

descentDelay = 15;

if ismember(edge,{Edges.dir{:}})

    if ismember(edge,{flight.ArrEdges{:}})
        t = (get_edge_length(edge)/flight.slant_climb_speed) + descentDelay;
    elseif ismember(edge,{flight.DepEdges{:}})
        t = (get_edge_length(edge)/flight.slant_climb_speed);
    else
        fprintf("Wrong edge %s \n", edge);
    end

end

if ismember(edge, {Edges.OVF{:}})
    t = (get_edge_length(edge)/flight.vertical_climb_speed);
end

if ismember(edge, {Edges.taxi{:}})
    t = (get_edge_length(edge)/flight.taxi_speed);
end

if ismember(edge, {Edges.gate{:}})
    t = (get_edge_length(edge)/flight.taxi_speed);
end

end

% function a = is_common_node(flight1,flight2)
% C = intersect(flight1.nodes,flight2.nodes,"stable");
% a =C;
% end

function class = UAM_class(flight)
flight_class = {'Small','Medium','Jumbo','Super','Ultra'};
n=split(flight.name,'-',1);
cat =n(1);
class = find(string(cat)==flight_class,1);
end

function len = get_edge_length(e)
global Edges
if ismember(e, [Edges.gate])%,[Edges.TLOF]])
    len = Edges.len(1);
elseif ismember(e, Edges.taxi)
    len = Edges.len(2);
elseif ismember(e, Edges.OVF)
    len = Edges.len(3);
elseif ismember(e,Edges.dir)
    len = Edges.len(4);
else
    fprintf(" edge not found %s \n", e{:});
end
end

function depTime = calcDepReqTime(flight)

global Edges
edges = flight.ArrEdges; %nodes = flight.ArrNodes;

taxiedges = intersect(edges,Edges.taxi);

fixTime = timeonedge(flight, edges{1});
OVFtime = timeonedge(flight, edges{2});
coolTime = flight.coolTime;

taxiTime = 0;

for e = 1:length(taxiedges)
    taxiTime = taxiTime + timeonedge(flight, taxiedges{e});
end

TAT = flight.TAT;

Qdelay = 10;

depTime = fixTime + OVFtime + coolTime + taxiTime + TAT + Qdelay;

end
%% Constraints Functions
function [minspeed, maxspeed] =  SpeedConstr(Edges, flight_set, M, t_iu)
global descentDelay Nodes
flight_name_set = [flight_set.name];
minspeed = optimconstr(flight_name_set, setdiff(Edges.all,Edges.TLOF));
maxspeed = optimconstr(flight_name_set, setdiff(Edges.all,Edges.TLOF));

for f = 1:length(flight_set)
    i = flight_set(f).name;
    tmpEdges = setdiff(flight_set(f).edges,Edges.TLOF);
    for e = 1:(length(tmpEdges))
        e_ = split(tmpEdges{e},'-');
        u = e_{1}; v = e_{2};
        if ismember(u,Nodes.dir) && ismember(u, flight_set(f).ArrNodes)
            delay = descentDelay;
        else
            delay = 0;
        end
        MinEdgeT_uv = max(timeonedge(flight_set(f),tmpEdges{e}) - 5,1); % TODO Different speed
        MaxEdgeT_uv = min(timeonedge(flight_set(f),tmpEdges{e}) + 5 + delay,M); % TODO Different speed
        minspeed(i,tmpEdges(e)) = t_iu(i,v) >= t_iu(i,u) + MinEdgeT_uv;
        maxspeed(i,tmpEdges(e)) = t_iu(i,v) <= t_iu(i,u) + MaxEdgeT_uv;
    end
end
end


function [ytime1,ytime2,ytime3] = YtimeConstr(Nodes, flight_set, t_iu, y_uij, M, a0)
flight_name_set = [flight_set.name];
ytime1 = optimconstr(Nodes, flight_name_set, flight_name_set);
ytime2 = optimconstr(Nodes, flight_name_set, flight_name_set);
ytime3 = optimconstr(Nodes, flight_name_set, flight_name_set);

% for n = 1:length(Nodes)
%     u = Nodes(n);
for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;

        % common_node = any(ismember(flight_set(f1).nodes,u)) & any(ismember(flight_set(f2).nodes,u));
        if (f1 ~= f2)
            common_nodes = intersect(flight_set(f1).nodes, flight_set(f2).nodes);

            ytime1(common_nodes,i,j) = t_iu(j,common_nodes) >= t_iu(i,common_nodes) - (1-y_uij(common_nodes,i,j))'*M;
            ytime2(common_nodes,i,j) = t_iu(i,common_nodes) >= t_iu(j,common_nodes) - (1-y_uij(common_nodes,a0,j))'*M;
            ytime3(common_nodes,i,j) = t_iu(i,common_nodes) >= t_iu(j,common_nodes) - (1-y_uij(common_nodes,i,a0))'*M;
        end
    end
end
% end
end

function [y2,y3,y4,y5] = y2to5Constr(Nodes,flight_set,y_uij,a0)

flight_name_set = [flight_set.name];
y2 = optimconstr(Nodes, flight_name_set, flight_name_set);
y3 = optimconstr(Nodes, flight_name_set, flight_name_set);
y4 = optimconstr(Nodes, flight_name_set, flight_name_set);
y5 = optimconstr(Nodes, flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        if (f1 ~= f2)
            common_nodes = intersect(flight_set(f1).nodes,flight_set(f2).nodes);
            y2(common_nodes,i,j) = y_uij(common_nodes,j,i) >= y_uij(common_nodes,a0,j);
            y3(common_nodes,i,j) = y_uij(common_nodes,a0, j) + y_uij(common_nodes,i,j) <=  1;
            y4(common_nodes,i,j) = y_uij(common_nodes,j,i) >= y_uij(common_nodes,i,a0);
            y5(common_nodes,i,j) = y_uij(common_nodes,i,a0) + y_uij(common_nodes,i,j) <= 1;
        end
    end
end

end

function y7 = y7Constr(Nodes,flight_set,y_uij)

flight_name_set = [flight_set.name];
y7 = optimconstr(Nodes, flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        if (f1 ~= f2)
            common_nodes = intersect(flight_set(f1).nodes,flight_set(f2).nodes);
            y7(common_nodes,i,j) = y_uij(common_nodes,i,j) + y_uij(common_nodes,j,i) == 1;
        end
    end
end

end

function Overtake = overtakeConstr(flight_set,Edges,y_uij)

flight_name_set = [flight_set.name];
Overtake = optimconstr(string([Edges.taxi,Edges.dir]), flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            commonEdges =  setdiff(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), [Edges.gate, Edges.OVF]);
            edges = commonEdges(:);
            edges_split = cellfun(@(e) split(e, '-'), edges, 'UniformOutput', false);
            u = cellfun(@(e) e{1}, edges_split, 'UniformOutput', false);
            v = cellfun(@(e) e{2}, edges_split, 'UniformOutput', false);
            Overtake(edges, i, j) = y_uij(u, i, j) - y_uij(v, i, j) == 0;
        end
    end
end

end


function Collision = collisonConstr(Edges, flight_set, y_uij)

flight_name_set = [flight_set.name];
Collision = optimconstr(Edges, flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            for e1 = 1:length(Edges)
                e = Edges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                er = [v  '-'  u];
                commonEdge = any(ismember(Edges{e1},flight_set(f1).edges) & ismember(flight_set(f2).edges,er));
                if commonEdge
                    Collision(e,i,j) = y_uij(u,i,j) - y_uij(v,i,j) == 0;
                end
            end
        end
    end
end
end

function taxiSeparation1 = taxiseparationConstr(Edges, flight_set, D_sep_taxi, y_uij, t_iu, M)

flight_name_set = [flight_set.name];
taxiSeparation1 = optimconstr({Edges{:}}, flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        if f1 ~= f2
            Dsep_ij = D_sep_taxi(flight_set(f1).class, flight_set(f2).class);
            commonEdges =  intersect(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), Edges,"stable");
            for e1 = 1:length(commonEdges)
                e = commonEdges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                D_uv = get_edge_length(commonEdges{e1});
                taxiSeparation1(e,i,j) = t_iu(j,u) >= t_iu(i,u) + (Dsep_ij/D_uv)*(t_iu(i,v) - t_iu(i,u)) - (1-y_uij(u,i,j))*M;
            end
        end
    end
end
end

function fixSeparation1 = fixseparationConstr(Edges, flight_set, D_sep_fix, y_uij, t_iu, M)

flight_name_set = [flight_set.name];
fixSeparation1 = optimconstr({Edges{:}}, flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        if f1 ~= f2
            commonEdges =  intersect(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), Edges,"stable");
            for e1 = 1:length(commonEdges)
                e = commonEdges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                D_uv = get_edge_length(commonEdges{e1});
                Dsep_ij = D_sep_fix(flight_set(f1).class, flight_set(f2).class);
                fixSeparation1(e,i,j) = t_iu(j,u) >= t_iu(i,u) + (Dsep_ij/D_uv)*(t_iu(i,v) - t_iu(i,u)) - (1-y_uij(u,i,j))*M;
            end
        end
    end
end
end


function TLOFClearArr = TLOFClearArrConstr(flight_set,y_uij, t_iu)
global M
flight_name_set = [flight_set.name];

TLOFClearArr = optimconstr(flight_name_set, flight_name_set);
for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    r1 = flight_set(f1).ArrTLOF;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        r2 = flight_set(f2).ArrTLOF;
        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = flight_set(f2).ArrNodes(2); % According to j flight's plan
            ui1 = flight_set(f2).ArrNodes(4); % according to i flight's path % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
            TLOFClearArr(i,j) = t_iu(j,ca) >= t_iu(i,ui1) - (1-y_uij(r,i,j))*M;
        end
    end
end
end

function TLOFenterDep = TLOFenterDepConstr(flight_set, t_iu)

flight_name_set = [flight_set.name];
TLOFenterDep = optimconstr(flight_name_set);
uiki = cellfun(@(d) string(d(end-3)), {flight_set.DepNodes});
r = [flight_set.DepTLOF];
constr = arrayfun(@(i,r,u) t_iu(i,r) >= t_iu(i,u), flight_name_set, r, uiki, 'UniformOutput', false);
TLOFenterDep(flight_name_set) = [constr{:}];

end


function wakeVortex = wakeConstr(flight_set, t_iu, y_uij,Twake)

global M Nodes
flight_name_set = [flight_set.name];
wakeVortex = optimconstr(Nodes.TLOF, flight_name_set,flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    r1 = union(flight_set(f1).ArrTLOF, flight_set(f1).DepTLOF);
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        r2 = union(flight_set(f2).ArrTLOF, flight_set(f2).DepTLOF);
        r = intersect(r1,r2);
        if (f1 ~= f2) && ~isempty(r)
            Rsepij = Twake(flight_set(f1).class, flight_set(f2).class);
            wakeVortex(r, i,j) = t_iu(j,r) >= t_iu(i,r) + Rsepij - (1-reshape(y_uij(r,i,j),[1,2]))*M;
        end
    end
end

end

function TLOFenter2Dep = TLOFenter2DepConstr(flight_set, t_iu, y_uij)

global M
flight_name_set = [flight_set.name];
TLOFenter2Dep = optimconstr(flight_name_set, flight_name_set);
for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    r1 = flight_set(f1).DepTLOF;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        r2 = flight_set(f2).DepTLOF;
        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = flight_set(f1).DepNodes(end-1); % According to i flight's plan..,Last node, LaunchpadNode, Climb_a, Climb_b
            TLOFenter2Dep(i,j) = t_iu(j,r) >= t_iu(i,ca) - (1-y_uij(r,i,j))*M;
        end
    end
end

end
