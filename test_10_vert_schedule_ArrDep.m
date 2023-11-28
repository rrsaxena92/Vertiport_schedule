clear
startTime = datetime; fprintf("Start time %s \n", startTime);
rng(26)
seedUsed = rng;

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


vertical_climb_edge_length_above_TLOF = 5*d5; %From TLOF pad to point X

vertical_climb_speed = 8; % 20km/hr is 6m/s which is speed on taxiways and vertical climb speed

inclination_climb_edge_length = 20*d5; %From point X to fixed direction
SlantClimbSpeed = 17;
%D is separation distance on taxi where rows are leading and columns are following
D_sep_taxi = [d1 d2 d3 d4 d5; d2 d2 d3 d4 d5; d3 d3 d3 d4 d5; d4 d4 d4 d4 d5; d5 d5 d5 d5 d5];

D_sep_fix = 15*D_sep_taxi;

s = edge_taxi_speed;

%T is time seperation based on wake vortex in seconds

Twake = [d1/s d2/s d3/s d4/s d5/s; d2/s d2/s d3/s d4/s d5/s; d3/s d3/s d3/s d4/s d5/s; d4/s d4/s d4/s d4/s d5/s; d5/s d5/s d5/s d5/s d5/s];

% Table for separation distance on fix direction (same for climb and approach)

m=ceil(Twake(5,5)); % 60km/hr is 17m/s which is speed on fixed direction link
m1=3*m;
FDT=(inclination_climb_edge_length/m1);
% speed table for seperation
FT=[(FDT/5) (2*FDT/5) (3*FDT/5) (4*FDT/5) (FDT);2*FDT/5 2*FDT/5 3*FDT/5 4*FDT/5 FDT;3*FDT/5 3*FDT/5 3*FDT/5 4*FDT/5 FDT;4*FDT/5 4*FDT/5 4*FDT/5 4*FDT/5 FDT;FDT FDT FDT FDT FDT];
F=Twake.*FT;

TOT = [2 4 6 8 10];
TAT = [90, 120, 150, 210, 300];

global Edges Nodes  flight_class operator descentDelay Qdelay% flight_path_nodes flight_path_edges

topo_1_arr_dep_dir_4
gateCapacity = 1;

Edges.len  = [gate_edge_len, edge_length_before_TLOF, vertical_climb_edge_length_above_TLOF, inclination_climb_edge_length];
descentDelay = 0;
Qdelay = 0;
extraDelayArr = 2.5; %12
diffDirtimeSep = 7; % According to Small t_XR + tot = 6.375s
%% FLight set

operator = {'xx','zz','yy','ww','tt','mm','nn','rr'};

