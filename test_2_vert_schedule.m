clear
startTime = datetime; fprintf("Start time %s \n", startTime);
rng(8);
seedUsed = rng;
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

max_vertical_climb_speed = 6; % 20km/hr is 6m/s which is max speed on taxiways and max vertical climb speed

inclination_climb_edge_length = 17*d5; %From point X to fixed direction

%D is separation distance on taxi where rows are leading and columns are following
D_sep_taxi = [d1 d2 d3 d4 d5; d2 d2 d3 d4 d5; d3 d3 d3 d4 d5; d4 d4 d4 d4 d5; d5 d5 d5 d5 d5];
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


Nodes.gates = {'G1','G2','G3','G4'};
Nodes.taxi  = {'a','b','c','d','e','f','g','h', 'i'};
Nodes.TLOF  = {'R1', 'R2'};
Nodes.OVF   = {'X','Y'};
Nodes.dir   = {'N','E','W','S'};
Nodes.all   = [[Nodes.gates], [Nodes.taxi], [Nodes.TLOF], [Nodes.OVF], [Nodes.dir]];

Edges.gate = {'G1-a','G3-a','G2-b','G4-b', 'g-G4', 'e-G2', 'd-G1', 'f-G3'};
Edges.taxi = {'a-b','b-c','i-f', 'f-g', 'h-d', 'd-e'};
Edges.TLOF = {'c-R2', 'R1-i', 'R1-h'};
Edges.OVF  = {'R2-X', 'Y-R1'};
Edges.dir  = {'X-N','X-E', 'W-Y', 'S-Y'};
Edges.all  = [[Edges.gate], [Edges.taxi], [Edges.TLOF], [Edges.OVF], [Edges.dir]];
Edges.len  = [edge_length_before_TLOF, vertical_climb_edge_length_above_TLOF, inclination_climb_edge_length];


flight_path_nodes={
    {'G1','a','b','c','R2','X','N'},{'G1','a','b','c','R2','X','E'},{'G3','a','b','c','R2','X','N'},{'G3','a','b','c','R2','X','E'},{'G2','b','c','R2','X','N'},{'G2','b','c','R2','X','E'},{'G4','b','c','R2','X','N'},{'G4','b','c','R2','X','E'}, ...
%     {'W','Y','R1','i','f','G3'},{'W','Y','R1','i','f','g','G4'},{'W','Y','R1','h','d','G1'},{'W','Y','R1','h','d','e','G2'},{'S','Y','R1','i','f','G3'},{'S','Y','R1','i','f','g','G4'},{'S','Y','R1','h','d','G1'},{'S','Y','R1','h','d','e','G2'}...
    };

flight_path_edges={
    {'G1-a','a-b','b-c','c-R2','R2-X','X-N'},{'G1-a','a-b','b-c','c-R2','R2-X','X-E'},{'G3-a','a-b','b-c','c-R2','R2-X','X-N'},{'G3-a','a-b','b-c','c-R2','R2-X','X-E'},{'G2-b','b-c','c-R2','R2-X','X-N'},{'G2-b','b-c','c-R2','R2-X','X-E'},{'G4-b','b-c','c-R2','R2-X','X-N'},{'G4-b','b-c','c-R2','R2-X','X-E'},...
%     {'W-Y','Y-R1','R1-i','i-f','f-G3'},{'W-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'W-Y','Y-R1','R1-h','h-d','d-G1'},{'W-Y','Y-R1','R1-h','h-d', 'd-e','e-G2'},{'S-Y','Y-R1','R1-i','i-f','f-G3'},{'S-Y','Y-R1','R1-i','i-f','f-g','g-G4'},{'S-Y','Y-R1','R1-h','h-d','d-G1'},{'S-Y','Y-R1','R1-h', 'h-d', 'd-e','e-G2'}...
    };

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
% flclass = {
%     'Super';
% %     'Medium';
%     'Small';
% %     'Medium';
%     'Jumbo'
%     };
%% FLight set

flight_class = {'Super','Jumbo','Medium','Small'};
operator = {'xx','zz','yy','ww','tt','mm','nn','rr'};

flight_set_struct = struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'coolTime', []);

num_flight = 3;
flight_req_time = randi(60,[num_flight,1]);

flight_set(num_flight,1) = flight_set_struct; % struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[]);
arr_flight_set = []; % struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[]);
dep_flight_set = []; % struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[]);

