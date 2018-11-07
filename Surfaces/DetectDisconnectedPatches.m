%% Detect if the vertices which belong to one parcel/region are in disconnected patches.
%
% ARGUMENTS:
%           TR    -- a matlab TriRep object of the global surface.
%           v_idx -- vector with the vertex indices that belong to the same 
%                    anatomical region.
%
% OUTPUT: 
%          Maximum number of patches that make up that region -- an integer 
%
% REQUIRES: 
%          TriRep -- A Matlab object, not yet available in Octave.
%          GetLocalSurface() -- Returns a local patch of surface of the 
%                               neighbourhood around a vertex. Is in the
%                               Surfaces/ directory.
%
% USAGE:
%{    
   
   
%}
% Paula Sanz-Leon (2018-11-07)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% How to detect if there is more than one component in the local surface
% that belongs to one region
% This script tries t

function [number_of_components, varargout] = DetectDisconnectedPatches(TR, v_idx)

    [LocalVertices, LocalTriangles, ~] = GetLocalSurface(TR, v_idx.', 1);

    tr_local = triangulation(LocalTriangles, LocalVertices(:, 1), LocalVertices(:, 2), LocalVertices(:, 3));

% Use Matlab's graph functions
    G = graph;
    s = tr_local.ConnectivityList(:, 1);
    t = tr_local.ConnectivityList(:, 2);
    u = tr_local.ConnectivityList(:, 3);

% Remove duplicate edges - matlab does not support this
    st = unique(sort([s, t],2),'rows');
    tu = unique(sort([t, u],2),'rows');
    su = unique(sort([u, s],2),'rows');
    edge_list = [st; tu; su];
    unique_edge_list = unique(sort(edge_list,2),'rows');

    G = addedge(G, unique_edge_list(:, 1), unique_edge_list(:, 2));
    [bins] = conncomp(G);

    number_of_components = max(bins);

% Visual debugging 
if visual_debug
    % Take the first v_idx nodes -- those are the central focal vertices
    % This works because of the sorting we did above.
  
   h = plot(G, 'EdgeColor', [0.5 0.5 0]);
   highlight(h,[1:length(v_idx)],'NodeColor','r')
   highlight(h,[length(v_idx)+1:size(LocalVertices, 1)],'NodeColor','g')
   varargout{1} = h;
end

end