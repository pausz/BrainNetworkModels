%% Plot the cortical surface emphasising mesh. 
%
% ARGUMENTS:
%          Surface -- triangulation object of cortical surface.
%
% OUTPUT: 
%      ThisFigure       -- Handle to overall figure object.
%      SurfaceHandle    -- Handle to patch object, cortical surface.
%
% REQUIRES: 
%        triangulation -- A Matlab object, not yet available in Octave.
%
% USAGE:
%{     
       ThisSurface = '213';
       load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles', 'VertexNormals'); 
       tr = triangulation(Triangles, Vertices);
       SurfaceCurvature = GetSurfaceCurvature(tr, VertexNormals);

       SurfaceMesh(tr, SurfaceCurvature)
%}
%
% MODIFICATION HISTORY:
%     SAK(13-01-2011) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%     PSL(Jul 2015)   -- TAG: MatlabR2015a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ThisFigure, SurfaceHandle] = SurfaceMesh(Surface, SurfaceShading, Title)

%% Display info
 ThisScreenSize = get(0,'ScreenSize');
 FigureWindowSize = ThisScreenSize + [ThisScreenSize(3)./4 ,ThisScreenSize(4)./16, -ThisScreenSize(3)./2 , -ThisScreenSize(4)./8];
   
 
%% Initialise figure  
 ThisFigure = gcf;
 set(ThisFigure,'Position',FigureWindowSize);
%% Colours
 MinData = 0.0025;
 MaxData = 0.0404;
 EdgeColour = 'none';
 MAP = colormap(parula(256));
 ColourSteps = size(MAP,1);
 SurfaceShading = max(fix(((SurfaceShading-MinData) ./ (MaxData-MinData)) .* ColourSteps), 1); 

  
%% Colour Surface by Region
 if nargin<2,
   SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
     'Edgecolor', EdgeColour, 'FaceColor', [0.8 0.8 0.8]);
 else
   switch length(SurfaceShading),
     case size(Surface.Points,1)
       SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
                             'Edgecolor', EdgeColour, 'FaceColor', 'interp', 'FaceVertexCData', SurfaceShading.'); %
   
     case size(Surface.ConnectivityList,1)
       SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
                             'Edgecolor', EdgeColour, 'FaceColor', 'flat',  'FaceVertexCData', SurfaceShading.'); %
   end
   title(['T:' num2str(Title) ' ms'], 'interpreter', 'none');
 end

 % Axes and Mesh plotting properties
 material shiny
 set(SurfaceHandle,'FaceLighting','gouraud','AmbientStrength',0.3, 'SpecularStrength', 0.2)
 
 lightangle(-90, 20)
 view([-90, 0])
 daspect([1 1 1])
 %ColorBarHandle = colorbar;
 %set(ColorBarHandle, 'location', 'southoutside')
 %set(ColorBarHandle,'ytick',linspace(1,ColourSteps,2))
 %set(ColorBarHandle, 'yticklabel', linspace(MinData, MaxData,2))
 colormap(brewermap([256], 'Reds'))
    
  
 %caxis(ThisFigure, 'manual');
 caxis([1 ColourSteps]);
 
 xlabel('X (mm)');
 ylabel('Y (mm)');
 zlabel('Z (mm)');
 
%  set(gca, 'CameraViewAngle', 7);
%  %set(gca, 'CameraUpVector', [-0.25 0.44 0.86]);
%  %set(gca, 'CameraPosition', [664 -1238 768]);
%  view(3)
%  grid on;
%  light;
  lighting phong;
%  camlight('left');
%  daspect([1 1 1])
 
%keyboard                       


end  %function SurfaceMesh()
