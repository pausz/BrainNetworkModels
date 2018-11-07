% How to detect if there is more than one component in the local surface
% that belongs to one region
% This script tries t

function [number_of_components] = untitledDetectDisconnectedPatches(TR, v_idx)

[LocalVertices, LocalTriangles, ~] = GetLocalSurface(TR, v_idx.', 1);

tr_local = triangulation(LocalTriangles, LocalVertices(:, 1), LocalVertices(:, 2), LocalVertices(:, 3));

G = graph;
s = tr_local.ConnectivityList(:, 1);
t = tr_local.ConnectivityList(:, 2);
u = tr_local.ConnectivityList(:, 3);

% Remove duplicate edges - matlab does not support this
st = unique(sort([s, t],2),'rows');
tu = unique(sort([t, u],2),'rows');
su = unique(sort([u, s],2),'rows');
edge_list = [st; tu; su];
uniqueEdgeList = unique(sort(edge_list,2),'rows');

G = addedge(G, uniqueEdgeList(:, 1), uniqueEdgeList(:, 2));
[bins] = conncomp(G);

number_of_components = max(bins);

% Take the first v_idx nodes -- those are the central focal vertices
% This works because of the sorting we did above.

LocalVertexColor = [1 0 0];
OtherVertexColor = [0 1 0];

  
%h = plot(G, 'EdgeColor', [0.5 0.5 0]);
%highlight(h,[1:length(v_idx)],'NodeColor','r')
%highlight(h,[length(v_idx)+1:size(LocalVertices, 1)],'NodeColor','g')


end