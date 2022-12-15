clear

%% User Input

num_flight = 1;
flight_req_time = randi(60,[num_flight,1]);

%% Sets
TaxiPoints = ["a", "b"];

TaxiEdges = {{'a-b'}};

TLOFpad = {'R1'};
% Sr = 2;
% qSlots = 1:Sr;
% Qnodes = repmat("q",[1,Sr]) + qSlots;
climb_paths = {'N'};
Fix_Nodes = {'Na','Nb', 'Sa', 'Sb'}; 
ClimbEdges = {{'Na-Nb'},{'Sa-Sb'}}; %TODO make clilmb approach edges 

gates = {'G1'};
gateEdges = {{'G1-a'}};

Nodes = [gates, TaxiPoints, TLOFpad, Fix_Nodes];
HoldingEdges = {{'b-R1'}};
LandEdges = {{'R1-Na'},  {'R1-Sa'}};
Edges = string([gateEdges{:}, TaxiEdges{:},HoldingEdges{:},LandEdges{:},ClimbEdges{:}]);

flight_path_node = {'Nb', 'Na', 'R1', 'b','a','G1'};
flight_path_edge = {'Nb-Na','Na-R1','R1-b','b-a','a-G1'};

Operators = "A";

flight_set = strings(1,num_flight);

if num_flight > 1
    for f = 1:num_flight
        o = randi(length(Operators));
        flight_set(f) = Operators(o)+num2str(f);
    end
else
    flight_set = {'A1'};
end

flight_set_0 = ["a0", flight_set];

%% Parameters

D_uv = 15; % length of the taxi way  TODO different length of different taxiway


ARAPPR_i = flight_req_time;
DRGATE_i = flight_req_time;

MinimumNodePassTime = 1;
MinTaxiT_uv = 7; % TODO different according to flight capabillity & edge
MaxTaxiT_uv = 11; % TODO different according to flight capabillity & edge
MinClimbTime_ic = 14; % TODO different according to flight capabillity & edge

MaxGateHold_ig = 9;
MaxTakeOffdelay = 6;
MaxClimbTime = 20;

Dsep_ij = 5;  % TODO have a table for taxi edges and flights 
Rsepij = 3; % TODO have a table for launchpad and flights 

Tfh_i = 4;
Tmin_icr = 10;
Tmax_icr = 25;
Csep_ij = 10; % separation distance betweeen 2 flights while climbing
Ticool = 5;

W_r = 7;
W_q = 2;
Wa_c = 3;
Wd_c = 3;
W_g = 1;

M = 200;

%% Optimsation problem

takeoffOpt = optimproblem;

% Decision variables

t_iu  = optimvar('t_iu', flight_set, Nodes, 'LowerBound',0);
x_uij = optimvar('x_uij', Nodes, flight_set_0, flight_set_0, 'LowerBound',0,'UpperBound',1, 'Type','integer');
y_uij = optimvar('y_uij', Nodes, flight_set_0, flight_set_0, 'LowerBound',0,'UpperBound',1, 'Type','integer');

% Arrivals
vertiIn = optimexpr(1,flight_set); % TODO for arrival

for f = 1:length(flight_set)
    i = flight_set(f);
    r = flight_path_node(3);  % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    vertiIn(i) = t_iu(i,r) - ARAPPR_i(f);
end

Qapproach = Wa_c*sum(vertiIn);


taxiTimeArr = optimexpr(1,flight_set); % TODO for arrival

for f = 1:length(flight_set)
    i = flight_set(f);
    ui1 = flight_path_node(4);
    uiki = flight_path_node(end); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    taxiTimeArr(i) = t_iu(i,uiki) - t_iu(i,ui1);
end

QtaxiTimeArr = sum(taxiTimeArr);

Landtime = optimexpr(1,flight_set); % TODO for arrival
for f = 1:length(flight_set)
    i = flight_set(f);
    ui1 = flight_path_node(4); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    r = flight_path_node(1); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    Landtime(i) = t_iu(i,ui1) - t_iu(i,r);
end

QLand = W_r*sum(Landtime);

taxiout = optimexpr(1,flight_set);

for f = 1:length(flight_set)
    i = flight_set(f);
    g = flight_path_node(1);
    taxiout(i) = t_iu(i,g) - DRGATE_i(f);
end

Qtaxiout = W_g*sum(taxiout);

taxiTimeDep = optimexpr(1,flight_set);

for f = 1:length(flight_set)
    i = flight_set(f);
    g = flight_path_node(1);
    uiki = flight_path_node(end-3); % Last node, LaunchpadNode, Climb_a, Climb_b
    taxiTimeDep(i) = t_iu(i,uiki) - t_iu(i,g);
end

QtaxiTimeDep = sum(taxiTimeDep);

takeOfftime = optimexpr(1,flight_set);
for f = 1:length(flight_set)
    i = flight_set(f);
    uiki = flight_path_node(end-3); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    r = flight_path_node(end-2); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    takeOfftime(i) = t_iu(i,r) - t_iu(i,uiki);
end

QtakeOff = W_q*sum(takeOfftime);

climbTime = optimexpr(1,flight_set);