flight_set_struct = struct('name',[],'type', [],'ArrReqTime',[],'DepReqTime',[],'ArrNodes',[],'ArrEdges', ...
    [],'ArrTLOF',[],'ArrFix_direction',[],'DepNodes',[],'DepEdges',[],'DepTLOF',[],'DepFix_direction', ...
    [],'Gate',[], 'gateV', [], 'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'TOT', [], 'TAT',[], 'nodes',[],'edges',[]);


flight_req_time = randi(60,[num_flight,1])*10 + randi(10,[num_flight,1]);

flight_set = []; % flight_set(num_flight,1) = flight_set_struct;


arr_flight_set = [];
dep_flight_set = [];
tat_flight_set = [];
for f = 1:num_flight
    q = randi(length(flight_class));
    o = randi(length(operator));

    if num_flight > 1
        flight.name = string(flight_class(q)) + '-' + string(operator(o))+'-'+f;
    else
        flight.name = {'Small-xx-1'};
    end

    flight.taxi_speed = edge_taxi_speed;
    flight.vertical_climb_speed = vertical_climb_speed;
    flight.slant_climb_speed = SlantClimbSpeed;
    flight.class = UAM_class(flight);
    flight.TOT = TOT(flight.class);
    flight.TAT = TAT(flight.class);

    flight.type = flight_set_type(randi(length(flight_set_type))); % Randomly choosing direction

    if flight.type == "dep"
        x = randi(length(flight_path_nodes_dep));
        n = flight_path_nodes_dep{x};
        flight.DepReqTime =  flight_req_time(f);
        flight.DepNodes = n;
        flight.DepEdges = flight_path_edges_dep{x};
        flight.Gate = flight.DepNodes{1};%Nodes.gates{strcmp(flight.DepNodes{1},Nodes.gatesEx)};
        flight.DepTLOF  = string(n{length(n)-2});
        flight.DepFix_direction = string(n{length(n)});

        flight.ArrReqTime = [];
        flight.ArrNodes = [];
        flight.ArrEdges = [];
        flight.ArrTLOF  = [];
        flight.ArrFix_direction = [];
        flight.gateV = [];

        flight.taxi_speed = edge_taxi_speed;
        flight.vertical_climb_speed = vertical_climb_speed;
        flight.slant_climb_speed = SlantClimbSpeed;
        flight.class = UAM_class(flight);
        flight.TOT = TOT(flight.class);
        flight.TAT = TAT(flight.class);

        flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
        flight.edges = union(flight.ArrEdges, flight.DepEdges, 'stable')';

        dep_flight_set = [dep_flight_set, flight];
        flight_set = [flight_set flight];

    elseif flight.type == "arr"
        x = randi(length(flight_path_nodes_arr));
        n = flight_path_nodes_arr{x};

        flight.ArrReqTime = flight_req_time(f);
        flight.ArrNodes = n;
        flight.ArrEdges = flight_path_edges_arr{x};
        flight.ArrTLOF  = string(n{3});
        flight.ArrFix_direction = string(n{1});
        flight.Gate = flight.ArrNodes{end}; %Nodes.gates{strcmp(flight.ArrNodes{end},Nodes.gatesEn)};
        flight.gateV = [];

        flight.DepReqTime =  [];
        flight.DepNodes = [];
        flight.DepEdges = [];
        flight.DepTLOF  = [];
        flight.DepFix_direction = [];

        flight.taxi_speed = edge_taxi_speed;
        flight.vertical_climb_speed = vertical_climb_speed;
        flight.slant_climb_speed = SlantClimbSpeed;
        flight.class = UAM_class(flight);
        flight.TOT = TOT(flight.class);
        flight.TAT = TAT(flight.class);

        flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
        flight.edges = union(flight.ArrEdges, flight.DepEdges, 'stable');

        arr_flight_set = [arr_flight_set flight];
        flight_set = [flight_set flight];

    elseif flight.type == "tat"

        name = flight.name;
        x = randi(length(flight_path_nodes_arr));
        flight.taxi_speed = edge_taxi_speed;
        flight.vertical_climb_speed = vertical_climb_speed;
        flight.slant_climb_speed = SlantClimbSpeed;
        flight.class = UAM_class(flight);
        flight.TOT = TOT(flight.class);
        flight.TAT = TAT(flight.class);

        flight.name = name + "_Arr";
        n = flight_path_nodes_arr{x};

        flight.ArrReqTime = flight_req_time(f);
        flight.ArrNodes = n;
        flight.ArrEdges = flight_path_edges_arr{x};
        flight.ArrTLOF  = string(n{3});
        flight.ArrFix_direction = string(n{1});
        flight.Gate = flight.ArrNodes{end}; %Nodes.gates{strcmp(flight.ArrNodes{end},Nodes.gatesEn)};

        flight.gateV = [];

        flight.DepReqTime = flight.ArrReqTime + calcDepReqTime(flight);
        flight.DepNodes = [];
        flight.DepEdges = [];
        flight.DepTLOF  = [];
        flight.DepFix_direction = [];

        flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
        flight.edges = union(flight.ArrEdges, flight.DepEdges, 'stable')';

        arr_flight_set = [arr_flight_set flight];
        flight_set = [flight_set flight];

        flight.name = name + "_Dep";
        n = flight_path_nodes_dep{x};
        flight.gateV = [];

        flight.DepNodes = n;
        flight.DepEdges = flight_path_edges_dep{x};

        flight.DepTLOF  = string(n{length(n)-2});
        flight.DepFix_direction = string(n{length(n)});

        flight.ArrNodes = [];
        flight.ArrEdges = [];
        flight.ArrTLOF  = [];
        flight.ArrFix_direction = [];

        flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
        flight.edges = union(flight.ArrEdges, flight.DepEdges, 'stable')';

        dep_flight_set = [dep_flight_set, flight];
        flight_set = [flight_set flight];

        flight.name = name;
        n = flight_path_nodes_arr{x};
        flight.ArrNodes = [];%flight_path_nodes_arr{x};
        flight.ArrEdges = [];%flight_path_edges_arr{x};
        flight.ArrTLOF  = string(n{3});
        flight.ArrFix_direction = string(n{1});

        flight.gateV = arrayfun(@(x) [flight.Gate, 'c',num2str(x)], 0:gateCapacity, 'UniformOutput', false);

        flight.DepNodes = [];%flight_path_nodes_dep{x};
        flight.DepEdges = [];%flight_path_edges_dep{x};
        n = flight_path_nodes_dep{x};
        flight.DepTLOF  = string(n{length(n)-2});
        flight.DepFix_direction = string(n{length(n)});

        flight.nodes = [[flight.ArrNodes],[flight.gateV] ,[flight.DepNodes]];
        flight.edges = union(flight.ArrEdges, flight.DepEdges, 'stable');

        tat_flight_set = [tat_flight_set flight];
        flight_set = [flight_set flight];

    else
        fprintf("Invalid set of flight %s number %d", flight.type, f);
    end
end

flight_name_set = [flight_set.name];
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
if ~isempty(dep_flight_set)
    dep_name_set = [dep_flight_set.name];
    if length(dep_name_set) == 1
        dep_name_set = {dep_name_set{:}};
    end
else
    dep_name_set = {' '};
end

if ~isempty(arr_flight_set)
    arr_name_set = [arr_flight_set.name];
    if length(arr_name_set) == 1
        arr_name_set = {arr_name_set{:}};
    end
else
    arr_name_set = {' '};
end
if ~isempty(tat_flight_set)
    tat_name_set = [tat_flight_set.name];
    if length(tat_name_set) == 1
        tat_name_set = {tat_name_set{:}};
    end
else
    tat_name_set = {' '};
end
% Keeping the time separtion between the arrivals on same directions
if ~isempty(arr_flight_set)
    % Loop over the 'arr' flights and check reqTime for same 'fix_direction'
    all_time_diff_met = false;
    while ~all_time_diff_met
        all_time_diff_met = true; % Assume that all flights meet the time diff requirement
        for f1 = 1:length(arr_flight_set)
            for f2 = 1:length(arr_flight_set)
                if f1 ~= f2
                    % Calculate time difference between reqTime values
                    time_diff = abs(arr_flight_set(f1).ArrReqTime - arr_flight_set(f2).ArrReqTime);
                    if strcmp(arr_flight_set(f1).ArrFix_direction, arr_flight_set(f2).ArrFix_direction) % On same direction
                        req_time_diff = D_sep_fix(arr_flight_set(f1).class, arr_flight_set(f2).class) / SlantClimbSpeed + extraDelayArr;
                    else % On different direction
                        if diffDirtimeSep == 0 
                            continue % No time separation required on differernt directions
                        end
                        req_time_diff = diffDirtimeSep;
                    end
                    if 0 < round(req_time_diff - time_diff,2)
                        % Add time difference to the flight with higher reqTime value
                        if arr_flight_set(f2).ArrReqTime  > arr_flight_set(f1).ArrReqTime
                            arr_flight_set(f2).ArrReqTime = arr_flight_set(f2).ArrReqTime + (req_time_diff - time_diff);
                            i = find(flight_name_set == arr_flight_set(f2).name);
                            flight_set(i).ArrReqTime = arr_flight_set(f2).ArrReqTime;
                            % Changing the ArrReqTime and DepReqTime in
                            % all the sets
                            if arr_flight_set(f2).type == "tat"
                                name = erase(arr_flight_set(f2).name, "_Arr");
                                i = find(flight_name_set == name);
                                flight_set(i).ArrReqTime = arr_flight_set(f2).ArrReqTime;
                                flight_set(i).DepReqTime = flight_set(i).ArrReqTime + calcDepReqTime(arr_flight_set(f2));
                                j = find(dep_name_set == (name+"_Dep"));
                                dep_flight_set(j).DepReqTime = flight_set(i).DepReqTime;
                                dep_flight_set(j).ArrReqTime = flight_set(i).ArrReqTime;
                                k = find(flight_name_set == (name+"_Dep"));
                                flight_set(k).ArrReqTime = arr_flight_set(f2).ArrReqTime;
                                flight_set(k).DepReqTime = flight_set(i).DepReqTime;
                                l = find(arr_flight_set(f2).name == flight_name_set);
                                flight_set(l).DepReqTime = flight_set(i).DepReqTime;
                            end
                        else
                            arr_flight_set(f1).ArrReqTime = arr_flight_set(f1).ArrReqTime + (req_time_diff - time_diff);
                            i = find(flight_name_set == arr_flight_set(f1).name);
                            flight_set(i).ArrReqTime = arr_flight_set(f1).ArrReqTime;
                            if arr_flight_set(f1).type == "tat"
                                name = erase(arr_flight_set(f1).name, "_Arr");
                                i = find(flight_name_set == name);
                                flight_set(i).ArrReqTime = arr_flight_set(f1).ArrReqTime;
                                flight_set(i).DepReqTime = flight_set(i).ArrReqTime + calcDepReqTime(arr_flight_set(f1));
                                j = find(dep_name_set == (name+"_Dep"));
                                dep_flight_set(j).DepReqTime = flight_set(i).DepReqTime;
                                dep_flight_set(j).ArrReqTime = flight_set(i).ArrReqTime;
                                k = find(flight_name_set == (name+"_Dep"));
                                flight_set(k).ArrReqTime = arr_flight_set(f2).ArrReqTime;
                                flight_set(k).DepReqTime = flight_set(i).DepReqTime;
                                l = find(arr_flight_set(f2).name == flight_name_set);
                                flight_set(l).DepReqTime = flight_set(i).DepReqTime;
                            end
                        end
                        all_time_diff_met = false;
                    end
                end
            end
        end
    end
end


num_flight_tot = length(flight_set);

fprintf("Num flights %d (%d), dep %d (%d) arr %d (%d) tat %d \n", num_flight_tot,num_flight, length(dep_flight_set), (length(dep_flight_set)-length(tat_flight_set)) , length(arr_flight_set),(length(arr_flight_set)-length(tat_flight_set)), length(tat_flight_set))
%% Parameters

W_ar = 10;  % Weight for time spent on TLOF after landing
W_qg = 1;  % Weight for time spent on the GATE Q
W_dr = 10; % Weight for time spent on TLOF before takeoff
Wa_c = 7;  % Weight for time spent on fix direction by arrival flight
Wd_c = 7;  % Weight for time spent on fix direction by departure flight
W_g  = 2;  % Weight for time spent waiting on gate by departure flight
Wa_t = 8; % Weight for time spent waiting on taxiing by departure flight
Wd_t = 8; % Weight for time spent waiting on taxiing by arrival flight

global M
M = ceil(num_flight/10 + 1)*2000; % Till 10 flights its 2000, till 20 flights its 4000, till 30 flihts its 6000

inputs.Twake = Twake;
inputs.Edges = Edges;
inputs.Nodes = Nodes;
inputs.gateCap = gateCapacity;
%% Optimsation problem

vertiOpt = optimproblem;

% Decision variables

t_iu  = optimvar('t_iu', flight_name_set, Nodes.all, 'LowerBound',0);
y_uij = optimvar('y_uij', Nodes.all, [flight_set.name], [flight_set.name], 'LowerBound',0,'UpperBound',1, 'Type','integer');

% Arrivals
vertiIn = optimexpr(1,arr_name_set);

for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    r = arr_flight_set(f).ArrTLOF;
    vertiIn(i) = t_iu(i,r) - arr_flight_set(f).ArrReqTime;
end

Wapproach = Wa_c*sum(vertiIn);

taxiTimeArr = optimexpr(1,arr_name_set);

for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    ui1 = arr_flight_set(f).ArrNodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    uiki = arr_flight_set(f).ArrNodes(end); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    taxiTimeArr(i) = t_iu(i,uiki) - t_iu(i,ui1);
end

WtaxiTimeArr = Wa_t*sum(taxiTimeArr);

Landtime = optimexpr(1,arr_name_set);
for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    ui1 = arr_flight_set(f).ArrNodes(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    r = arr_flight_set(f).ArrTLOF;
    Landtime(i) = t_iu(i,ui1) - t_iu(i,r);
end

WLand = W_ar*sum(Landtime);

% Turn Around
gateQ = optimexpr(1,tat_name_set);

for f = 1:length(tat_flight_set)
    i = tat_flight_set(f).name;
    Gent = tat_flight_set(f).Gate + "c0";
    Gext = tat_flight_set(f).Gate + "c"+string(gateCapacity);
    gateQ(i) = t_iu(i,Gext) - t_iu(i,Gent);
end

Wtime = W_qg*sum(gateQ);

% Departures
taxiout = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).DepNodes(1);
    taxiout(i) = t_iu(i,g) - dep_flight_set(f).DepReqTime;
end

Wtaxiout = W_g*sum(taxiout);

taxiTimeDep = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).DepNodes(1);
    uiki = dep_flight_set(f).DepNodes(end-3); % Last node, LaunchpadNode, Climb_a, Climb_b
    taxiTimeDep(i) = t_iu(i,uiki) - t_iu(i,g);
