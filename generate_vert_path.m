function [flight_path_nodes_arr, flight_path_edges_arr, flight_path_nodes_dep, flight_path_edges_dep] = generate_vert_path(Nodes, Edges)
% creating Graph
edges_split = cellfun(@(e) split(e, '-'), Edges.all, 'UniformOutput', false);
u = cellfun(@(e) e{1}, edges_split, 'UniformOutput', false);
v = cellfun(@(e) e{2}, edges_split, 'UniformOutput', false);
G = digraph(u,v);

% Define arrival and departure directions
directions = [Nodes.dir];


% Initialize empty lists for flight path nodes and edges
flight_path_nodes_arr = {};
flight_path_edges_arr = {};
flight_path_nodes_dep = {};
flight_path_edges_dep = {};



% Loop through arrival directions
for i = 1:length(directions)
  startNode = directions{i};
  % Find all paths from current direction to all gates and Extract nodes and edges
  for g = 1:length(Nodes.gates)
    endNode = Nodes.gates{g};
    node_paths = allpaths(G, startNode, endNode, 'MaxNumPaths',1);
    flight_path_nodes_arr{end+1} = node_paths{1};
    flight_path_edges_arr{end+1} = createEdgesFromPath(node_paths{1});
  end
end

% Loop through departure gates
for g = 1:length(Nodes.gates)
  startNode = Nodes.gates{g};
  for i = 1:length(directions)
      endNode = directions{i};
      % Find all paths from current gate to all TLOF exits
      node_paths = allpaths(G, startNode, endNode, 'MaxNumPaths',1);

      % Extract nodes and edges from paths
      flight_path_nodes_dep{end+1} = node_paths{1};
      flight_path_edges_dep{end+1} = createEdgesFromPath(node_paths{1});
  end
end
end 

function edges = createEdgesFromPath(nodes)
  % Initialize empty list for edges
  edges = cell(1,length(nodes)-1);
  
  % Loop through consecutive nodes in the path
  for i = 1:length(nodes) - 1
    % Create edge string from current and next node
    edge = strcat(nodes{i}, '-', nodes{i+1});
    % Add edge to the list
    edges{i} = edge;
  end
end