for f = 1:num_flight
    q = randi(length(flight_class));
    x = randi(length(flight_path_nodes));
    o = randi(length(operator));
    n = flight_path_nodes{x};

    if num_flight > 1
        flight.name=string(flight_class(q)) + '-' + string(operator(o))+'-'+f;
    else
        flight.name = {'Super-xx-1'};
    end

    flight.reqTime = flight_req_time(f);
    flight.nodes = flight_path_nodes{x};
    flight.edges = flight_path_edges{x};
    flight.taxi_speed=max_edge_taxi_speed;
    flight.vertical_climb_speed=6;
    flight.slant_climb_speed=17;
    flight.class = find(string(UAM_class(flight))==flight_class,1);
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
    if length(arr_name_set) == 1
        arr_name_set = {arr_name_set{:}};
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

flight_0 = struct('name',"0-0-0",'reqTime',0,'direction',[],'nodes',{Nodes.all},'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[],'class',[],'coolTime',[]);
a0 = flight_0.name;
flight_set_0 = [flight_0 ; flight_set];
flight_name_set_0 = [flight_0.name , flight_set.name];
fprintf("Num flights %d, dep %d arr %d \n", num_flight, length(dep_flight_set), length(arr_flight_set))
%% Parameters

W_r = 7;
W_q = 2;
Wa_c = 3;
Wd_c = 3;
W_g = 1;

M = 200;

inputs.Twake = Twake;
inputs.Edges = Edges;
inputs.Nodes = Nodes;
%% Optimsation problem

vertiOpt = optimproblem;

% Decision variables

t_iu  = optimvar('t_iu', flight_name_set, Nodes.all, 'LowerBound',0);
x_uij = optimvar('x_uij', Nodes.all, [flight_set_0.name], [flight_set_0.name], 'LowerBound',0,'UpperBound',1, 'Type','integer');
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

QtaxiTimeArr = sum(taxiTimeArr);

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

QtaxiTimeDep = sum(taxiTimeDep);

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

vertiOpt.Objective = Qapproach + QLand + QtaxiTimeArr + Qtaxiout + QtaxiTimeDep + QtakeOff + QClimb;

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

vertiOpt.Constraints.gateOutC1 = optimconstr(dep_name_set); % TODO According to departures
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    g = dep_flight_set(f).nodes(1);
    vertiOpt.Constraints.gateOutC1(i) = t_iu(i,g) >= dep_flight_set(f).reqTime;
end

fprintf(" 0.2 ");

% Taxiing speed constraints C5 & C6
vertiOpt.Constraints.minspeed = optimconstr(flight_name_set, setdiff(Edges.all,Edges.TLOF));
vertiOpt.Constraints.maxspeed = optimconstr(flight_name_set, setdiff(Edges.all,Edges.TLOF));

for f = 1:length(flight_set)
    i = flight_set(f).name;
    tmpEdges = setdiff(flight_set(f).edges,Edges.TLOF);
    for e = 1:(length(tmpEdges))
        e_ = split(tmpEdges{e},'-');
        u = e_{1}; v = e_{2};
        MinEdgeT_uv = max(timeonedge(flight_set(f),tmpEdges{e}, d5) - 5,0); % TODO Different speed
        MaxEdgeT_uv = min(timeonedge(flight_set(f),tmpEdges{e}, d5) + 5,M); % TODO Different speed
        vertiOpt.Constraints.minspeed(i,tmpEdges(e)) = t_iu(i,v) >= t_iu(i,u) + MinEdgeT_uv;
        vertiOpt.Constraints.maxspeed(i,tmpEdges(e)) = t_iu(i,v) <= t_iu(i,u) + MaxEdgeT_uv;
    end
end

fprintf(" 1 ");
%
% Defination of x^u_ij C7-C11

% vertiOpt.Constraints.xii   = optimconstr(Nodes.all, flight_name_set_0);
vertiOpt.Constraints.xsum1 = optimconstr(Nodes.all, flight_name_set_0);
vertiOpt.Constraints.xsum2 = optimconstr(Nodes.all, flight_name_set_0);

% for n = 1:length(Nodes.all) 
%     u = Nodes.all(n);
%     for f = 1:length(flight_set_0)
%         i = flight_set_0(f).name; % This is a wrong aproach as it add all the flights who are not passing thorught the node
% %         vertiOpt.Constraints.xii(u,i)   = x_uij(u,i,i) == 0;
%         vertiOpt.Constraints.xsum1(u,i) = sum(x_uij(u,i,:)) - x_uij(u,i,i) == 1;
%         vertiOpt.Constraints.xsum2(u,i) = sum(x_uij(u,:,i)) - x_uij(u,i,i) == 1;
%     end
% end


for n = 1:length(Nodes.all)
    u = Nodes.all(n);
    for f1 = 1:length(flight_set_0)
        i = flight_set_0(f1).name;
        xsum1 = optimexpr;
        xsum2 = optimexpr;
        isFilled = false;
        for f2 = 1:length(flight_set_0)
            j = flight_set_0(f2).name;
            common_node = any(ismember(flight_set_0(f1).nodes,u)) & any(ismember(flight_set_0(f2).nodes,u));
            if (f1 ~= f2) && common_node
                xsum1 = xsum1 + x_uij(u,i,j);
                xsum2 = xsum2 + x_uij(u,j,i);
                isFilled = true;
            end
        end
        if isFilled
            vertiOpt.Constraints.xsum1(u,i) = xsum1 == 1;
            vertiOpt.Constraints.xsum2(u,i) = xsum2 == 1;
        end
    end
end

fprintf(" 2 ");

vertiOpt.Constraints.xtime1 = optimconstr(Nodes.all, flight_name_set, flight_name_set);
vertiOpt.Constraints.xtime2 = optimconstr(Nodes.all, flight_name_set, flight_name_set);
vertiOpt.Constraints.xtime3 = optimconstr(Nodes.all, flight_name_set, flight_name_set);

for n = 1:length(Nodes.all)
    u = Nodes.all(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1).name;
        for f2 = 1:length(flight_set)
            j = flight_set(f2).name;

            common_node = any(ismember(flight_set(f1).nodes,u)) & any(ismember(flight_set(f2).nodes,u));

            if (f1 ~= f2) && common_node
                vertiOpt.Constraints.xtime1(u,i,j) = t_iu(j,u) >= t_iu(i,u) - (1-x_uij(u,i,j))*M;
                vertiOpt.Constraints.xtime2(u,i,j) = t_iu(i,u) >= t_iu(j,u) - (1-x_uij(u,a0,j))*M;
                vertiOpt.Constraints.xtime3(u,i,j) = t_iu(i,u) >= t_iu(j,u) - (1-x_uij(u,i,a0))*M;
            end
        end
    end
end

fprintf(" 3 ");

% Deifinition of y^u_ij C12-C17

vertiOpt.Constraints.y1 = optimconstr(Nodes.all, flight_name_set_0, flight_name_set_0);

for n = 1:length(Nodes.all)
    u = Nodes.all(n);
    for f1 = 1:length(flight_set_0)
        i = flight_set_0(f1).name;
        for f2 = 1:length(flight_set_0)
            j = flight_set_0(f2).name;
            common_node = any(ismember(flight_set_0(f1).nodes,u)) & any(ismember(flight_set_0(f2).nodes,u));

            if (f1 ~= f2) && common_node
                vertiOpt.Constraints.y1(u,i,j) = y_uij(u,i,j) >= x_uij(u,i,j);
            end
        end
    end
end

fprintf(" 4 ");

vertiOpt.Constraints.y2 = optimconstr(Nodes.all, flight_name_set, flight_name_set);
vertiOpt.Constraints.y3 = optimconstr(Nodes.all, flight_name_set, flight_name_set);
vertiOpt.Constraints.y4 = optimconstr(Nodes.all, flight_name_set, flight_name_set);
vertiOpt.Constraints.y5 = optimconstr(Nodes.all, flight_name_set, flight_name_set);

for n = 1:length(Nodes.all)
    u = Nodes.all(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1).name;
        for f2 = 1:length(flight_set)
            j = flight_set(f2).name;
            common_node = any(ismember(flight_set(f1).nodes,u)) & any(ismember(flight_set(f2).nodes,u));

            if (f1 ~= f2) && common_node
                vertiOpt.Constraints.y2(u,i,j) = y_uij(u,j,i) >= x_uij(u,a0,j);
                vertiOpt.Constraints.y3(u,i,j) = x_uij(u,a0, j) + y_uij(u,i,j) <=  1;
                vertiOpt.Constraints.y4(u,i,j) = y_uij(u,j,i) >= x_uij(u,i,a0);
                vertiOpt.Constraints.y5(u,i,j) = x_uij(u,i,a0) + y_uij(u,i,j) <= 1;
            end
        end
    end
end

fprintf(" 5 ");

vertiOpt.Constraints.y6 = optimconstr(Nodes.all, flight_name_set, flight_name_set, flight_name_set);

for n = 1:length(Nodes.all)
    u = Nodes.all(n);
    for f1 = 1:length(flight_set)
        i = flight_set(f1).name;
        for f2 = 1:length(flight_set)
            j = flight_set(f2).name;
            for f3 = 1:length(flight_set)
                k = flight_set(f3).name;
                common_node = any(ismember(flight_set_0(f1).nodes,u)) & any(ismember(flight_set_0(f2).nodes,u)) & any(ismember(flight_set_0(f3).nodes,u));
                if (f1 ~= f2) && (f1 ~=f3) && (f2 ~= f3) && common_node
                    vertiOpt.Constraints.y6(u,i,j,k) = y_uij(u,k,j) >= x_uij(u,i,j) + y_uij(u,k,i) -1;
                end
            end
        end
    end
end

fprintf(" 6 ");

% Overtake C18
vertiOpt.Constraints.Overtake = optimconstr(string([Edges.taxi,Edges.dir]), flight_name_set, flight_name_set);
for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            commonEdges =  setdiff(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), [Edges.gate, Edges.OVF]);
            for e1 = 1:length(commonEdges)
                e = commonEdges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                vertiOpt.Constraints.Overtake(e,i,j) = y_uij(u,i,j) - y_uij(v,i,j) == 0;
            end
        end
    end