end

WtaxiTimeDep = Wd_t*sum(taxiTimeDep);

takeOfftime = optimexpr(1,dep_name_set);
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    uiki = dep_flight_set(f).DepNodes(end-3); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    r = dep_flight_set(f).DepTLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    takeOfftime(i) = t_iu(i,r) - t_iu(i,uiki);
end

WtakeOff = W_dr*sum(takeOfftime);

climbTime = optimexpr(1,dep_name_set);

for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    r = dep_flight_set(f).DepTLOF; % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    cb = dep_flight_set(f).DepFix_direction;
    climbTime(i) = t_iu(i,cb) - t_iu(i,r);
end

WClimb = Wd_c*sum(climbTime);

vertiOpt.Objective = (Wapproach + WLand + WtaxiTimeArr + Wtaxiout + Wtime + WtaxiTimeDep + WtakeOff + WClimb)/10;

%% Constraints
fprintf("Formulating constraints.....");

% ARAPR_i Arr C1
vertiOpt.Constraints.ARAPR_i = optimconstr(arr_name_set);
for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    cb = arr_flight_set(f).ArrNodes(1);
    vertiOpt.Constraints.ARAPR_i(i) = t_iu(i,cb) == arr_flight_set(f).ArrReqTime;
end

fprintf(" 0.1 ");