for f = 1:length(flight_set)
    i = flight_set(f);
    r = flight_path_node(end-3); % ..,Last node, LaunchpadNode, Climb_a, Climb_b
    cb = flight_path_node(end);
    climbTime(i) = t_iu(i,cb) - t_iu(i,r);
end

QClimb = Wd_c*sum(climbTime);

takeoffOpt.Objective = Qapproach + QLand + QtaxiTimeArr + Qtaxiout + QtaxiTimeDep + QtakeOff + QClimb;

%% Constraints
fprintf("Formulating constraints.....");

% ARAPR_i Arr C1
takeoffOpt.Constraints.ARAPR_i = optimconstr(flight_set); % TODO for arrival
for f = 1:length(flight_set)
     i = flight_set(f);
     cb = flight_path_node(1);
     takeoffOpt.Constraints.ARAPR_i(i) = t_iu(i,cb) == flight_req_time(f);
end

fprintf(" 0.1 ");

% Gate out C2

takeoffOpt.Constraints.gateOutC1 = optimconstr(flight_set); % TODO According to departures
for f = 1:length(flight_set)
    i = flight_set(f);
    g = flight_path_node(1);
    takeoffOpt.Constraints.gateOutC1(i) = t_iu(i,g) >= DRGATE_i(f);
end

fprintf(" 0.2 ");

% Taxiing speed constraints C5 & C6
takeoffOpt.Constraints.minspeed = optimconstr(flight_set, Edges);
takeoffOpt.Constraints.maxspeed = optimconstr(flight_set, Edges);

for f = 1:length(flight_set)
    i = flight_set(f);
    for e = 1:(length(flight_path_edge))
        %      j = flight_path_(e);
        e_ = split(flight_path_edge{e},'-');
        u = e_{1}; v = e_{2};
        takeoffOpt.Constraints.minspeed(i,flight_path_edge(e)) = t_iu(i,v) >= t_iu(i,u) + MinTaxiT_uv; % TODO select according to edge
        takeoffOpt.Constraints.maxspeed(i,flight_path_edge(e)) = t_iu(i,v) <= t_iu(i,u) + MaxTaxiT_uv; % TODO select according to edge
    end
end

fprintf(" 1 ");

% Defination of x^u_ij C7-C11

takeoffOpt.Constraints.xsum1 = optimconstr(Nodes, flight_set_0);
takeoffOpt.Constraints.xsum2 = optimconstr(Nodes, flight_set_0);

for n = 1:length(Nodes)
    u = Nodes(n);
    for f = 1:length(flight_set_0)
        i = flight_set_0(f);
        takeoffOpt.Constraints.xsum1(u,i) = sum(x_uij(u,i,:)) == 1;
        takeoffOpt.Constraints.xsum2(u,i) = sum(x_uij(u,:,i)) == 1;
    end
end

fprintf(" 2 ");

takeoffOpt.Constraints.xtime1 = optimconstr(Nodes, flight_set, flight_set);
takeoffOpt.Constraints.xtime2 = optimconstr(Nodes, flight_set, flight_set);
takeoffOpt.Constraints.xtime3 = optimconstr(Nodes, flight_set, flight_set);

for n = 1:length(Nodes)
    u = Nodes(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1);
        for f2 = 1:length(flight_set)
            j = flight_set(f2);
            if f1 ~= f2
                takeoffOpt.Constraints.xtime1(u,i,j) = t_iu(j,u) >= t_iu(i,u) - (1-x_uij(u,i,j))*M;
                takeoffOpt.Constraints.xtime1(u,i,j) = t_iu(i,u) >= t_iu(j,u) - (1-x_uij(u,"a0",j))*M;
                takeoffOpt.Constraints.xtime1(u,i,j) = t_iu(i,u) >= t_iu(j,u) - (1-x_uij(u,i,"a0"))*M;
            end
        end
    end
end

fprintf(" 3 ");

% Deifinition of y^u_ij C12-C17

takeoffOpt.Constraints.y1 = optimconstr(Nodes, flight_set_0, flight_set_0);

for n = 1:length(Nodes)
    u = Nodes(n);
    for f1 = 1:length(flight_set_0)
        i = flight_set_0(f1);
        for f2 = 1:length(flight_set_0)
            j = flight_set_0(f2);
            if f1 ~= f2
                takeoffOpt.Constraints.y1(u,i,j) = y_uij(u,i,j) >= x_uij(u,i,j);
            end
        end
    end
end

fprintf(" 4 ");

takeoffOpt.Constraints.y2 = optimconstr(Nodes, flight_set, flight_set);
takeoffOpt.Constraints.y3 = optimconstr(Nodes, flight_set, flight_set);
takeoffOpt.Constraints.y4 = optimconstr(Nodes, flight_set, flight_set);
takeoffOpt.Constraints.y5 = optimconstr(Nodes, flight_set, flight_set);

