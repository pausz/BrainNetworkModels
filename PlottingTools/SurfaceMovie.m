%% Plot activity on the cortical surface as a movie, with a corresponding 
%  time series projection. 
%
% ARGUMENTS:
%        Surface    -- TriRep object of cortical surface.
%        TimeSeries -- The timeseries (time-points, NumberOfVertices)
%        Mapping    -- From vertices to timeseries you want to display,
%                   a simple subset, a region averaging, or 
%TODO: more complex mappings such as EEG/MEG/etc... 
%
% OUTPUT:
%        ThisFigure  -- Handle to overall figure object.
%        TheMovie    -- Matlab movie of the animation.
%
% REQUIRES: 
%        triangulation -- A Matlab 'triangulation' object, not yet available in Octave.
% USAGE:
%{     
       TR = triangulation(Triangles, Vertices);
       Step = 2^3;
       Duration = 2^14;
       SimulatedActivity = Store_phi_e(end-Duration+1:Step:end,:);
       SurfaceMovie(TR,SimulatedActivity,options.Connectivity.RegionMapping)

%NOTE: To convert a returned matlab movie (TheMovie) to .mpeg use
%      mpgwrite(TheMovie, jet, 'MyNewMovieName.mpeg'); 
%}
%
% MODIFICATION HISTORY:
%     SAK(19-11-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%     PSL(July 2015)  -- TAG: MatlabR2015a
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TODO: Make Mapping a structure containg a projection matrix & cell array 
%      of names for projected time series, add legend to timeseries...

%TODO: Enable arg specification of 3D orientation and lighting.

%TODO: Consider adding pause and reverse play feature... 

function [ThisFigure, TheMovie] = SurfaceMovie(Surface, TimeSeries, options, Time)
%% Set defaults for any argument that weren't specified
  if nargin<3,
    Mapping = 1:42;  
  else
    Mapping = options.Connectivity.RegionMapping;
    NodeStr = options.Connectivity.NodeStr;
  end
  
  % Data info
  NumberOfVertices = length(Surface.Points);
  TimeSteps        = size(TimeSeries, 1);
  
  if nargin<4,
    Time = 1:TimeSteps;
  end
  
  MaxData = max(TimeSeries(:));
  MinData = min(TimeSeries(:));

%% Display info
  ThisScreenSize = get(0,'ScreenSize');
  FigureWindowSize = ThisScreenSize + [ThisScreenSize([3,4])./8 , -ThisScreenSize([3,4])./4];

%% Initialise figure  
  ThisFigure = figure;
  set(ThisFigure,'Position',FigureWindowSize);
  SurfacePaneHandle = subplot('position',[0.05 0.15 0.3 0.7]);
  TimeSeriesPaneHandle = subplot('position',[0.4 0.05 0.55 0.9]);


%% Initialise timeseries 
  if numel(Mapping) <= NumberOfVertices,
    NumberOfRegions = length(unique(Mapping));
    RegionalTimeseries = zeros(size(TimeSeries, 1), NumberOfRegions);
    for k=1:NumberOfRegions,
      RegionalTimeseries(:,k) = mean(TimeSeries(:, Mapping==k),2);
    end
    TimeSeriesTitle = 'Region-averaged TimeSeries';
  
  elseif (size(Mapping,2) == NumberOfVertices) && (size(Mapping,1) < 142),
    NumberOfRegions = size(Mapping,1);
    RegionalTimeseries = (Mapping * TimeSeries.').';
    TimeSeriesTitle = 'EEG TimeSeries';
  
  else
    msg = 'The Mapping arg should either provide indices to average over or a projectin matrix...';
    error(['BrainNetworkModels:' mfilename ':StrangeShapedMapping'], msg);
  end
  
  RegionalTimeseries = detrend(RegionalTimeseries);
  
  SeparateBy = 0.33*(max(RegionalTimeseries(:)) - min(RegionalTimeseries(:)));
  
  plot(TimeSeriesPaneHandle, Time, RegionalTimeseries + SeparateBy*repmat((1:NumberOfRegions),[TimeSteps,1]), 'LineWidth', 3);
  title(TimeSeriesTitle, 'interpreter', 'none');
  set(gca,'xlim',[0 Time(end)]);
  xlabel('Time (dpts)');
  set(gca,'ylim',[0 SeparateBy*(NumberOfRegions+1)]);
  set(gca,'YTick', SeparateBy*(1:NumberOfRegions));
  YaxesLimits = get(gca,'ylim');
  hold(TimeSeriesPaneHandle, 'on')
  set(gca,'YTickLabel', NodeStr);
  
  CurrentTimeHandle = plot(TimeSeriesPaneHandle, [1 1],YaxesLimits, 'color',[0.73 0.73 0.73]);

%% Initialise Surface
  %Map timeseries to colormap indices
  MAP = colormap;
  ColourSteps = size(MAP,1);
  TimeSeries = max(fix(((TimeSeries-MinData) ./ (MaxData-MinData)) .* ColourSteps), 1); 
  
  subplot(SurfacePaneHandle),
    SurfaceHandle = patch('Faces', Surface.ConnectivityList(1:1:end,:) , 'Vertices', Surface.Points, ...
                          'Edgecolor',[0.77, 0.77, 0.77], 'FaceColor', 'interp', 'FaceVertexCData', TimeSeries(1,:).', 'CDataMapping', 'direct'); %
    material dull
    title('phi_e', 'interpreter', 'none');
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Z (mm)');
    view([-89 0]);
    
    daspect([1 1 1])
    colorbar('location','southoutside');
    colormap(brewermap([], 'Reds'))
    caxis(SurfacePaneHandle, 'manual');
    caxis(SurfacePaneHandle, [1 ColourSteps]);
%keyboard                       

%% Movie: update surface colour and progress line in time series plot. 
  %Initialise structure to save movie
  if nargout>1, 
    TheMovie(1,1:TimeSteps) = getframe(ThisFigure);
  end
  
  for k = 1:TimeSteps,
    delete(CurrentTimeHandle)
    CurrentTimeHandle = plot(TimeSeriesPaneHandle, [Time(k) Time(k)],YaxesLimits, 'color',[0.42 0.42 0.42], 'LineWidth', 3);
    set(SurfaceHandle, 'FaceVertexCData', TimeSeries(k,:).', 'CDataMapping', 'direct')
    
    %Save movie
    if nargout>1,
      TheMovie(1,k) = getframe(ThisFigure);
    end
    pause(2^-4)
  end

end  %SurfaceMovie()