% Gate out C2

vertiOpt.Constraints.gateOutC1 = optimconstr(dep_name_set);
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).DepNodes(1);
    vertiOpt.Constraints.gateOutC1(i) = t_iu(i,g) >= dep_flight_set(f).DepReqTime;
end

fprintf(" 0.2 ");

% Taxiing speed constraints C5 & C6
[vertiOpt.Constraints.minspeed ,vertiOpt.Constraints.maxspeed] =  SpeedConstr(Edges, [arr_flight_set, dep_flight_set], M, t_iu);
fprintf(" 1 ");

% Turnaround time TAT C7
vertiOpt.Constraints.TAT = optimconstr(tat_name_set);
for f = 1:length(tat_flight_set)
    i = tat_flight_set(f).name;
    gen = tat_flight_set(f).Gate + "c0";% tat_flight_set(f).ArrNodes(end);
    gex = tat_flight_set(f).Gate + "c"+string(gateCapacity); %tat_flight_set(f).DepNodes(1);
    vertiOpt.Constraints.TAT(i) = t_iu(i,gex) - t_iu(i,gen) >= tat_flight_set(f).TAT;
end
fprintf(" 1.1 ");

% Deifinition of y^u_ij C9-C16

vertiOpt.Constraints.ytime = YtimeConstr(setdiff(Nodes.all,Nodes.gates), flight_set, t_iu, y_uij, M);

