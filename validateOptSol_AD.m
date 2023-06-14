function outputs = validateOptSol_AD(vertioptSoln, flight_set, inputs)

global Edges
% twake = inputs.Twake;
Edges = inputs.Edges;
% nodes = inputs.Nodes;
% gateCapacity = inputs.gateCap;


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

flight_sol_struct = struct("name",[],"type",[],"ArrReqTime",[],"DepReqTime",[],"Gate",[],"ArrTLOF",[],"ArrFix_direction",[],"DepTLOF",[],"DepFix_direction",[],"taxi_speed",[],"vertical_climb_speed",[],"slant_climb_speed",[],"class",[],"coolTime",[],"TAT",[],...
    "nodes",[],"edges",[],"nodeTime",[],"ArrNodes",[],"ArrEdges",[],"ArrTLOFtime",[],"ArrGateTime",...
    [],"ArrfixTimeTaken",[],"ArrTLOFTimeTaken",[],"ArrTLOFexitTimeTaken",[],"ArrTaxiTimeTaken",[],"ArrTotalTimeTaken",[],"ArrfixDelay",[],"ArrOFVdelay",...
    [],"ArrTaxidelay",[],"ArrZeroDelayTime",[],"TurnAroundTime",[],"DepNodes",[],"DepEdges",[],...
    "DepTLOFtime",[],"DepGateTime",[],"DepfixTimeTaken",[],"DepTLOFexitTimeTaken",[],"DepTLOFTimeTaken",[],"DepTaxiTimeTaken",[],"DepGateDelay",[],...
    "DepTotalTimeTaken",[],"DepTaxidelay",[],"DepOFVdelay",[],"DepfixDelay",[],"DepZeroDelayTime",[],"TotalTimeTaken",[],"zeroDelayTime",[],"delay",[]);

flight_sol = [];

