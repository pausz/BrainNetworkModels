
%% Compute:
% 1) triangle areas; 
% 2) vertex areas of each region defined by the parcellation;
% 3) vertex areas around each vertex.

%% NOTE:
% Barycentric vs Voronoi Areas discussion: http://www.alecjacobson.com/weblog/?p=1146
% For non regular meshes (regular positions) with well behaved triangles
% (non obtuse angles). If there are obtuse angles, use 'mixed'. 

% This script requires: 
%                       + matlabmesh/mesh/vertexArea.m
%                       + matlabmesh/mesh/makeMesh.m
%%
% Load the data
load('Cortex_reg13.mat', 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
load('RegionMapping_reg13_O52R00_IRP2008')

% Put the data into a triangulation object or mesh struct
tr   = triangulation(Triangles, Vertices);
Mesh = makeMesh(Vertices, Triangles);

[~, TotalCortexArea] = GetSurfaceAreas(tr);
 
%% Compute Vertex Areas
MixedVertexArea   = vertexArea(Mesh, 1:length(Vertices), 'mixed');
OneringVertexArea = vertexArea(Mesh, 1:length(Vertices), 'onering')/3;
%% Compute Vertex and Triangle areas for each region

NumberOfRegions = length(unique(RegionMapping));
RegionTriangleArea = zeros(NumberOfRegions,1);
RegionMixedVertexArea = RegionTriangleArea;
RegionOneringVertexArea = RegionTriangleArea;

for ThisRegion=1:NumberOfRegions,
    TheseTriangles = [];
    VertexIndices = find(RegionMapping==ThisRegion);
    TriIndices = tr.vertexAttachments(VertexIndices);
    for ThisVertex = 1:length(TriIndices),
        TheseTriangles = cat(2, TheseTriangles, TriIndices{ThisVertex});
    end
    TheseTriangles = unique(TheseTriangles);
    % The sum of TotalSurfaceArea overestimates the whole surface area
    [TriangleAreas, RegionTriangleArea(ThisRegion)] = GetSurfaceAreas(tr, TheseTriangles);
    RegionMixedVertexArea(ThisRegion)   = sum(MixedVertexArea(RegionMapping==ThisRegion));
    RegionOneringVertexArea(ThisRegion) = sum(OneringVertexArea(RegionMapping==ThisRegion));
end

%% Plot some pretty pictures

% Get some useful data
ThisConnectivity = 'O52R00_IRP2008';
options.Connectivity.WhichMatrix = ThisConnectivity;
options.Connectivity.hemisphere = 'both';
options.Connectivity.RemoveThalamus = true;
options.Connectivity = GetConnectivity(options.Connectivity);
%%
[SortedTriangleArea, Idx] = sort(RegionTriangleArea);
SortedVertexArea = RegionMixedVertexArea(Idx);
SortedOneringArea = RegionOneringVertexArea(Idx);
SortedAreas = [SortedTriangleArea SortedVertexArea SortedOneringArea];

%% 
figure(77);
hold on;
Regions = 1:NumberOfRegions;
[ax, p1, p2] = plotyy(Regions, SortedAreas*1e-6, Regions, 100*(SortedAreas/TotalCortexArea));

set(ax(1),'XTick', 1:NumberOfRegions);
set(ax(1),'XTickLabel', options.Connectivity.NodeStr(Idx));
set(ax(1),'XTickLabelRotation', 90)
set(ax(1), 'YColor', [0, 44.3, 73.7] / 100)
set(ax(2), 'YColor', [188,75,0] / 255)
xlabel(ax(1), 'Anatomical Regions')
ylabel(ax(1), 'Region Area [m^{2}]')
ylabel(ax(2), 'Region Area / Total Cortex Area [%]')

p1(1).LineWidth = 2;
p1(2).LineWidth = 2;
p2(1).LineWidth = 2;
p2(2).LineWidth = 2;

xlim(ax(1), [0 NumberOfRegions+1]);
xlim(ax(2), [0 NumberOfRegions+1]);

%% 
figure(33);

nbins = 20;
step = (max(MixedVertexArea) - min(MixedVertexArea))/ nbins;
min_va = min(MixedVertexArea) - step / 2;
max_va = max(MixedVertexArea) + step / 2 ;

va_edges = linspace(min_va, max_va, nbins+2);

h= histogram(MixedVertexArea, va_edges);
hold on;
plot(min(MixedVertexArea), 0, 'o')
plot(max(MixedVertexArea), 0, 'o')
