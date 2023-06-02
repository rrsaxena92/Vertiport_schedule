clear
startTime = datetime; fprintf("Start time %s \n", startTime);
rng(26)
seedUsed = rng;
saveFile = 1;
num_flight = 5;
fairness_enable = 0;
P = 0.15;
GateNode = 0;

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

%From gate to TLOF
edge_length_before_TLOF = 3*d5;
max_edge_taxi_speed = 6;


vertical_climb_edge_length_above_TLOF=5*d5; %From TLOF pad to point X

max_vertical_climb_speed = 8; % 20km/hr is 6m/s which is max speed on taxiways and max vertical climb speed

inclination_climb_edge_length = 20*d5; %From point X to fixed direction
maxSlantClimbSpeed = 17;
%D is separation distance on taxi where rows are leading and columns are following
D_sep_taxi = [d1 d2 d3 d4 d5; d2 d2 d3 d4 d5; d3 d3 d3 d4 d5; d4 d4 d4 d4 d5; d5 d5 d5 d5 d5];

D_sep_fix = 15*D_sep_taxi;
% disp(D);

s = max_edge_taxi_speed;

%T is time seperation based on wake vortex in seconds
% disp("Wake vortex time seperation ");
Twake = [d1/s d2/s d3/s d4/s d5/s; d2/s d2/s d3/s d4/s d5/s; d3/s d3/s d3/s d4/s d5/s; d4/s d4/s d4/s d4/s d5/s; d5/s d5/s d5/s d5/s d5/s];
% disp(ceil(T));

% Table for separation distance on fix direction (same for climb and approach)

m=ceil(Twake(5,5)); % 60km/hr is 17m/s which is max speed on fixed direction link
m1=3*m;
FDT=(inclination_climb_edge_length/m1);
% speed table for seperation
FT=[(FDT/5) (2*FDT/5) (3*FDT/5) (4*FDT/5) (FDT);2*FDT/5 2*FDT/5 3*FDT/5 4*FDT/5 FDT;3*FDT/5 3*FDT/5 3*FDT/5 4*FDT/5 FDT;4*FDT/5 4*FDT/5 4*FDT/5 4*FDT/5 FDT;FDT FDT FDT FDT FDT];
F=Twake.*FT;
% disp(ceil(F));

cooling_time=[2 4 6 8 10];


global Edges Nodes flight_path_nodes flight_path_edges flight_class operator descentDelay
topo_1_dep_dir_4

Edges.len  = [edge_length_before_TLOF, vertical_climb_edge_length_above_TLOF, inclination_climb_edge_length];
descentDelay = 20;
%% FLight set

flight_class = {'Small','Medium','Jumbo','Super','Ultra'}; % Should be equal to value inside UAM_class function
operator = {'xx','zz','yy','ww','tt','mm','nn','rr'};

flight_set_struct = struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'coolTime', []);


flight_req_time = randi(60,[num_flight,1]);

flight_set(num_flight,1) = flight_set_struct;
arr_flight_set = [];
dep_flight_set = [];

for f = 1:num_flight
    q = randi(length(flight_class));
    x = randi(length(flight_path_nodes));
    o = randi(length(operator));
    n = flight_path_nodes{x};

    if num_flight > 1
        flight.name = string(flight_class(q)) + '-' + string(operator(o))+'-'+f;
    else
        flight.name = {'Super-xx-1'};
    end

    flight.reqTime = flight_req_time(f);
    flight.nodes = flight_path_nodes{x};
    flight.edges = flight_path_edges{x};
    flight.taxi_speed=max_edge_taxi_speed;
    flight.vertical_climb_speed=max_vertical_climb_speed;
    flight.slant_climb_speed = maxSlantClimbSpeed;
    flight.class = UAM_class(flight);
    flight.coolTime = cooling_time(flight.class);

    if flight_type(flight, Nodes) == "dep"
        flight.TLOF = string(n{length(n)-2});
        flight.fix_direction = string(n{length(n)});
        flight.direction = "dep";
        dep_flight_set = [dep_flight_set, flight];
    elseif flight_type(flight, Nodes) == "arr"
        flight.TLOF = string(n{3});
        flight.fix_direction = string(n{1});
        flight.direction = "arr";
        arr_flight_set = [arr_flight_set flight];
    else
        fprintf("Invalid path of flight %s number %d", flight.name, f);
    end

    flight_set(f) = flight;