for f = 1:num_flight
    flight.name   = flight_set(f).name;

    flight.type   = flight_set(f).type;
    flight.taxi_speed   = flight_set(f).taxi_speed;
    flight.vertical_climb_speed   = flight_set(f).vertical_climb_speed;
    flight.slant_climb_speed   = flight_set(f).slant_climb_speed;
    flight.class   = flight_set(f).class;
    flight.coolTime   = flight_set(f).coolTime;
    flight.TAT  =  flight_set(f).TAT;

    flight.nodes = flight_set(f).nodes;
    flight.edges = flight_set(f).edges;

    flight.nodeTime = sort(t_iu(f,(t_iu(f,:) ~= 0)));


    if flight.type == "arr"

        flight.ArrReqTime = flight_set(f).ArrReqTime;
        flight.ArrNodes   = flight_set(f).ArrNodes  ;
        flight.ArrEdges   = flight_set(f).ArrEdges  ;
        flight.ArrTLOF    = flight_set(f).ArrTLOF   ;
        flight.ArrFix_direction = flight_set(f).ArrFix_direction;
        flight.ArrTLOFtime = flight.nodeTime(find(flight.ArrTLOF == flight.nodes,1));
        flight.ArrGateTime = flight.nodeTime(find(string(flight.ArrNodes(end)) == flight.nodes));
        flight.ArrfixTimeTaken =  flight.nodeTime(2) - flight.nodeTime(1);
        flight.ArrTLOFTimeTaken =  flight.ArrTLOFtime - flight.nodeTime(2);
        flight.ArrTLOFexitTimeTaken = flight.nodeTime(4) - flight.ArrTLOFtime;
        flight.ArrTaxiTimeTaken = flight.ArrGateTime - flight.nodeTime(4);
        flight.ArrTotalTimeTaken = flight.ArrGateTime  - flight.nodeTime(1);

        zeroTime = zeroDelayTime(flight);
		flight.ArrfixDelay = flight.ArrfixTimeTaken -zeroTime(3);
        flight.ArrOFVdelay = flight.ArrTLOFTimeTaken - zeroTime(2);
		flight.ArrTaxidelay = flight.ArrTaxiTimeTaken - zeroTime(1);
        flight.ArrZeroDelayTime = sum(zeroTime) + flight.coolTime;
        flight.Gate = flight_set(f).Gate;

        flight.TurnAroundTime = 0;        

        flight.DepReqTime = 0;
        flight.DepNodes   = '';
        flight.DepEdges   = ''  ;
        flight.DepTLOF    = ''  ;
        flight.DepFix_direction = '';
        flight.DepTLOFtime = 0;
        flight.DepGateTime = 0;
        flight.DepfixTimeTaken =  0;
        flight.DepTLOFexitTimeTaken = 0;
        flight.DepTLOFTimeTaken =  0;
        flight.DepTaxiTimeTaken = 0;
        flight.DepGateDelay = 0;
        flight.DepTotalTimeTaken = 0;
		flight.DepTaxidelay = 0;
        flight.DepOFVdelay = 0;
		flight.DepfixDelay = 0;
        flight.DepZeroDelayTime = 0;

        flight.TotalTimeTaken = flight.ArrTotalTimeTaken;
        flight.zeroDelayTime = flight.ArrZeroDelayTime;

    end

    if flight.type == "dep"

        flight.ArrReqTime = 0;
        flight.ArrNodes   = '' ;
        flight.ArrEdges   = '' ;
        flight.ArrTLOF    = ''   ;
        flight.ArrFix_direction = 0;
        flight.ArrTLOFtime = 0;
        flight.ArrGateTime = 0;
        flight.ArrfixTimeTaken =  0;
        flight.ArrTLOFTimeTaken =  0;
        flight.ArrTLOFexitTimeTaken = 0;
        flight.ArrTaxiTimeTaken = 0;
        flight.ArrTotalTimeTaken = 0;
		flight.ArrfixDelay = 0;
        flight.ArrOFVdelay = 0;
		flight.ArrTaxidelay = 0;
        flight.ArrZeroDelayTime = 0;

        flight.TurnAroundTime = 0;
        flight.Gate = flight_set(f).Gate;

        flight.DepReqTime = flight_set(f).DepReqTime;
        flight.DepNodes   = flight_set(f).DepNodes  ;
        flight.DepEdges   = flight_set(f).DepEdges  ;
        flight.DepTLOF    = flight_set(f).DepTLOF   ;
        flight.DepFix_direction = flight_set(f).DepFix_direction;
        flight.DepTLOFtime = flight.nodeTime(find(flight.DepTLOF == flight.nodes,1));
        flight.DepGateTime = flight.nodeTime(find(string(flight.DepNodes(1)) == flight.nodes));
        flight.DepfixTimeTaken =  flight.nodeTime(end) - flight.nodeTime(end-1);
        flight.DepTLOFexitTimeTaken = flight.nodeTime(end-1) - flight.DepTLOFtime;
        flight.DepTLOFTimeTaken =  flight.DepTLOFtime - flight.nodeTime(end-3);
        flight.DepTaxiTimeTaken = flight.nodeTime(end-3) - flight.DepGateTime; % Last node, LaunchpadNode, Climb_a, Climb_b
        flight.DepGateDelay = flight.DepGateTime - flight.DepReqTime;
        flight.DepTotalTimeTaken = flight.nodeTime(end) - flight.DepGateTime + flight.DepGateDelay;
        zeroTime = zeroDelayTime(flight);
		flight.DepTaxidelay = flight.DepTaxiTimeTaken - zeroTime(1);
        flight.DepOFVdelay = flight.DepTLOFexitTimeTaken - zeroTime(2);
		flight.DepfixDelay = flight.DepfixTimeTaken -zeroTime(3);
        flight.DepZeroDelayTime = sum(zeroTime);
        
        flight.zeroDelayTime = flight.DepZeroDelayTime;
        flight.TotalTimeTaken = flight.DepTotalTimeTaken;
    end

    if flight.type == "tat"
        flight_tat.type   = flight.type;
        flight_tat.taxi_speed   = flight.taxi_speed;
        flight_tat.vertical_climb_speed   = flight.vertical_climb_speed;
        flight_tat.slant_climb_speed   = flight.slant_climb_speed;
        flight_tat.class   = flight.class;
        flight_tat.coolTime   = flight.coolTime;
        flight_tat.TAT  =  flight.TAT;     
        flight_tat.Gate = flight_set(f).Gate;

        if ~isempty(strfind(flight.name{:}, "_Arr"))
            flight_tat.ArrReqTime = flight_set(f).ArrReqTime;
            flight_tat.ArrNodes   = flight_set(f).ArrNodes  ;
            flight_tat.ArrEdges   = flight_set(f).ArrEdges  ;
            flight_tat.ArrTLOF    = flight_set(f).ArrTLOF   ;
            flight_tat.ArrFix_direction = flight_set(f).ArrFix_direction;
    
            flight_tat.ArrTLOFtime = flight.nodeTime(find(flight_tat.ArrTLOF == flight.nodes,1));
            flight_tat.ArrGateTime = flight.nodeTime(find(string(flight_tat.ArrNodes(end)) == flight.nodes));
            flight_tat.ArrfixTimeTaken =  flight.nodeTime(2) - flight.nodeTime(1);
            flight_tat.ArrTLOFTimeTaken =  flight_tat.ArrTLOFtime - flight.nodeTime(2);
            flight_tat.ArrTLOFexitTimeTaken = flight.nodeTime(4) - flight_tat.ArrTLOFtime;
            flight_tat.ArrTaxiTimeTaken = flight_tat.ArrGateTime - flight.nodeTime(4);
            flight_tat.ArrTotalTimeTaken = flight_tat.ArrGateTime  - flight.nodeTime(1);
            flight_tat.ArrnodeTime = flight.nodeTime;
            continue
        end

        if ~isempty(strfind(flight.name{:}, "_Dep"))
            flight_tat.DepReqTime = flight_set(f).DepReqTime;
            flight_tat.DepNodes   = flight_set(f).DepNodes  ;
            flight_tat.DepEdges   = flight_set(f).DepEdges  ;
            flight_tat.DepTLOF    = flight_set(f).DepTLOF   ;
            flight_tat.DepFix_direction = flight_set(f).DepFix_direction;
    
            flight_tat.DepTLOFtime = flight.nodeTime(find(flight_tat.DepTLOF == flight.nodes,1));
            flight_tat.DepGateTime = flight.nodeTime(find(string(flight_tat.DepNodes(1)) == flight.nodes));
            flight_tat.DepfixTimeTaken =  flight.nodeTime(end) - flight.nodeTime(end-1);
            flight_tat.DepTLOFexitTimeTaken = flight.nodeTime(end-1) - flight_tat.DepTLOFtime;
            flight_tat.DepTLOFTimeTaken =  flight_tat.DepTLOFtime - flight.nodeTime(end-3);
            flight_tat.DepTaxiTimeTaken = flight.nodeTime(end-3) - flight_tat.DepGateTime; % Last node, LaunchpadNode, Climb_a, Climb_b
            flight_tat.DepGateDelay = flight_tat.DepGateTime - flight_tat.DepReqTime;
            flight_tat.DepTotalTimeTaken = flight.nodeTime(end) - flight_tat.DepGateTime + flight_tat.DepGateDelay;
            flight_tat.DepnodeTime = flight.nodeTime;
            continue
        end

        if ~contains(string(flight.name), "_Arr") && ~contains(string(flight.name), "_Dep")

            flight_tat.name = flight.name;
            flight_tat.nodes = [flight_tat.ArrNodes flight.nodes flight_tat.DepNodes];
            flight_tat.nodeTime = [flight_tat.ArrnodeTime flight.nodeTime flight_tat.DepnodeTime];
            flight_tat.edges = [flight_tat.ArrEdges flight_tat.DepEdges];

            flight_tat.TurnAroundTime    = flight_tat.DepGateTime - flight_tat.ArrGateTime;
    
            zeroTime = zeroDelayTime(flight_tat);
            flight_tat.ArrfixDelay = flight_tat.ArrfixTimeTaken -zeroTime(1);
            flight_tat.ArrOFVdelay = flight_tat.ArrTLOFTimeTaken - zeroTime(2);
		    flight_tat.ArrTaxidelay = flight_tat.ArrTaxiTimeTaken - zeroTime(3);
            flight_tat.ArrZeroDelayTime = sum(zeroTime(1:3)) + flight.coolTime;
    
		    flight_tat.DepTaxidelay = flight_tat.DepTaxiTimeTaken - zeroTime(4);
            flight_tat.DepOFVdelay = flight_tat.DepTLOFexitTimeTaken - zeroTime(5);
		    flight_tat.DepfixDelay = flight_tat.DepfixTimeTaken -zeroTime(6);
            flight_tat.DepZeroDelayTime = sum(zeroTime(4:6));
            
            flight_tat.zeroDelayTime = flight_tat.ArrZeroDelayTime + flight_tat.DepZeroDelayTime + flight.TAT;
            flight_tat.TotalTimeTaken = flight_tat.nodeTime(end) - flight_tat.nodeTime(1);
            
            flight_tat = rmfield(flight_tat, ["ArrnodeTime", "DepnodeTime"]);
            clear flight
            flight = flight_tat;
        end
    end


    flight.delay = flight.TotalTimeTaken - flight.zeroDelayTime;
    flight = orderfields(flight,flight_sol_struct);

    flight_sol = [flight_sol flight];
