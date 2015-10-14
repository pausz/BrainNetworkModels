
%% Get triangle areas of the different regions defined by the parcellation

% Load the data
load('Cortex_reg13.mat', 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
load('RegionMapping_reg13_O52R00_IRP2008')

% Put the data into a triangulation object
tr = triangulation(Triangles, Vertices); 

[~, TotalCortexArea] = GetSurfaceAreas(tr);

% 
NumberOfRegions = length(unique(RegionMapping));
TotalRegionArea = zeros(NumberOfRegions,1);
for ThisRegion=1:NumberOfRegions,
    TheseTriangles = [];
    VertexIndices = find(RegionMapping==ThisRegion);
    TriIndices = tr.vertexAttachments(VertexIndices);
    for ThisVertex = 1:length(TriIndices),
        TheseTriangles = cat(2, TheseTriangles, TriIndices{ThisVertex});
    end
    TheseTriangles = unique(TheseTriangles);
    % The sum of TotalSurfaceArea overestimates the whole surface area
    [TriangleAreas, TotalRegionArea(ThisRegion)] = GetSurfaceAreas(tr, TheseTriangles);
end

%% Plot some pretty pictures

% Get some useful data
ThisConnectivity = 'O52R00_IRP2008';
options.Connectivity.WhichMatrix = ThisConnectivity;
options.Connectivity.hemisphere = 'both';
options.Connectivity.RemoveThalamus = true;
options.Connectivity = GetConnectivity(options.Connectivity);
%%
[SortedAreas, Idx] = sort(TotalRegionArea);
%% 
figure(77);

Regions = 1:NumberOfRegions;
[ax, p1, p2] = plotyy(Regions, SortedAreas*1e-6, Regions, 100*(SortedAreas/TotalCortexArea));
set(ax(1),'XTick', 1:NumberOfRegions);
set(ax(1),'XTickLabel', options.Connectivity.NodeStr(Idx));
set(ax(1),'XTickLabelRotation', 90)
xlabel(ax(1), 'Anatomical Regions')
ylabel(ax(1), 'Region Triangle Area [m^{2}]')
ylabel(ax(2), 'Region Triangle Area / Total Cortex Area [%]')
p1.LineWidth = 2;
p2.LineWidth = 2;
xlim(ax(1), [0 NumberOfRegions+1]);
xlim(ax(2), [0 NumberOfRegions+1]);


