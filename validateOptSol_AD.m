function outputs = validateOptSol_AD(vertioptSoln, flight_set_0, inputs)

global Edges
% twake = inputs.Twake;
Edges = inputs.Edges;
% nodes = inputs.Nodes;
% gateCapacity = inputs.gateCap;


num_flight = length(flight_set_0);
t_iu  = vertioptSoln.t_iu;
if isfield(vertioptSoln, 'x_uij')
    x_uij = vertioptSoln.x_uij;
end
if isfield(vertioptSoln, 'y_uij')
    y_uij = vertioptSoln.y_uij;
end

% arr_flight_set = []; dep_flight_set = [];
%
% for f = 2:length(flight_set_0)
%    if  flight_set_0(f).direction == "arr"
%        arr_flight_set = [arr_flight_set flight_set_0(f)];
%    elseif flight_set_0(f).direction == "dep"
%        dep_flight_set = [dep_flight_set flight_set_0(f)];
%    else
%        fprintf("Wrong flight direction %s for flight %d \n", flight_set_0(f).direction, f);
%    end
% end

% flight_sol_struct = struct('name',[],'reqTime',[],'direction',[],'nodes',[],'edges',[],'TLOF',[],'fix_direction',[],'taxi_speed',[],'vertical_climb_speed',[],'slant_climb_speed',[], 'class', [], 'coolTime', []);

flight_sol = [];

for f = 2:num_flight
    flight.name   = flight_set_0(f).name;

    flight.ArrReqTime = flight_set_0(f).ArrReqTime;
    flight.ArrNodes   = flight_set_0(f).ArrNodes  ;
    flight.ArrEdges   = flight_set_0(f).ArrEdges  ;
    flight.ArrTLOF    = flight_set_0(f).ArrTLOF   ;
    flight.ArrFix_direction = flight_set_0(f).ArrFix_direction;

    flight.DepReqTime = flight_set_0(f).DepReqTime;
    flight.DepNodes   = flight_set_0(f).DepNodes  ;
    flight.DepEdges   = flight_set_0(f).DepEdges  ;
    flight.DepTLOF    = flight_set_0(f).DepTLOF   ;
    flight.DepFix_direction = flight_set_0(f).DepFix_direction;

    flight.taxi_speed   = flight_set_0(f).taxi_speed;
    flight.vertical_climb_speed   = flight_set_0(f).vertical_climb_speed;
    flight.slant_climb_speed   = flight_set_0(f).slant_climb_speed;
    flight.class   = flight_set_0(f).class;
    flight.coolTime   = flight_set_0(f).coolTime;
    flight.TAT  =  flight_set_0(f).TAT;

    flight.nodes = flight_set_0(f).nodes;
    flight.edges = flight_set_0(f).edges;

    flight.nodeTime = sort(t_iu(f-1,(t_iu(f-1,:) ~= 0)));

    flight.ArrTLOFtime = flight.nodeTime(find(flight.ArrTLOF == flight.nodes,1));
    flight.DepTLOFtime = flight.nodeTime(find(flight.DepTLOF == flight.nodes,1));

    flight.ArrGateTime = flight.nodeTime(find(string(flight.ArrNodes(end)) == flight.nodes));
    flight.DepGateTime = flight.nodeTime(find(string(flight.DepNodes(1)) == flight.nodes));

    flight.ArrfixTimeTaken =  flight.nodeTime(2) - flight.nodeTime(1);
    flight.ArrTLOFTimeTaken =  flight.ArrTLOFtime - flight.nodeTime(2);
    flight.ArrTLOFexitTimeTaken = flight.nodeTime(4) - flight.ArrTLOFtime;
    flight.ArrTaxiTimeTaken = flight.ArrGateTime - flight.nodeTime(5);

    flight.ArrTotalTimeTaken = flight.ArrGateTime  - flight.nodeTime(1);

    flight.DepfixTimeTaken =  flight.nodeTime(end) - flight.nodeTime(end-1);
    flight.DepTLOFexitTimeTaken = flight.nodeTime(end-1) - flight.DepTLOFtime;
    flight.DepTLOFTimeTaken =  flight.DepTLOFtime - flight.nodeTime(end-3);
    flight.DepTaxiTimeTaken = flight.nodeTime(end-3) - flight.DepGateTime; % Last node, LaunchpadNode, Climb_a, Climb_b
    flight.DepGateDelay = flight.DepGateTime - flight.DepReqTime;

    flight.DepTotalTimeTaken = flight.nodeTime(end) - flight.DepGateTime;
    flight.TurnAroundTime    = flight.DepGateTime - flight.ArrGateTime;

    flight.TotalTimeTaken = flight.nodeTime(end) - flight.nodeTime(1);

    zeroTime = zeroDelayTime(flight);
    flight.zeroDelayTime = sum(zeroTime) + flight.coolTime + flight.TAT;

    flight.delay = flight.TotalTimeTaken - flight.zeroDelayTime;

    flight_sol = [flight_sol flight];