end

outputs.flight_sol_set = flight_sol;

if num_flight > 2
    if isfield(vertioptSoln, 'x_uij')
        outputs.wakeConstr = calc_wake_separationConstr(flight_set, inputs, t_iu, x_uij);
        outputs.wake_sep = calc_wake_separationActual(flight_set, inputs, t_iu, x_uij);
    else
        [outputs.wakeConstrArr, outputs.wakeConstrDep] = calc_wake_separationConstr(flight_set, inputs, t_iu, y_uij);
        [outputs.wake_sepArr, outputs.wake_sepDep] = calc_wake_separationActual(flight_set, inputs, t_iu, y_uij);
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

global Edges %descentDelay

% descentDelay = 15;

if ismember(edge,{Edges.dir{:}})

    if ismember(edge,{flight.ArrEdges{:}})
        t = (get_edge_length(edge)/flight.slant_climb_speed);
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

timeOnTaxi = 0;
if flight.type == "arr"
    timeOnapproach = (get_edge_length(flight.ArrEdges(1))/flight.slant_climb_speed)-5;
    timeOnOVF = (get_edge_length(flight.ArrEdges(2))/flight.vertical_climb_speed)-5;

    for e = 4:(length(flight.ArrEdges)) % Last taxi node to TLOF not counted
        timeOnTaxi = timeOnTaxi + max((get_edge_length(flight.ArrEdges(e))/flight.taxi_speed) - 5,1);
    end
    timetaken = [timeOnTaxi, timeOnOVF, timeOnapproach];