end

flight_name_set = [flight_set.name];
if ~isempty(arr_flight_set)
    arr_name_set = [arr_flight_set.name];
    extraDelay = 12;
    if length(arr_name_set) == 1
        arr_name_set = {arr_name_set{:}};
    end
    % Loop over the 'arr' flights and check reqTime for same 'fix_direction'
    all_time_diff_met = false;
    while ~all_time_diff_met
        all_time_diff_met = true; % Assume that all flights meet the time diff requirement

        for f1 = 1:length(arr_flight_set)
            for f2 = 1:length(arr_flight_set)
                if f1 ~= f2
                    if strcmp(arr_flight_set(f1).fix_direction, arr_flight_set(f2).fix_direction)
                        % Calculate time difference between reqTime values
                        time_diff = abs(arr_flight_set(f1).reqTime - arr_flight_set(f2).reqTime);
                        req_time_diff = D_sep_fix(flight_set(f1).class, flight_set(f2).class) / maxSlantClimbSpeed + extraDelay;
                        if 0 < round(req_time_diff - time_diff,2)
                            % Add time difference to the flight with higher reqTime value
                            if arr_flight_set(f2).reqTime  > arr_flight_set(f1).reqTime
                                arr_flight_set(f2).reqTime = arr_flight_set(f2).reqTime + (req_time_diff - time_diff);
                                i = find(flight_name_set == arr_flight_set(f2).name);
                                flight_set(i).reqTime = arr_flight_set(f2).reqTime;
                            else
                                arr_flight_set(f1).reqTime = arr_flight_set(f1).reqTime + (req_time_diff - time_diff);
                                i = find(flight_name_set == arr_flight_set(f1).name);
                                flight_set(i).reqTime = arr_flight_set(f1).reqTime;
                            end

                            all_time_diff_met = false;
                        end
                    end
                end
            end
        end
    end
else
    arr_name_set = {' '};
end

if ~isempty(dep_flight_set)
    dep_name_set = [dep_flight_set.name];
    if length(dep_name_set) == 1
        dep_name_set = {dep_name_set{:}};
    end
else
    dep_name_set = {' '};
end

% id = [6 4];
% tmp = flight_set(id);
% clear flight_set
% flight_set = tmp;
% flight_name_set = [flight_set.name];
% tmp = arr_flight_set(id);
% clear arr_flight_set
% arr_flight_set = tmp;
% arr_name_set = [arr_flight_set.name];
% num_flight = length(flight_set);

flight_0 = struct('name',"0-0-0",'reqTime',0,'direction',[],'nodes',{Nodes.all},'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[],'class',[],'coolTime',[]);
a0 = flight_0.name;
flight_set_0 = [flight_0 ; flight_set];
flight_name_set_0 = [flight_0.name , flight_set.name];
fprintf("Num flights %d, dep %d arr %d \n", num_flight, length(dep_flight_set), length(arr_flight_set))
%% Parameters

W_r  = 10;  % Weight for time spent on TLOF after landing
W_q  = 10;  % Weight for time spent on TLOF before takeoff
Wa_c = 7;  % Weight for time spent on fix direction by arrival flight
Wd_c = 7;  % Weight for time spent on fix direction by departure flight
W_g  = 2;  % Weight for time spent waiting on gate by departure flight
Wa_t = 8; % Weight for time spent waiting on taxiing by arrival flight
Wd_t = 8; % Weight for time spent waiting on taxiing by departure flight

global M
M = ceil(num_flight/10 +1)*400; % Till 10 flights its 400, till 20 flights its 800, till 30 flihts its 1200

inputs.Twake = Twake;
inputs.Edges = Edges;
inputs.Nodes = Nodes;
%% Optimsation problem

vertiOpt = optimproblem;

% Decision variables

t_iu  = optimvar('t_iu', flight_name_set, Nodes.all, 'LowerBound',0);
y_uij = optimvar('y_uij', Nodes.all, [flight_set_0.name], [flight_set_0.name], 'LowerBound',0,'UpperBound',1, 'Type','integer');

% Arrivals
vertiIn = optimexpr(1,arr_name_set);

for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    r = arr_flight_set(f).TLOF;
    vertiIn(i) = t_iu(i,r) - arr_flight_set(f).reqTime;
end

Qapproach = Wa_c*sum(vertiIn);

taxiTimeArr = optimexpr(1,arr_name_set);

for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    ui1 = arr_flight_set(f).nodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    uiki = arr_flight_set(f).nodes(end); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    taxiTimeArr(i) = t_iu(i,uiki) - t_iu(i,ui1);
end

QtaxiTimeArr = Wa_t*sum(taxiTimeArr);

Landtime = optimexpr(1,arr_name_set);
for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    ui1 = arr_flight_set(f).nodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    r = arr_flight_set(f).TLOF;
    Landtime(i) = t_iu(i,ui1) - t_iu(i,r);
end

QLand = W_r*sum(Landtime);

taxiout = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).nodes(1);
    taxiout(i) = t_iu(i,g) - dep_flight_set(f).reqTime;