for n = 1:length(Nodes)
    u = Nodes(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1);
        for f2 = 1:length(flight_set)
            j = flight_set(f2);
            if f1 ~= f2
                takeoffOpt.Constraints.y2(u,i,j) = y_uij(u,i,j) >= x_uij(u,"a0",j);
                takeoffOpt.Constraints.y3(u,i,j) = x_uij(u,"a0", j) + y_uij(u,i,j) <=  1;
                takeoffOpt.Constraints.y4(u,i,j) = y_uij(u,i,j) >= x_uij(u,i,"a0");
                takeoffOpt.Constraints.y5(u,i,j) = x_uij(u,i,"a0") + y_uij(u,i,j) <= 1;
            end
        end
    end
end

fprintf(" 5 ");

takeoffOpt.Constraints.y6 = optimconstr(Nodes, flight_set, flight_set, flight_set);

for n = 1:length(Nodes)
    u = Nodes(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1);
        for f2 = 1:length(flight_set)
            j = flight_set(f2);
            for f3 = 1:length(flight_set)
                k = flight_set(f3);
                if (f1 ~= f2) && (f1 ~=f3) && (f2 ~= f3)
                    takeoffOpt.Constraints.y6(u,i,j,k) = y_uij(u,k,j) >= x_uij(u,i,j) + y_uij(u,k,i) -1;
                end
            end
        end
    end
end

fprintf(" 6 ");

% Taxi & climb separation C20

takeoffOpt.Constraints.taxiSeparation1 = optimconstr(string([TaxiEdges,ClimbEdges]), flight_set, flight_set);
tmpEdges = string([TaxiEdges,ClimbEdges]);
for e = 1:length(tmpEdges)
    %     e_ = convertStringsToChars(TaxiEdges(e));

    e_ = split(tmpEdges{e},'-');
    u = e_{1}; v = e_{2};
    for f1 = 1:length(flight_set)
        for f2 = 1:length(flight_set)
            i = flight_set(f1);
            j = flight_set(f2);
            if f1 ~= f2 % TODO consition according to
                takeoffOpt.Constraints.taxiSeparation1(e_,i,j) = t_iu(j,u) >= t_iu(i,u) + (Dsep_ij/D_uv)*(t_iu(i,v) - t_iu(i,u)) - (1-y_uij(u,i,j))*M; % TODO taxi edge & climb edge D_uv
            end
        end
    end
end

fprintf(" 7 ");

% TLOF pad exit C21
takeoffOpt.Constraints.TLOFenter = optimconstr(flight_set); %TODO according to arrivals
for f = 1:length(flight_set)
    i = flight_set(f);
    r = flight_path_node(3);
    ui1 = flight_path_node(4);
    takeoffOpt.Constraints.TLOFenter(i) = t_iu(i,ui1) >= t_iu(i,r) + Ticool; % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
end

fprintf(" 8 ");

% TLOF pad entrance C21.1
takeoffOpt.Constraints.TLOFenter = optimconstr(flight_set); %TODO according to departures
for f = 1:length(flight_set)
    i = flight_set(f);
    r = flight_path_node(end-2);
    uiki = flight_path_node(end-3);
    takeoffOpt.Constraints.TLOFenter(i) = t_iu(i,r) >= t_iu(i,uiki); %  ..,Last node, LaunchpadNode, Climb_a, Climb_b
end

fprintf(" 9 ");

% Wake vortex separation C22

takeoffOpt.Constraints.wake = optimconstr(flight_set,flight_set);

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1);
        j = flight_set(f2);
        r = flight_path_node(3); % TODO according to flight's path if both i & j are immediate follower
        if f1 ~= f2
            takeoffOpt.Constraints.wake(i,j) = t_iu(j,r) >= t_iu(i,r) + Rsepij - (1-x_uij(r,i,j))*M;
        end
    end
end

fprintf(" 10 ");

takeoffOpt.Constraints.TLOFClear = optimconstr(flight_set, flight_set); %TODO according to arrivals

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1);
        j = flight_set(f2); 
        ca = flight_path_node(2); % According to j flight's plan
        r = flight_path_node(3); % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
        ui1 = flight_path_node(4); % TODO according to i flight's path 
        if f1 ~= f2
            takeoffOpt.Constraints.TLOFClear(i,j) = t_iu(j,ca) >= t_iu(i,ui1) - (1-x_uij(r,i,j))*M;
        end
    end
end

fprintf(" 11 ");

takeoffOpt.Constraints.TLOFenter2 = optimconstr(flight_set, flight_set); %TODO according to departures
for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1);
        j = flight_set(f2);
        ca = flight_path_node(2); % According to j flight's plan
        r = flight_path_node(3); %  ..,Last node, LaunchpadNode, Climb_a, Climb_b
        if f1 ~= f2
            takeoffOpt.Constraints.TLOFenter2(i,j) = t_iu(j,r) >= t_iu(i,ca) - (1-x_uij(r,i,j)*M);
        end
    end
end

fprintf(" 12 ");

fprintf(" \n ");

%% Problem solving

x0.t_iu  = zeros(length(flight_set), length(Nodes));
x0.x_uij = zeros(length(Nodes), length(flight_set_0), length(flight_set_0));
x0.y_uij = zeros(length(Nodes), length(flight_set_0), length(flight_set_0));

LandOpt_sol = solve(takeoffOpt, x0);