fprintf(" 2 ");

vertiOpt.Constraints.y7 = y7Constr(setdiff(Nodes.all,Nodes.gates),flight_set,y_uij);

fprintf(" 3 ");

% Overtake C18

vertiOpt.Constraints.Overtake = overtakeConstr([arr_flight_set,dep_flight_set],Edges,y_uij);

fprintf(" 4 ");

% Collission C19

vertiOpt.Constraints.Collison = collisonConstr(string(Edges.all), [arr_flight_set,dep_flight_set], y_uij);

fprintf(" 5 ");

% Taxi & climb separation C20

vertiOpt.Constraints.taxiSeparation1 = taxiseparationConstr(string(union(Edges.taxi,Edges.gate)), [arr_flight_set,dep_flight_set], D_sep_taxi, y_uij, t_iu, M);
vertiOpt.Constraints.fixSeparation1  = fixseparationConstr(string(Edges.dir), [arr_flight_set,dep_flight_set], D_sep_fix, y_uij, t_iu, M);

fprintf(" 6 ");

if ~isempty(arr_flight_set)
    % TLOF pad exit C21

    vertiOpt.Constraints.TLOFexitArr = optimconstr(arr_name_set);
    for f = 1:length(arr_flight_set)
        i = arr_flight_set(f).name;
        r = arr_flight_set(f).ArrTLOF;
        ui1 = arr_flight_set(f).ArrNodes(4);% Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
        TOTi = arr_flight_set(f).TOT;
        vertiOpt.Constraints.TLOFexitArr(i) = t_iu(i,ui1) >= t_iu(i,r) + TOTi;
    end

    fprintf(" 7 ");

    % land approach Arr C26.2

    vertiOpt.Constraints.TLOFClearArr = TLOFClearArrConstr(arr_flight_set, y_uij, t_iu);

    fprintf(" 8 ");
end

if ~isempty(dep_flight_set)

    % TLOF pad entrance C21.1
    vertiOpt.Constraints.TLOFenterDep = TLOFenterDepConstr(dep_flight_set, t_iu);

    fprintf(" 9 ");

    % takeOff climb C26.1

    vertiOpt.Constraints.TLOFenter2Dep = TLOFenter2DepConstr(dep_flight_set, t_iu, y_uij);
    fprintf(" 10 ");
end

% Wake vortex separation C22

vertiOpt.Constraints.wake = wakeConstr([arr_flight_set,dep_flight_set], t_iu, y_uij,Twake);

