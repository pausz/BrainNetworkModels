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

function [number_of_components, largest_component, lc_size, bad_vertices, varargout] = DetectDisconnectedPatches(TR, v_idx, visual_debug)
if nargin < 3
    visual_debug = 0;
end
    [LocalVertices, LocalTriangles, ~] = GetLocalSurface(TR, v_idx.', 1);

    tr_local = triangulation(LocalTriangles, LocalVertices(:, 1), LocalVertices(:, 2), LocalVertices(:, 3));

% Use Matlab's graph functions
    G = graph;
    s = tr_local.ConnectivityList(:, 1);
    t = tr_local.ConnectivityList(:, 2);
    u = tr_local.ConnectivityList(:, 3);

% Remove duplicate edges - matlab's graph fn does not support it
    st = unique(sort([s, t],2),'rows');
    tu = unique(sort([t, u],2),'rows');
    su = unique(sort([u, s],2),'rows');
    edge_list = [st; tu; su];
    unique_edge_list = unique(sort(edge_list,2),'rows');

    G = addedge(G, unique_edge_list(:, 1), unique_edge_list(:, 2));
    [bins] = conncomp(G);
    number_of_components = max(bins);

    % Get largest component based on focal vertices
    [n, e] = histcounts(bins(1:length(v_idx)));
    
    these_bins = e(2:end)-e(1); 
    [lc_size, this_bin] = max(n);
    
    largest_component = these_bins(this_bin);
    % Vertices in disconnected patches - corresponds to i-th vertex in TR
    bad_vertices = v_idx((bins(1:length(v_idx)) ~=largest_component));
    
% Visual debugging 
if visual_debug
    % Take the first v_idx nodes -- those are the central focal vertices
    % This works because of the sorting we did above.
   GraphPlotFigureHandle = figure;
   GraphPlotHandle = plot(G, 'EdgeColor', [0.5 0.5 0]);
   highlight(h,1:length(v_idx),'NodeColor','r')
   highlight(h,length(v_idx)+1:size(LocalVertices, 1),'NodeColor','g')
   varargout{1} = GraphPlotFigureHandle;
   varargout{2} = GraphPlotHandle;
end

end