end

Qtaxiout = W_g*sum(taxiout);

taxiTimeDep = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).nodes(1);
    uiki = dep_flight_set(f).nodes(end-3); % Last node, LaunchpadNode, Climb_a, Climb_b
    taxiTimeDep(i) = t_iu(i,uiki) - t_iu(i,g);
end

QtaxiTimeDep = Wd_t*sum(taxiTimeDep);

takeOfftime = optimexpr(1,dep_name_set);
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    uiki = dep_flight_set(f).nodes(end-3); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    r = dep_flight_set(f).TLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    takeOfftime(i) = t_iu(i,r) - t_iu(i,uiki);
end

QtakeOff = W_q*sum(takeOfftime);

climbTime = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    r = dep_flight_set(f).TLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    cb = dep_flight_set(f).fix_direction;
    climbTime(i) = t_iu(i,cb) - t_iu(i,r);
end

QClimb = Wd_c*sum(climbTime);

vertiOpt.Objective = (Qapproach + QLand + QtaxiTimeArr + Qtaxiout + QtaxiTimeDep + QtakeOff + QClimb)/10;

%% Constraints
fprintf("Formulating constraints.....");

% ARAPR_i Arr C1
vertiOpt.Constraints.ARAPR_i = optimconstr(arr_name_set);
for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    cb = arr_flight_set(f).nodes(1);
    vertiOpt.Constraints.ARAPR_i(i) = t_iu(i,cb) == arr_flight_set(f).reqTime;
end

fprintf(" 0.1 ");


% Gate out C2

vertiOpt.Constraints.gateOutC1 = optimconstr(dep_name_set);
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).nodes(1);
    vertiOpt.Constraints.gateOutC1(i) = t_iu(i,g) >= dep_flight_set(f).reqTime;
end

fprintf(" 0.2 ");

% Taxiing speed constraints C5 & C6
[vertiOpt.Constraints.minspeed ,vertiOpt.Constraints.maxspeed] =  SpeedConstr(Edges, flight_set, M, t_iu);
fprintf(" 1 ");

% Deifinition of y^u_ij C9-C16

[vertiOpt.Constraints.ytime1,vertiOpt.Constraints.ytime2,vertiOpt.Constraints.ytime3] = YtimeConstr(Nodes.all, flight_set, t_iu, y_uij, M, a0);

fprintf(" 2 ");

[vertiOpt.Constraints.y2,vertiOpt.Constraints.y3,vertiOpt.Constraints.y4,vertiOpt.Constraints.y5] = y2to5Constr(Nodes.all,flight_set,y_uij,a0);

fprintf(" 3 ");

vertiOpt.Constraints.y7 = y7Constr(Nodes.all,flight_set,y_uij);

fprintf(" 4 ");

% Overtake C18

vertiOpt.Constraints.Overtake = overtakeConstr(flight_set,Edges,y_uij);

fprintf(" 5 ");

% Collission C19

vertiOpt.Constraints.Collison = collisonConstr(string([Edges.taxi,Edges.dir]), flight_set, y_uij);

fprintf(" 6 ");

% Taxi & climb separation C20

vertiOpt.Constraints.taxiSeparation1 = taxiseparationConstr(string(Edges.taxi), flight_set, D_sep_taxi, y_uij, t_iu, M);
vertiOpt.Constraints.fixSeparation1  = fixseparationConstr(string(Edges.dir), flight_set, D_sep_fix, y_uij, t_iu, M);

fprintf(" 7 ");