end

outputs.flight_sol_set = flight_sol;

if num_flight > 2
    if isfield(vertioptSoln, 'x_uij')
        outputs.wakeConstr = calc_wake_separationConstr(flight_set_0, inputs, t_iu, x_uij);
        outputs.wake_sep = calc_wake_separationActual(flight_set_0, inputs, t_iu, x_uij);
    else
        [outputs.wakeConstrArr, outputs.wakeConstrDep] = calc_wake_separationConstr(flight_set_0, inputs, t_iu, y_uij);
        [outputs.wake_sepArr, outputs.wake_sepDep] = calc_wake_separationActual(flight_set_0, inputs, t_iu, y_uij);
    end
end
end

%% Functions

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

function timetaken = zeroDelayTime(flight)

timeOnTaxiArr = 0; timeOnTaxiDep = 0;
global descentDelay

timeOnapproach = max(timeonedge(flight, flight.ArrEdges(1)) -5,1);
timeOnOVFArr = max(timeonedge(flight, flight.ArrEdges(2)) -5,1);

for e = 4:(length(flight.ArrEdges)) % Last taxi node to TLOF not counted
    timeOnTaxiArr = timeOnTaxiArr + max(timeonedge(flight, flight.ArrEdges(e)) -5,1);
end


for e = 1:(length(flight.DepEdges)-3) % Last taxi node to TLOF not counted
    timeOnTaxiDep = timeOnTaxiDep + max(timeonedge(flight, flight.DepEdges(e)) -5,1);
end

timeOnOVFDep = max(timeonedge(flight, flight.DepEdges(end-1)) -5,1);
timeOnclimb =  max(timeonedge(flight, flight.DepEdges(end)) -5,1);

timetaken = [timeOnapproach, timeOnOVFArr, timeOnTaxiArr , timeOnTaxiDep, timeOnOVFDep, timeOnclimb];

end

function [wake_sepArr, wake_sepDep] = calc_wake_separationConstr(flight_set_0, inputs, t_iu, z_uij)

nodes = inputs.Nodes;
twake = inputs.Twake;
wake_sepArr = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).ArrTLOF;
        r2 = flight_set_0(f2).ArrTLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            Rsepij = twake(flight_set_0(f1).class, flight_set_0(f2).class);
            wake_sepArr(f1-1,f2-1) = z_uij(r,f1,f2) * (t_iu(f2-1,r) - (t_iu(f1-1,r) - Rsepij));
        end
    end
end

wake_sepDep = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).DepTLOF;
        r2 = flight_set_0(f2).DepTLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            Rsepij = twake(flight_set_0(f1).class, flight_set_0(f2).class);
            wake_sepDep(f1-1,f2-1) = z_uij(r,f1,f2) * (t_iu(f2-1,r) - (t_iu(f1-1,r) - Rsepij));
        end
    end
end
end

function [wake_sepArr, wake_sepDep] = calc_wake_separationActual(flight_set_0, inputs, t_iu, z_uij)

nodes = inputs.Nodes;
wake_sepArr = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).ArrTLOF;
        r2 = flight_set_0(f2).ArrTLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            wake_sepArr(f1-1,f2-1) = (t_iu(f2-1,r) - (t_iu(f1-1,r))) * z_uij(r,f1,f2);
        end
    end
end

wake_sepDep = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).DepTLOF;
        r2 = flight_set_0(f2).DepTLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            wake_sepDep(f1-1,f2-1) = (t_iu(f2-1,r) - (t_iu(f1-1,r))) * z_uij(r,f1,f2);
        end
    end
end
end