elseif flight.type== "dep"
    for e = 1:(length(flight.DepEdges)-3) % Last taxi node to TLOF not counted
        timeOnTaxi = timeOnTaxi + max((get_edge_length(flight.DepEdges(e))/flight.taxi_speed) - 5,1);
    end

    timeOnOVF = max((get_edge_length(flight.DepEdges(end-1))/flight.vertical_climb_speed) - 5,1);
    timeOnclimb = max((get_edge_length(flight.DepEdges(end))/flight.slant_climb_speed) - 5,1);
    timetaken = [timeOnTaxi, timeOnOVF, timeOnclimb];

elseif flight.type== "tat"
    timeOnapproach = (get_edge_length(flight.ArrEdges(1))/flight.slant_climb_speed)-5;
    timeOnOVFArr = (get_edge_length(flight.ArrEdges(2))/flight.vertical_climb_speed)-5;

    timeOnTaxiArr = 0;
    for e = 4:(length(flight.ArrEdges)) % Last taxi node to TLOF not counted
        timeOnTaxiArr = timeOnTaxiArr + max((get_edge_length(flight.ArrEdges(e))/flight.taxi_speed) - 5,1);
    end

    timeOnTaxiDep  = 0;
    for e = 1:(length(flight.DepEdges)-3) % Last taxi node to TLOF not counted
        timeOnTaxiDep = timeOnTaxiDep + max((get_edge_length(flight.DepEdges(e))/flight.taxi_speed) - 5,1);
    end

    timeOnOVFDep = max((get_edge_length(flight.DepEdges(end-1))/flight.vertical_climb_speed) - 5,1);
    timeOnclimb = max((get_edge_length(flight.DepEdges(end))/flight.slant_climb_speed) - 5,1);
    
    timetaken = [timeOnapproach, timeOnOVFArr, timeOnTaxiArr , timeOnTaxiDep, timeOnOVFDep, timeOnclimb];
end

end

function [wake_sepArr, wake_sepDep] = calc_wake_separationConstr(flight_set_0, inputs, t_iu, z_uij)

nodes = inputs.Nodes;
twake = inputs.Twake;
wake_sepArr = -1*ones(length(flight_set_0)-1);
for f1 = 2:length(flight_set_0)
    for f2 = 2:length(flight_set_0)
        r1 = flight_set_0(f1).ArrTLOF;
        r2 = flight_set_0(f2).ArrTLOF;

        if any((f1 ~= f2)) && any(string(r1) == string(r2))
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

        if any((f1 ~= f2)) && any(string(r1) == string(r2))
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

        if any((f1 ~= f2)) && any(string(r1) == string(r2))
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

        if any((f1 ~= f2)) && any(string(r1) == string(r2))
            r = find(nodes.all == r1,1);
            wake_sepDep(f1-1,f2-1) = (t_iu(f2-1,r) - (t_iu(f1-1,r))) * z_uij(r,f1,f2);
        end
    end
end
end
