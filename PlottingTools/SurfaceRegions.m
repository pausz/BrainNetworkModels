%% Colour the cortical surface by region. 
%
% ARGUMENTS:
%        Surface -- triangulation object of cortical surface.
%        options -- a structure that contains the associated Connectivity
%                   matrix and RegionMapping.
%        ThisColourMap -- N x 3 array defining a colourmap. 
%        ThisRegionIndex -- An integer to select one specific region. It
%                           should be included in RegionMapping.
%
% OUTPUT: 
%        ThisFigure        -- Handle to overall figure object.
%        SurfaceHandle     -- Handle to patch object, cortical surface.
%
% REQUIRES: 
%        triangulation -- A Matlab object, not yet available in Octave.
%
% USAGE:
%{     
       ThisSurface = 'reg13';
       load(['Surfaces' filesep 'Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles');  % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
       tr = triangulation(Triangles, Vertices);

       options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
       options.Connectivity.hemisphere = 'both';
       options.Connectivity.RemoveThalamus = true;
       options.Connectivity = GetConnectivity(options.Connectivity)
        
       load(['Surfaces' filesep 'RegionMapping_' ThisSurface '_O52R00_IRP2008.mat'])
       options.Connectivity.RegionMapping = RegionMapping;

       [ThisFigure SurfaceHandle] = SurfaceRegions(tr, options)

%}
%
% MODIFICATION HISTORY:
%     SAK(13-01-2011) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%     PSL(Jul 2015)   -- TAG: MatlabR2015a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ThisFigure, SurfaceHandleOne] = SurfaceRegions(Surface, options, ThisColourMap, ThisRegionIndex)
%% Set any argument that weren't specified
  if nargin < 3,
    ThisColourMap  = 'RegionColours74';
    ThisRegionIndex = []; 
  end
  if nargin < 4,
     ThisRegionIndex = [];
  end
          

%% Data info
  NumberOfRegions = length(unique(options.Connectivity.RegionMapping));
  ThisRegionColour = [0.75 0.75 0.75];
  ThisVertexColour = [1 0 0];
  NumberOfVertices = size(Surface.Points, 1);
  NumberOfTriangles = size(Surface.ConnectivityList, 1);

%% Display info
  ThisScreenSize = get(0,'ScreenSize');
  FigureWindowSize = ThisScreenSize + [ThisScreenSize(3)./4 ,ThisScreenSize(4)./16, -ThisScreenSize(3)./2 , -ThisScreenSize(4)./8];

%% Initialise figure  
  ThisFigure = figure;
  set(ThisFigure,'Position',FigureWindowSize);
%% Get Colourmap  
  if ischar(ThisColourMap),
      load(ThisColourMap);
      cmap = map; 
  else
      cmap = ThisColourMap;
  end
  colormap(ThisFigure, cmap)

  %%RegionLabels = cellfun(@(x) x(2:end), options.Connectivity.NodeStr(1:end/2), 'UniformOutput', false);

%% Colour Surface by Region or Colour One Region and overlay a 3D scatter plot.

% Handle the cases for colouring all regions or just one
if length(ThisRegionIndex) < 1,
  FaceVertexData = options.Connectivity.RegionMapping;
  EdgeColour = 'interp';
  step = (length(options.Connectivity.NodeStr)-1) / length(options.Connectivity.NodeStr);
  colorbar('YTick', 0.5:step:(length(options.Connectivity.NodeStr)-1), 'YTickLabel', options.Connectivity.NodeStr, 'Ylim', [0, length(options.Connectivity.NodeStr)-1]);
else
  FaceVertexData = 0.77*ones(size(Surface.Points));
  FaceVertexData(options.Connectivity.RegionMapping == ThisRegionIndex,:) = repmat(ThisRegionColour, [sum(options.Connectivity.RegionMapping == ThisRegionIndex) 1]);
  EdgeColour = 'interp';
  ScatterHandle = scatter3(Surface.Points(options.Connectivity.RegionMapping == ThisRegionIndex, 1), Surface.Points(options.Connectivity.RegionMapping == ThisRegionIndex, 2), Surface.Points(options.Connectivity.RegionMapping == ThisRegionIndex, 3), 42, 'filled');
  set(ScatterHandle,'MarkerFaceColor',ThisVertexColour)
  legend(options.Connectivity.NodeStr(ThisRegionIndex))
  hold;
end    
  SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:NumberOfTriangles,:) , 'Vertices', Surface.Points, ...
    'Edgecolor',EdgeColour, 'FaceColor', 'interp', 'FaceVertexCData', FaceVertexData); %

  set(SurfaceHandle, 'FaceAlpha', 0.8)

  material dull
  light;
  lighting phong;
  camlight('left');
  
  title(datestr(clock), 'interpreter', 'none');
  xlabel('X (mm)');
  ylabel('Y (mm)');
  zlabel('Z (mm)');
  daspect([1 1 1])
%keyboard                       

end %function SurfaceRegions()
