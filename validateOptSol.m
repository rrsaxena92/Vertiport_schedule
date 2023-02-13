function outputs = validateOptSol(vertioptSoln, flight_set_0, inputs)


twake = inputs.Twake;
Edges = inputs.Edges;
nodes = inputs.Nodes;
% W_r = 7;
% W_q = 2;
% Wa_c = 3;
% Wd_c = 3;
% W_g = 1;
%
% M = 200;
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
    flight.reqTime   = flight_set_0(f).reqTime;
    flight.direction   = flight_set_0(f).direction;
    flight.nodes   = flight_set_0(f).nodes;
    flight.edges   = flight_set_0(f).edges;
    flight.TLOF   = flight_set_0(f).TLOF;
    flight.fix_direction   = flight_set_0(f).fix_direction;
    flight.taxi_speed   = flight_set_0(f).taxi_speed;
    flight.vertical_climb_speed   = flight_set_0(f).vertical_climb_speed;
    flight.slant_climb_speed   = flight_set_0(f).slant_climb_speed;
    flight.class   = flight_set_0(f).class;
    flight.coolTime   = flight_set_0(f).coolTime;
    flight.nodeTime = t_iu(f-1,(t_iu(f-1,:) ~= 0));
    flight.TLOFtime = flight.nodeTime(end-2);
    if flight.direction == "arr"
        flight.fixTimeTaken =  flight.nodeTime(end-1) - flight.nodeTime(end);
        flight.TLOFTimeTaken =  flight.TLOFtime - flight.nodeTime(end-1);
        flight.TLOFexitTimeTaken = flight.nodeTime(end-3) - flight.TLOFtime;
        flight.TaxiTimeTaken = flight.nodeTime(1) - flight.nodeTime(end-3);
        flight.GateTime = flight.nodeTime(1) - flight.nodeTime(2);
        flight.TotalTimeTaken = flight.nodeTime(1) - flight.nodeTime(end);
        zeroTime = zeroDelayTime(flight, Edges);
        flight.zeroDelayTime = sum(zeroTime) + flight.coolTime;
    else % dep
        flight.fixTimeTaken =  flight.nodeTime(end) - flight.nodeTime(end-1);
        flight.TLOFexitTimeTaken = flight.nodeTime(end-1) - flight.TLOFtime;
        flight.TLOFTimeTaken =  flight.TLOFtime - flight.nodeTime(end-3);
        flight.TaxiTimeTaken = flight.nodeTime(end-3) - flight.nodeTime(1); % Last node, LaunchpadNode, Climb_a, Climb_b
        flight.GateTime = flight.nodeTime(1) - flight.reqTime;
        flight.TotalTimeTaken = flight.nodeTime(end) - flight.nodeTime(1) + flight.GateTime;
        flight.zeroDelayTime = sum(zeroDelayTime(flight, Edges));
    end

    flight.delay = flight.TotalTimeTaken - flight.zeroDelayTime;

    flight_sol = [flight_sol flight];
end

outputs.flight_sol_set = flight_sol;

if isfield(vertioptSoln, 'x_uij')
    outputs.wakeConstr = calc_wake_separationConstr(flight_set_0, inputs, t_iu, x_uij);
    outputs.wake_sep = calc_wake_separationActual(flight_set_0, inputs, t_iu, x_uij);
else
    outputs.wakeConstr = calc_wake_separationConstr(flight_set_0, inputs, t_iu, y_uij);
    outputs.wake_sep = calc_wake_separationActual(flight_set_0, inputs, t_iu, y_uij);
end

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


function timetaken = zeroDelayTime(flight, Edges)

timeOnTaxi = 0;
if flight.direction == "arr"
    timeOnapproach = (get_edge_length(flight.edges(1), Edges)/flight.slant_climb_speed)-5;
    timeOnOVF = (get_edge_length(flight.edges(2), Edges)/flight.vertical_climb_speed)-5;

    for e = 4:(length(flight.edges)) % Last taxi node to TLOF not counted
        timeOnTaxi = timeOnTaxi + (get_edge_length(flight.edges(e), Edges)/flight.taxi_speed)-5;
    end
    timetaken = [timeOnTaxi, timeOnOVF, timeOnapproach];

else % dep
    for e = 1:(length(flight.edges)-3) % Last taxi node to TLOF not counted
        timeOnTaxi = max(timeOnTaxi + (get_edge_length(flight.edges(e), Edges)/flight.taxi_speed) - 5,0);
    end

    timeOnOVF = max((get_edge_length(flight.edges(end-1), Edges)/flight.vertical_climb_speed) - 5,0);
    timeOnclimb = max((get_edge_length(flight.edges(end), Edges)/flight.slant_climb_speed) - 5,0);
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
