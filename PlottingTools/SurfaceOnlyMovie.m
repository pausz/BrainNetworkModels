%% Plot activity on the cortical surface as a movie, with a corresponding 
%  time series projection. 
%
% ARGUMENTS:
%          Surface -- TriRep object of cortical surface.
%          TimeSeries -- The timeseries (time-points, NumberOfVertices)
%          Mapping -- From vertices to timeseries you want to display,
%                     a simple subset, a region averaging, or 
%TODO: more complex mappings such as EEG/MEG/etc... 
%
% OUTPUT:
%      ThisFigure  -- Handle to overall figure object.
%      TheMovie    -- Matlab movie of the animation.
%
% USAGE:
%{     
       TR = TriRep(Triangles, Vertices);
       Step = 2^3;
       Duration = 2^14;
       SimulatedActivity = Store_phi_e(end-Duration+1:Step:end,:);
       SurfaceMovie(TR,SimulatedActivity,options.Connectivity.RegionMapping)

%NOTE: To convert a returned matlab movie (TheMovie) to .avi use
%      v = VideoWriter('test.avi')
       open(v);
       for kk=1:size(ThisMovie,2), writeVideo(v,ThisMovie(1, kk)), end
       close(v)
%}
%
% MODIFICATION HISTORY:
%     SAK(19-11-2010) -- Original.
%     PSL(24-10-2018) -- Derived.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TODO: Enable arg specification for colormap for the surface

function [ThisFigure, TheMovie] = SurfaceOnlyMovie(Surface, TimeSeries, Mapping, Time)
%% Set defaults for any argument that weren't specified
 if nargin<3,
    Mapping = 1:42;  
 end
 
 % Data info
 TimeSteps = size(TimeSeries, 1);
 
 if nargin<4,
   Time = 1:TimeSteps;
 end

 MaxData = max(TimeSeries(:));
 MinData = min(TimeSeries(:));
 
 
%% Display info
 ThisScreenSize = get(0,'ScreenSize');
 FigureWindowSize = ThisScreenSize + [ThisScreenSize([3,4])./8 , -800, -ThisScreenSize([4])./4];
   
%% Initialise figure  
  ThisFigure = figure;
  ThisFigure.Color = [1 1 1];
  set(ThisFigure,'Position',FigureWindowSize);
  SurfacePaneHandle = subplot('position',[0.01 0.01 0.95 0.95]);
    
%% Initialise Surface
 %Map timeseries to colormap indices
  %cmap = [linspace(0.5,1,256)', 0.5*ones(256,2)];
  %MAP = colormap(cmap);
  %MAP = colormap(colorcube);
  load('BlueGreyRed')
  MAP=colormap(BlueGreyRed);
  %ColourSteps = size(MAP,1);
  %TimeSeries = max(fix(((TimeSeries-MinData) ./ (MaxData-MinData)) .* ColourSteps), 1); 

   subplot(SurfacePaneHandle),
   SurfaceHandle = patch('Faces', Surface.Triangulation(1:1:end,:) , 'Vertices', Surface.X, ...
                         'Edgecolor','k', 'Edgealpha', 0.1, 'FaceColor', 'interp', 'FaceVertexCData', TimeSeries(1,:).'); %
   %material dull
   xlabel('X (mm)');
   ylabel('Y (mm)');
   zlabel('Z (mm)');
                       
   box on
   axis equal %daspect([1 1 1])
   colorbar('location','southoutside');
   %caxis(SurfacePaneHandle, 'manual');
   max_val = max(abs(TimeSeries(:)));
   caxis(SurfacePaneHandle, [-max_val/2 max_val/2]);
%keyboard                       

%% Movie: update surface colour and progress line in time series plot. 
 %Initialise structure to save movie
 if nargout>1, 
   TheMovie(1,1:TimeSteps) = getframe(ThisFigure);
 end
 
 for k = 1:TimeSteps,
   set(SurfaceHandle, 'FaceVertexCData', TimeSeries(k,:).')
   
   %Save movie
   if nargout>1,
     TheMovie(1,k) = getframe(ThisFigure);
   end
 end
   

end  %SurfaceMovie()