end

fprintf(" 7 ");

% Collission C19
vertiOpt.Constraints.Collision = optimconstr(string([Edges.taxi,Edges.dir]), flight_name_set, flight_name_set);
tmpEdges = string([Edges.taxi,Edges.dir]);
for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            for e1 = 1:length(tmpEdges)
                e = tmpEdges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                er = [v  '-'  u];
                commonEdge = any(ismember(tmpEdges{e1},flight_set(f1).edges) & ismember(flight_set(f2).edges,er));
                if commonEdge
                    vertiOpt.Constraints.Collision(e,i,j) = y_uij(u,i,j) - y_uij(v,i,j) == 0;
                end
            end
        end
    end
end

fprintf(" 8 ");

% Taxi & climb separation C20

vertiOpt.Constraints.taxiSeparation1 = optimconstr(string([Edges.taxi,Edges.dir]), flight_name_set, flight_name_set);
tmpEdges = cell([Edges.taxi,Edges.dir]);
for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        if f1 ~= f2
            commonEdges =  intersect(intersect(flight_set(f1).edges,flight_set(f2).edges,"stable"), tmpEdges,"stable");
            for e1 = 1:length(commonEdges)
                e = commonEdges{e1};
                e_ = split(e,'-');
                u = e_{1}; v = e_{2};
                D_uv = get_edge_length(commonEdges{e1},Edges);
                Dsep_ij = D_sep_taxi(flight_set(f1).class, flight_set(f2).class);
                vertiOpt.Constraints.taxiSeparation1(e,i,j) = t_iu(j,u) >= t_iu(i,u) + (Dsep_ij/D_uv)*(t_iu(i,v) - t_iu(i,u)) - (1-y_uij(u,i,j))*M;
            end
        end
    end