if ~isempty(arr_flight_set)
    % TLOF pad exit C21

    vertiOpt.Constraints.TLOFexitArr = optimconstr(arr_name_set);
    for f = 1:length(arr_flight_set)
        i = arr_flight_set(f).name;
        r = arr_flight_set(f).TLOF;
        ui1 = arr_flight_set(f).nodes(4);% Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
        Ticool = arr_flight_set(f).coolTime;
        vertiOpt.Constraints.TLOFexitArr(i) = t_iu(i,ui1) >= t_iu(i,r) + Ticool;
    end

    fprintf(" 8 ");


    % land approach Arr C26.2

    vertiOpt.Constraints.TLOFClearArr = TLOFClearArrConstr(arr_flight_set, y_uij, t_iu);

    fprintf(" 9 ");
end

if ~isempty(dep_flight_set)

    % TLOF pad entrance C21.1
    vertiOpt.Constraints.TLOFenterDep = TLOFenterDepConstr(dep_flight_set, t_iu);

    fprintf(" 10 ");

    % takeOff climb C26.1

    vertiOpt.Constraints.TLOFenter2Dep = TLOFenter2DepConstr(dep_flight_set, t_iu, y_uij);
    fprintf(" 11 ");
end

% Wake vortex separation C22

vertiOpt.Constraints.wake = wakeConstr(flight_set, t_iu, y_uij,Twake);

fprintf(" 14 ");

% Fairness constraints

if fairness_enable
    vertiOpt.Constraints.fairness = optimconstr(dep_name_set);

    if GateNode
        limit = (1+P) * ((sum(arrayfun(@(x) t_iu(x.name, x.nodes(1)) - x.reqTime, dep_flight_set)))/length(dep_flight_set));
    else
        limit = (1+P) * ((sum(arrayfun(@(x) t_iu(x.name, x.nodes(end)) - x.reqTime, dep_flight_set)))/length(dep_flight_set));
    end

    for f = 1:length(dep_flight_set)
        i = dep_flight_set(f).name;
        if GateNode
            g = dep_flight_set(f).nodes(1);
            zeroTime = 0;
        else
            g = dep_flight_set(f).nodes(end);
            zeroTime = 0;
        end
        vertiOpt.Constraints.fairness(i) = t_iu(i, g) - dep_flight_set(f).reqTime - zeroTime<= limit;
    end
    fprintf(" 15 ");
end

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
    flight_sol = validateOptSol(vertiOpt_sol, flight_set_0, inputs);
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
    filename = "seed_" + num2str(num_flight) + '_' + datefmt + ".mat";
    filePath = folder + "//" + filename;
    save(filePath,'seedUsed');
    if isempty(flight_sol)
        strctTbl = struct2table(flight_set);
        filename = "flight_set_" + num2str(num_flight) + '_' + datefmt;
        ext = ".csv";
        filePath = folder + "//" + filename + ext;
        writetable(strctTbl,filePath,'Delimiter',',');
    else
        strctTbl = struct2table(flight_sol.flight_sol_set);
        filename = "flight_sol_" + num2str(num_flight) + '_' + datefmt;
        ext = ".csv";
        filePath = folder + "//" + filename+ ext;
        writetable(strctTbl,filePath,'Delimiter',',');
    end

end

fprintf("Formulation Time %s Solver time %s \n", Formulationtime, Solveruntime);
%% Functions
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
        if ismember(u,Nodes.dir)
            delay = descentDelay;
        else
            delay = 0;
        end
        MinEdgeT_uv = max(timeonedge(flight_set(f),tmpEdges{e}, Edges.len) - 5,0); % TODO Different speed
        MaxEdgeT_uv = min(timeonedge(flight_set(f),tmpEdges{e}, Edges.len) + 5 + delay,M); % TODO Different speed
        minspeed(i,tmpEdges(e)) = t_iu(i,v) >= t_iu(i,u) + MinEdgeT_uv;
        maxspeed(i,tmpEdges(e)) = t_iu(i,v) <= t_iu(i,u) + MaxEdgeT_uv;
    end
end
end




function flight_dir = flight_type(flight,nodes)
n=flight.nodes;
if(ismember(string(n(length(flight.nodes))),nodes.dir))
    flight_dir = "dep"; % Departure
elseif (ismember(string(n(length(flight.nodes))),nodes.gates))
    flight_dir = "arr"; % Arrival
else
    flight_dir = 'null';
end
end

function t = timeonedge(flight,edge,edgeLen)

