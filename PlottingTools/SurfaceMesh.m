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

function [ThisFigure, SurfaceHandle] = SurfaceMesh(Surface, SurfaceShading)

%% Display info
 ThisScreenSize = get(0,'ScreenSize');
 FigureWindowSize = ThisScreenSize + [ThisScreenSize(3)./4 ,ThisScreenSize(4)./16, -ThisScreenSize(3)./2 , -ThisScreenSize(4)./8];
   
 
%% Initialise figure  
 ThisFigure = gcf;
 set(ThisFigure,'Position',FigureWindowSize);
 
  
%% Colour Surface by Region
 if nargin<2,
   SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
     'Edgecolor', [0 0 0], 'FaceColor', [0.8 0.8 0.8]);
 else
   switch length(SurfaceShading),
     case size(Surface.Points,1)
       SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
                             'Edgecolor', [0 0 0], 'FaceColor', 'interp', 'FaceVertexCData', SurfaceShading.'); %
   
     case size(Surface.ConnectivityList,1)
       SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
                             'Edgecolor', [0 0 0], 'FaceColor', 'flat',  'FaceVertexCData', SurfaceShading.'); %
   end
   title(['Shading represents:' inputname(2)], 'interpreter', 'none');
 end

 % Axes and Mesh plotting properties
 material dull
 colormap(brewermap([], 'Reds'))
 
 xlabel('X (mm)');
 ylabel('Y (mm)');
 zlabel('Z (mm)');
 
 set(gca, 'CameraViewAngle', 7);
 %set(gca, 'CameraUpVector', [-0.25 0.44 0.86]);
 %set(gca, 'CameraPosition', [664 -1238 768]);
 view(3)
 grid on;
 light;
 lighting phong;
 camlight('left');
 daspect([1 1 1])
 
%keyboard                       


end  %function SurfaceMesh()