fprintf(" 11 ");
% Single occupancy of TLOF pad
if ~isempty(arr_flight_set) && ~isempty(dep_flight_set)
    vertiOpt.Constraints.TLOFpadSingle = TLOFpadSingleConstr(arr_flight_set, dep_flight_set, t_iu, y_uij);
end
fprintf(" 12.1 ")
if ~isempty(tat_flight_set)

    % Conitinuity for gate entry exit and Q
    vertiOpt.Constraints.GateQ = GateQconstr1(tat_flight_set, arr_flight_set, dep_flight_set, t_iu);
    fprintf(" 13.1 ");
    [vertiOpt.Constraints.GateQ_gen, vertiOpt.Constraints.GateQ_gex] = GateQconstr2(tat_flight_set, arr_flight_set, dep_flight_set, y_uij);

    fprintf(" 13.2 ");

    [GateCapacity1, GateCapacity2] = GateCapacityConstr(tat_flight_set,t_iu, y_uij);

    fprintf(" 13.3 ");
end

fprintf(" \n ");
endTime = datetime;
fprintf(" End Time %s \n", endTime);
Formulationtime = endTime - startTime;
%% Problem solving

x0.t_iu  = zeros(length(flight_set), length(Nodes.all));
x0.y_uij = zeros(length(Nodes.all), length(flight_set), length(flight_set));
x0.y1 = zeros(length(tat_flight_set), length(tat_flight_set));

startTime = datetime; fprintf("Start time %s \n", startTime);
vertiOpt_sol = solve(vertiOpt, x0);
endTime = datetime;
fprintf(" End Time %s \n", endTime);
Solveruntime = endTime - startTime;

%% Result Analysis
if ~isempty(vertiOpt_sol.t_iu)
    %     startTime1 = datetime; fprintf("Start time %s \n", startTime1);
    flight_sol = validateOptSol_AD(vertiOpt_sol, flight_set, inputs);
    % endTime = datetime;

    % Validateruntime = endTime - startTime;
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

function t = timeonedge(flight,edge)

global Edges

t = 0;
edgeLen = get_edge_length(edge);
if ismember(edge,{Edges.dir{:}})
    t = (edgeLen/flight.slant_climb_speed);
end

if ismember(edge, {Edges.OVF{:}})
    t = (edgeLen/flight.vertical_climb_speed);
end

if ismember(edge, {Edges.taxi{:}})
    t = (edgeLen/flight.taxi_speed);
end

if ismember(edge, {Edges.gate{:}})
    t = (edgeLen/flight.taxi_speed);
end

if t == 0
    fprintf("Wrong edge %s \n", edge);
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

global Edges Qdelay
edges = flight.ArrEdges; %nodes = flight.ArrNodes;

taxiedges = intersect(edges,[Edges.taxi, Edges.gate]);

fixTime = timeonedge(flight, edges{1})-5;
OVFtime = timeonedge(flight, edges{2})-5;
TOT = flight.TOT;

taxiTime = 0;

for e = 1:length(taxiedges)
    taxiTime = taxiTime + max(timeonedge(flight, taxiedges{e})-5,1);
end

TAT = flight.TAT;

depTime = fixTime + OVFtime + TOT + taxiTime + TAT + Qdelay;

end
%% Constraints Functions
function [minspeed, maxspeed] =  SpeedConstr(Edges, flight_set, M, t_iu)
global descentDelay Nodes
flight_name_set = [flight_set.name];
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
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

function ytime = YtimeConstr(Nodes, flight_set, t_iu, y_uij, M)
flight_name_set = [flight_set.name];
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
ytime = optimconstr(Nodes, flight_name_set, flight_name_set);

% for n = 1:length(Nodes)
%     u = Nodes(n);
for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;

        % common_node = any(ismember(flight_set(f1).nodes,u)) & any(ismember(flight_set(f2).nodes,u));
        if (f1 ~= f2)
            common_nodes = intersect(flight_set(f1).nodes, flight_set(f2).nodes);
            ytime(common_nodes,i,j) = t_iu(j,common_nodes) >= t_iu(i,common_nodes) - (1-y_uij(common_nodes,i,j))'*M;
        end
    end
end
% end
end

function y7 = y7Constr(Nodes,flight_set,y_uij)

flight_name_set = [flight_set.name];
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
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
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
Overtake = optimconstr(string(setdiff(Edges.all, [Edges.OVF,Edges.TLOF])), flight_name_set, flight_name_set);

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            commonEdges =  setdiff(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), [Edges.TLOF, Edges.OVF]);
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
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
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
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
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
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
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
if length(flight_set) > 1
    flight_name_set = [flight_set.name];
    if length(flight_name_set) == 1
        flight_name_set = {flight_name_set{:}};
    end