n=split(edge,'-',1);
x=string(n(1));
y=string(n(2));
if flight.direction == "dep"
    if(x == flight.TLOF)
        t=(edgeLen(2)/flight.vertical_climb_speed);
    elseif (y == flight.fix_direction)
        t=(edgeLen(3)/flight.slant_climb_speed);
    else
        t=(edgeLen(1)/flight.taxi_speed);
    end
elseif flight.direction == "arr"
    if(y == flight.TLOF)
        t=(edgeLen(2)/flight.vertical_climb_speed);
    elseif (x == flight.fix_direction)
        t=(edgeLen(3)/flight.slant_climb_speed);
    else
        t=(edgeLen(1)/flight.taxi_speed);
    end
else
    fprintf("Wrong flight direction for flight %s \n", flight.name);
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
if ismember(e, [[Edges.gate],[Edges.taxi],[Edges.TLOF]])
    len = Edges.len(1);
elseif ismember(e, Edges.OVF)
    len = Edges.len(2);
elseif ismember(e,Edges.dir)
    len = Edges.len(3);
else
    fprintf(" edge not found %s \n", e{:});
end
end

function timetaken = zeroDelayTime(flight)

timeOnTaxi = 0;
if flight.direction == "arr"
    timeOnapproach = (get_edge_length(flight.edges(1))/flight.slant_climb_speed)-5;
    timeOnOVF = (get_edge_length(flight.edges(2))/flight.vertical_climb_speed)-5;

    for e = 4:(length(flight.edges)) % Last taxi node to TLOF not counted
        timeOnTaxi = timeOnTaxi + (get_edge_length(flight.edges(e))/flight.taxi_speed)-5;
    end
    timetaken = [timeOnTaxi, timeOnOVF, timeOnapproach];

else % dep
    for e = 1:(length(flight.edges)-3) % Last taxi node to TLOF not counted
        timeOnTaxi = max(timeOnTaxi + (get_edge_length(flight.edges(e))/flight.taxi_speed) - 5,0);
    end

    timeOnOVF = max((get_edge_length(flight.edges(end-1))/flight.vertical_climb_speed) - 5,0);
    timeOnclimb = max((get_edge_length(flight.edges(end))/flight.slant_climb_speed) - 5,0);
    timetaken = [timeOnTaxi, timeOnOVF, timeOnclimb];
end

end
%% Constraints
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
    for f2 = (f1+1):length(flight_set)
        j = flight_set(f2).name;
        common_nodes = intersect(flight_set(f1).nodes,flight_set(f2).nodes);
        y7(common_nodes,i,j) = y_uij(common_nodes,i,j) + y_uij(common_nodes,j,i) == 1;

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
            %             commonEdges = intersect(intersect(flight_set(f1).edges, Edges),intersect(flight_set(f2).edges,pivot_string(Edges,'-')));
            %             edges = commonEdges(:);
            %             edges_split = cellfun(@(e) split(e, '-'), edges, 'UniformOutput', false);
            %             u = cellfun(@(e) e{1}, edges_split, 'UniformOutput', false);
            %             v = cellfun(@(e) e{2}, edges_split, 'UniformOutput', false);
            %             Collision(edges,i,j) = y_uij(u,i,j) - y_uij(v,i,j) == 0;

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


function TLOFClearArr = TLOFClearArrConstr(arr_flight_set,y_uij, t_iu)
global M
arr_name_set = [arr_flight_set.name];
TLOFClearArr = optimconstr(arr_name_set, arr_name_set);
for f1 = 1:length(arr_flight_set)
    i = arr_flight_set(f1).name;
    r1 = arr_flight_set(f1).TLOF;
    for f2 = 1:length(arr_flight_set)
        j = arr_flight_set(f2).name;
        r2 = arr_flight_set(f2).TLOF;
        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = arr_flight_set(f2).nodes(2); % According to j flight's plan
            ui1 = arr_flight_set(f2).nodes(4); % according to i flight's path % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
            TLOFClearArr(i,j) = t_iu(j,ca) >= t_iu(i,ui1) - (1-y_uij(r,i,j))*M;
        end
    end
end
end

function TLOFenterDep = TLOFenterDepConstr(dep_flight_set, t_iu)