end

fprintf(" 9 ");

% TLOF pad exit C21
vertiOpt.Constraints.TLOFenterArr = optimconstr(arr_name_set);
for f = 1:length(arr_flight_set)
    i = arr_flight_set(f).name;
    r = arr_flight_set(f).TLOF;
    ui1 = arr_flight_set(f).nodes(4);% Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
    Ticool = arr_flight_set(f).coolTime;
    vertiOpt.Constraints.TLOFenterArr(i) = t_iu(i,ui1) >= t_iu(i,r) + Ticool;
end

% fprintf(" 10 ");

% TLOF pad entrance C21.1
vertiOpt.Constraints.TLOFenterDep = optimconstr(dep_name_set);
for f = 1:length(dep_flight_set)
    i = dep_flight_set(f).name;
    r = dep_flight_set(f).TLOF;
    uiki = dep_flight_set(f).nodes(end-3); %  ..,Last node, LaunchpadNode, Climb_a, Climb_b
    vertiOpt.Constraints.TLOFenterDep(i) = t_iu(i,r) >= t_iu(i,uiki);
end

fprintf(" 11 ");

% Wake vortex separation C22

vertiOpt.Constraints.wake = optimconstr(flight_name_set,flight_name_set);

for f1 = 1:length(flight_set)
    for f2 = 1:length(flight_set)
        i = flight_set(f1).name;
        j = flight_set(f2).name;
        r1 = flight_set(f1).TLOF;
        r2 = flight_set(f2).TLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            Rsepij = Twake(flight_set(f1).class, flight_set(f2).class);
            vertiOpt.Constraints.wake(i,j) = t_iu(j,r) >= t_iu(i,r) + Rsepij - (1-x_uij(r,i,j))*M;
        end
    end