else
    flight_name_set = {flight_set.name{:}};
end

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

if length(flight_set) >= 1
    flight_name_set = [flight_set.name];
    if length(flight_name_set) == 1
        flight_name_set = {flight_name_set{:}};
    end
else
    flight_name_set = {flight_set.name{:}};
end
TLOFenterDep = optimconstr(flight_name_set);
uiki = cellfun(@(d) string(d(end-3)), {flight_set.DepNodes});
r = [flight_set.DepTLOF];
TOT = [flight_set.TOT];
constr = arrayfun(@(i,r,u,toti) t_iu(i,r) >= t_iu(i,u) + toti, flight_name_set, r, uiki, TOT, 'UniformOutput', false);
TLOFenterDep(flight_name_set) = [constr{:}];

end


function wakeVortex = wakeConstr(flight_set, t_iu, y_uij,Twake)

global M Nodes
flight_name_set = [flight_set.name];
if length(flight_name_set) == 1
    flight_name_set = {flight_name_set{:}};
end
wakeVortex = optimconstr(Nodes.TLOF, flight_name_set,flight_name_set);

for f1 = 1:length(flight_set)
    i = flight_set(f1).name;
    r1 = union(string(flight_set(f1).ArrTLOF), string(flight_set(f1).DepTLOF));
    for f2 = 1:length(flight_set)
        j = flight_set(f2).name;
        r2 = union(string(flight_set(f1).ArrTLOF), string(flight_set(f1).DepTLOF));
        r = intersect(string(r1),string(r2));
        if (f1 ~= f2) && ~isempty(r)
            Rsepij = Twake(flight_set(f1).class, flight_set(f2).class);
            for r1 = 1:length(r)
                wakeVortex(r(r1), i,j) = t_iu(j,r(r1)) >= t_iu(i,r(r1)) + Rsepij - (1-y_uij(r(r1),i,j))*M;
            end
        end
    end
end

end

function TLOFenter2Dep = TLOFenter2DepConstr(flight_set, t_iu, y_uij)

global M
if length(flight_set) >= 1
    flight_name_set = [flight_set.name];
    if length(flight_name_set) == 1
        flight_name_set = {flight_name_set{:}};
    end
else
    flight_name_set = {flight_set.name{:}};
end

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


function TLOFpadSingle = TLOFpadSingleConstr(arr_flight_set, dep_flight_set, t_iu, y_uij)

global M
flight_name_set = unique([[arr_flight_set.name] , [dep_flight_set.name]]);
TLOFpadSingle = optimconstr(flight_name_set, flight_name_set);
for f1 = 1:length(arr_flight_set)
    i = arr_flight_set(f1).name;
    r1 = arr_flight_set(f1).ArrTLOF;
    ex = arr_flight_set(f1).ArrNodes(4); % TLOF pad exit node
    for f2 = 1:length(dep_flight_set)
        j = dep_flight_set(f2).name;
        r2 = dep_flight_set(f2).DepTLOF;
        en = dep_flight_set(f2).DepNodes(end-3); % TLOF pad entrance node
        if (r1 == r2) && (i~=j)
            r = r1;
            TLOFpadSingle(i,j) = t_iu(j,en) >= t_iu(i,ex) - (1-y_uij(r,i,j))*M;
        end
    end
end

end

function [GateQ] = GateQconstr1(tat_flight_set, arr_flight_set, dep_flight_set, t_iu)

if length(tat_flight_set) >= 1
    tat_name_set = [tat_flight_set.name];
    if length(tat_name_set) == 1
        tat_name_set = {tat_name_set{:}};
    end
end

if length(arr_flight_set) >= 1
    arr_name_set = [arr_flight_set.name];
    if length(arr_name_set) == 1
        arr_name_set = {arr_name_set{:}};
    end
end

if length(dep_flight_set) >= 1
    dep_name_set = [dep_flight_set.name];
    if length(dep_name_set) == 1
        dep_name_set = {dep_name_set{:}};
    end
end

GateQ = optimconstr(tat_name_set,2);
for f = 1:length(tat_flight_set)
    i = tat_flight_set(f).name;
    ia = i + "_Arr";
    id = i + "_Dep";
    fa = arr_name_set == ia;
    fd = dep_name_set == id;
    gen = arr_flight_set(fa).ArrNodes(end);
    gex = dep_flight_set(fd).DepNodes(1);
    g0  = strcat(tat_flight_set(f).Gate,'c',string(0));
    gcg = strcat(tat_flight_set(f).Gate,'c',string(1));
    GateQ(i,1) = t_iu(ia,gen) == t_iu(i,g0); % arrival set entry = tat set entry
    GateQ(i,2) = t_iu(id,gex) == t_iu(i,gcg); % departure set exit = tat set exit
