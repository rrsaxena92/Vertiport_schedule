function outputs = validateOptSol(vertioptSoln, flight_set, inputs)


twake = inputs.Twake;
Edges = inputs.Edges;
nodes = inputs.Nodes;
num_flight = length(flight_set);
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

if isempty(find("0-0-0"==[flight_set.name], 1))  % For bakcward compability when dummy 0 aircraft was used
    startIdx = 1;
else
    startIdx = 2;
end

for f = startIdx:num_flight
    flight.name   = flight_set(f).name;
    flight.reqTime   = flight_set(f).reqTime;
    flight.direction   = flight_set(f).direction;
    flight.nodes   = flight_set(f).nodes;
    flight.edges   = flight_set(f).edges;
    flight.TLOF   = flight_set(f).TLOF;
    flight.fix_direction   = flight_set(f).fix_direction;
    flight.taxi_speed   = flight_set(f).taxi_speed;
    flight.vertical_climb_speed   = flight_set(f).vertical_climb_speed;
    flight.slant_climb_speed   = flight_set(f).slant_climb_speed;
    flight.class   = flight_set(f).class;
    flight.coolTime   = flight_set(f).coolTime;
    flight.nodeTime = sort(t_iu(f-(startIdx-1),(t_iu(f-(startIdx-1),:) ~= 0)));

    if flight.direction == "arr"
        flight.TLOFtime = flight.nodeTime(3);
        flight.fixTimeTaken =  flight.nodeTime(2) - flight.nodeTime(1);
        flight.TLOFTimeTaken =  flight.TLOFtime - flight.nodeTime(2);
        flight.TLOFexitTimeTaken = flight.nodeTime(4) - flight.TLOFtime;
        flight.TaxiTimeTaken = flight.nodeTime(end) - flight.nodeTime(4);
        flight.GateTime = flight.nodeTime(end);
        flight.TotalTimeTaken = flight.nodeTime(end) - flight.nodeTime(1);

        zeroTime = zeroDelayTime(flight);
        flight.OFVdelay = flight.TLOFTimeTaken - zeroTime(2);
        flight.zeroDelayTime = sum(zeroTime) + flight.coolTime;

    else % dep
        flight.TLOFtime = flight.nodeTime(end-2);
        flight.fixTimeTaken =  flight.nodeTime(end) - flight.nodeTime(end-1);
        flight.TLOFexitTimeTaken = flight.nodeTime(end-1) - flight.TLOFtime;
        flight.TLOFTimeTaken =  flight.TLOFtime - flight.nodeTime(end-3);
        flight.TaxiTimeTaken = flight.nodeTime(end-3) - flight.nodeTime(1); % Last node, LaunchpadNode, Climb_a, Climb_b
        flight.GateTime = flight.nodeTime(1) - flight.reqTime;
        flight.TotalTimeTaken = flight.nodeTime(end) - flight.nodeTime(1) + flight.GateTime;

        zeroTime = zeroDelayTime(flight);
        flight.OFVdelay = flight.TLOFexitTimeTaken - zeroTime(2);
        flight.zeroDelayTime = sum(zeroTime);
    end

    flight.Taxidelay = flight.TaxiTimeTaken - zeroTime(1);
    flight.fixDelay = flight.fixTimeTaken -zeroTime(3);
    flight.delay = flight.TotalTimeTaken - flight.zeroDelayTime;
    flight_sol = [flight_sol flight];
end

outputs.flight_sol_set = flight_sol;

if num_flight > 2
if isfield(vertioptSoln, 'x_uij')
    outputs.wakeConstr = calc_wake_separationConstr(flight_set, inputs, t_iu, x_uij);
    outputs.wake_sep = calc_wake_separationActual(flight_set, inputs, t_iu, x_uij);
else
    outputs.wakeConstr = calc_wake_separationConstr(flight_set, inputs, t_iu, y_uij);
    outputs.wake_sep = calc_wake_separationActual(flight_set, inputs, t_iu, y_uij);
end
end
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

function wake_sep = calc_wake_separationConstr(flight_set_0, inputs, t_iu, z_uij)

nodes = inputs.Nodes;
twake = inputs.Twake;
wake_sep = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).TLOF;
        r2 = flight_set_0(f2).TLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            Rsepij = twake(flight_set_0(f1).class, flight_set_0(f2).class);
            wake_sep(f1-1,f2-1) = z_uij(r,f1,f2) * (t_iu(f2-1,r) - (t_iu(f1-1,r) - Rsepij));
        end
    end
end
end

function wake_sep = calc_wake_separationActual(flight_set_0, inputs, t_iu, z_uij)

nodes = inputs.Nodes;
wake_sep = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).TLOF;
        r2 = flight_set_0(f2).TLOF;

        if (f1 ~= f2) && (r1 == r2)
            r = find(nodes.all == r1,1);
            wake_sep(f1-1,f2-1) = (t_iu(f2-1,r) - (t_iu(f1-1,r))) * z_uij(r,f1,f2);
        end
    end
end

end