end

fprintf(" 12 ");

% land approach Arr C26.2
vertiOpt.Constraints.TLOFClearArr = optimconstr(arr_name_set, arr_name_set);

for f1 = 1:length(arr_flight_set)
    for f2 = 1:length(arr_flight_set)
        i = arr_flight_set(f1).name;
        j = arr_flight_set(f2).name;
        r1 = arr_flight_set(f1).TLOF;
        r2 = arr_flight_set(f2).TLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = arr_flight_set(f2).nodes(2); % According to j flight's plan
            ui1 = arr_flight_set(f2).nodes(4); % according to i flight's path % Climb_b, Climb_a, LaunchpadNode,1st node....... Last node
            vertiOpt.Constraints.TLOFClearArr(i,j) = t_iu(j,ca) >= t_iu(i,ui1) - (1-x_uij(r,i,j))*M;
        end
    end
end

fprintf(" 13 ");

% takeOff climb C26.1
vertiOpt.Constraints.TLOFenter2Dep = optimconstr(dep_name_set, dep_name_set);
for f1 = 1:length(dep_flight_set)
    for f2 = 1:length(dep_flight_set)
        i = dep_flight_set(f1).name;
        j = dep_flight_set(f2).name;
        r1 = dep_flight_set(f1).TLOF;
        r2 = dep_flight_set(f2).TLOF;
        if (f1 ~= f2) && (r1 == r2)
            r = r1;
            ca = dep_flight_set(f1).nodes(end-1); % According to i flight's plan..,Last node, LaunchpadNode, Climb_a, Climb_b
            vertiOpt.Constraints.TLOFenter2Dep(i,j) = t_iu(j,r) >= t_iu(i,ca) - (1-x_uij(r,i,j))*M;
        end
    end
end

fprintf(" 14 ");

fprintf(" \n ");

%% Problem solving

x0.t_iu  = zeros(length(flight_set), length(Nodes.all));
x0.x_uij = zeros(length(Nodes.all), length(flight_set_0), length(flight_set_0));
x0.y_uij = zeros(length(Nodes.all), length(flight_set_0), length(flight_set_0));

vertiOpt_sol = solve(vertiOpt, x0);
endTime = datetime;
fprintf(" End Time %s \n", endTime);
Solveruntime = endTime - startTime;

%% Result Analysis
if ~isempty(vertiOpt_sol.t_iu)
    startTime1 = datetime; fprintf("Start time %s \n", startTime1);
    flight_sol = validateOptSol(vertiOpt_sol, flight_set_0, inputs);
    endTime = datetime;
    fprintf(" End Time %s \n", endTime);
    Validateruntime = endTime - startTime1;
else
    fprintf(" SOLUTION NOT FOUND \n");
    flight_sol = [];
end
%% The End
datefmt = datestr(startTime, "YYYY_mm_DD_HH_MM_SS");
folder = "Results//";
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
%% Functions

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

function t = timeonedge(flight,edge,d)
n=split(edge,'-',1);
x=string(n(1));
y=string(n(2));
if flight.direction == "dep"
    if(x == flight.TLOF)
        t=(5*d)/flight.vertical_climb_speed;
    elseif (y == flight.fix_direction)
        t=(17*d)/flight.slant_climb_speed;
    else
        t=(3*d)/flight.taxi_speed;
    end
elseif flight.direction == "arr"
    if(y == flight.TLOF)
        t=(5*d)/flight.vertical_climb_speed;
    elseif (x == flight.fix_direction)
        t=(17*d)/flight.slant_climb_speed;
    else
        t=(3*d)/flight.taxi_speed;
    end
else
    fprintf("Wrong flight direction for flight %s \n", flight.name);
end
end

% function a = is_common_node(flight1,flight2)
% C = intersect(flight1.nodes,flight2.nodes,"stable");
% a =C;
% end

function cat = UAM_class(flight)
n=split(flight.name,'-',1);
cat =n(1);
end

function len = get_edge_length(e, Edges)

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