end
end


function [GateQ_ygenij, GateQ_ygexij] = GateQconstr2(tat_flight_set, arr_flight_set, dep_flight_set, y_uij)

if length(tat_flight_set) >= 1
    tat_name_set = [tat_flight_set.name];
    if length(tat_name_set) == 1
        tat_name_set = {tat_name_set{:}};
    end
end

if length(arr_flight_set) >= 1
    arr_name_set = [arr_flight_set.name];
    if length(arr_name_set) == 1
        arr_name_set = {arr_name_set{:}};
    end
end

if length(dep_flight_set) >= 1
    dep_name_set = [dep_flight_set.name];
    if length(dep_name_set) == 1
        dep_name_set = {dep_name_set{:}};
    end
end

GateQ_ygenij = optimconstr(tat_name_set, tat_name_set);
GateQ_ygexij = optimconstr(tat_name_set, tat_name_set);

for f1 = 1:length(tat_flight_set)
    i = tat_flight_set(f1).name;
    ia = i + "_Arr";
    id = i + "_Dep";
    f1a = arr_name_set == ia;
    f1d = dep_name_set == id;
    geni = arr_flight_set(f1a).ArrNodes(end);
    gexi = dep_flight_set(f1d).DepNodes(1);
    g0i  = strcat(tat_flight_set(f1).Gate,'c',string(0));
    gcgi = strcat(tat_flight_set(f1).Gate,'c',string(1));
    for f2 = 1:length(tat_flight_set)
        j = tat_flight_set(f2).name;
        ja = j + "_Arr";
        jd = j + "_Dep";
        f2a = arr_name_set == ja;
        f2d = dep_name_set == jd;
        genj = arr_flight_set(f2a).ArrNodes(end);
        if all(geni{1} == genj{1}) && (f1~=f2)
            g = geni; g0 = g0i;
            GateQ_ygenij(i,j) = y_uij(g,ia,ja) == y_uij(g0,i,j);
            g = gexi; gcg = gcgi;
            GateQ_ygexij(i,j) = y_uij(g,id,jd) == y_uij(gcg,i,j);
        end
    end
end
end


function [GateCapacity1, GateCapacity2] = GateCapacityConstr(tat_flight_set,t_iu, y_uij)

global M

if length(tat_flight_set) >= 1
    tat_name_set = [tat_flight_set.name];
    if length(tat_name_set) == 1
        tat_name_set = {tat_name_set{:}};
    end
end

y1 = optimvar("y1", tat_name_set, tat_name_set, 'LowerBound',0,'UpperBound',1, 'Type','integer');
GateCapacity1 = optimconstr(tat_name_set, tat_name_set);
GateCapacity2 = optimconstr(tat_name_set, tat_name_set, tat_name_set, tat_name_set);

for f1 = 1:length(tat_flight_set)
    i  = tat_flight_set(f1).name;
    g1 = tat_flight_set(f1).Gate;
    for f2 = 1:length(tat_flight_set)
        j = tat_flight_set(f2).name;
        g2 = tat_flight_set(f2).Gate;
        for f3 = f2:length(tat_flight_set)
            k = tat_flight_set(f3).name;
            g3 = tat_flight_set(f3).Gate;
            for f4 = f3:length(tat_flight_set)
                l = tat_flight_set(f4).name;
                g4 = tat_flight_set(f4).Gate;

                if ((f1~=f2) && (f2~=f3) && (f3~=f4) && (f1~=f3) && (f2~=f4) && (f1~=f4)) && (all(g1==g2) && all(g2==g3) && all(g3==g4))
                    g = g1;
                    GateCapacity1(i,j) = t_iu(i,g+"c0") >= t_iu(j,g+"c1") - (1-y_uij(g+"c0",j,i))*M - (1-y1(i,j))*M;
                    GateCapacity1(i,k) = t_iu(i,g+"c0") >= t_iu(k,g+"c1") - (1-y_uij(g+"c0",k,i))*M - (1-y1(i,k))*M;
                    GateCapacity1(i,l) = t_iu(i,g+"c0") >= t_iu(l,g+"c1") - (1-y_uij(g+"c0",l,i))*M - (1-y1(i,l))*M;
                    GateCapacity2(i,j,k,l) = y1(i,j)+y1(i,k)+y1(i,l)>=1;
                end
            end
        end
    end
end
end