dep_name_set = [dep_flight_set.name];
TLOFenterDep = optimconstr(dep_name_set);
uiki = cellfun(@(d) string(d(end-3)), {dep_flight_set.nodes});
r = [dep_flight_set.TLOF];
constr = arrayfun(@(i,r,u) t_iu(i,r) >= t_iu(i,u), dep_name_set, r, uiki, 'UniformOutput', false);
TLOFenterDep(dep_name_set) = [constr{:}];

end


function wakeVortex = wakeConstr(flight_set, t_iu, y_uij,Twake)

global M
flight_name_set = [flight_set.name];
wakeVortex = optimconstr(flight_name_set,flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    r1 = flight_set(f1).TLOF;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        r2 = flight_set(f2).TLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            Rsepij = Twake(flight_set(f1).class, flight_set(f2).class);
            wakeVortex(i,j) = t_iu(j,r) >= t_iu(i,r) + Rsepij - (1-y_uij(r,i,j))*M;
        end
    end
end

% [I,J] = ndgrid(1:length(flight_set),1:length(flight_set));
% idx = I~=J; % Index of all unique combinations of i and j
%
% flight_i = flight_set; % All unique flights in i
% flight_j = flight_set; % All unique flights in j
%
% % Get the class of the flight and calculate Rsepij
% class_i = [flight_i.class];
% class_j = [flight_j.class];
% Rsepij = Twake(class_i, class_j);
%
% % Get the TLOF of the flights
% r_i = [flight_i.TLOF];
% r_j = [flight_j.TLOF];
%
% % Check if the TLOF of the two flights are equal
% is_same_r = r_i == r_j;
%
% % Get the names of the flights
% name_i = [flight_i.name];
% name_j = [flight_j.name];
%
% % Form the constraint
% wakeVortex(is_same_r) = t_iu(name_j(is_same_r),r_j(is_same_r)) >= t_iu(name_i(is_same_r),r_i(is_same_r)) + Rsepij(is_same_r) - (1-x_uij(r_i(is_same_r),name_i(is_same_r),name_j(is_same_r)))*M;

% [f1, f2] = ndgrid(1:length(flight_set));
% idx = find(f1 ~= f2 & strcmp({flight_set(f1).TLOF}, {flight_set(f2).TLOF}));
% i = {flight_set(f1(idx)).name};
% j = {flight_set(f2(idx)).name};
% r = {flight_set(f1(idx)).TLOF};
% Rsepij = arrayfun(@(k) Twake(flight_set(f1(idx(k))).class, flight_set(f2(idx(k))).class), 1:numel(idx));
% wakeVortex(i,j) = t_iu(j,r) >= t_iu(i,r) + Rsepij - (1-x_uij(r,i,j))*M;
end

function TLOFenter2Dep = TLOFenter2DepConstr(dep_flight_set, t_iu, y_uij)

global M
dep_name_set = [dep_flight_set.name];
TLOFenter2Dep = optimconstr(dep_name_set, dep_name_set);
for f1 = 1:length(dep_flight_set)
    i = dep_flight_set(f1).name;
    r1 = dep_flight_set(f1).TLOF;
    for f2 = 1:length(dep_flight_set)
        j = dep_flight_set(f2).name;
        r2 = dep_flight_set(f2).TLOF;
        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = dep_flight_set(f1).nodes(end-1); % According to i flight's plan..,Last node, LaunchpadNode, Climb_a, Climb_b
            TLOFenter2Dep(i,j) = t_iu(j,r) >= t_iu(i,ca) - (1-y_uij(r,i,j))*M;
        end
    end
end

end


function TLOFpadSingle = TLOFpadSingleConstr(arr_flight_set, dep_flight_set, t_iu, y_uij)

global M
flight_name_set = [[arr_flight_set.name] , [dep_flight_set.name]];
TLOFpadSingle = optimconstr(flight_name_set, flight_name_set);
for f1 = 1:length(arr_flight_set)
    i = arr_flight_set(f1).name;
    r1 = arr_flight_set(f1).TLOF;
    ex = arr_flight_set(f1).nodes(4); % TLOF pad exit node
    for f2 = 1:length(dep_flight_set)
        j = dep_flight_set(f2).name;
        r2 = dep_flight_set(f2).TLOF;
        en = dep_flight_set(f2).nodes(end-3); % TLOF pad entrance node
        if (r1 == r2)
            r = r1;
            TLOFpadSingle(i,j) = t_iu(j,en) >= t_iu(i,ex) - (1-y_uij(r,i,j))*M;
        end
    end
end

end