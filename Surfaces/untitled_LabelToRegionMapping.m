%% Convert label mapping to index based region mapping

labels_file = importdata('EPFL_83ROIs.txt');


RegionMapping_rh = zeros(length(lm_rh), 1);
RegionMapping_lh = zeros(length(lm_lh), 1);
% Right hemisphere
for i=2:35,
    
    StringToFind = labels_file.textdata{i, 2};
    IndexCells = strfind(lm_rh, StringToFind); % find the cells that contain StringToFind
    Index      = find(not(cellfun('isempty', IndexCells))); % get the indices
    RegionMapping_rh(Index,1) = i-1;
    
end

% Left hemisphere
for i=43:76,
    
    StringToFind = labels_file.textdata{i, 2};
    IndexCells = strfind(lm_lh, StringToFind); % find the cells that contain StringToFind
    Index      = find(not(cellfun('isempty', IndexCells))); % get the indices
    RegionMapping_lh(Index,1) = i-8;
    
end


%% 

p=patch('Faces', Surface.tr.Triangulation(1:1:end,:) , 'Vertices', Surface.tr.X, ...
    'Edgecolor','interp', 'FaceColor', 'flat', 'FaceVertexCData', RegionMapping_lh, 'EdgeColor','none','FaceAlpha',1);

set(p,'FaceVertexCData',RegionMapping_lh);
daspect([1 1 1]);
view([90 90]); % sets the viewpoint to the Cartesian coordinates x, y, and z
camlight;     % creates a light right and up from camera
colormap cool;
lighting gouraud; % specify lighting algorithm
axis off;