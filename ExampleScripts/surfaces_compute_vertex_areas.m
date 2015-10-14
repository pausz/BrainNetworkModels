
%% Barycentric vs Voronoi Areas discussion: http://www.alecjacobson.com/weblog/?p=1146

% For non regular meshes (regular positions) with well behaved triangles
% (non obtuse angles). If there are obtuse angles, then use 'mixed'. 

% This script requires: 
%                       + matlabmesh/mesh/vertexArea.m
%                       + matlabmesh/mesh/makeMesh.m

% Load the data
load('Cortex_reg13.mat', 'Vertices', 'Triangles'); % Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals' 
load('RegionMapping_reg13_O52R00_IRP2008')

Mesh = makeMesh(Vertices, Triangles);
%% Compute Vertex Areas
MixedVertexArea  = vertexArea(Mesh, 1:length(Vertices), 'mixed');
%%
nbins = 20;
step = (max(MixedVertexArea) - min(MixedVertexArea))/ nbins;
min_va = min(MixedVertexArea) - step / 2;
max_va = max(MixedVertexArea) + step / 2 ;

va_edges = linspace(min_va, max_va, nbins+2);

h= histogram(MixedVertexArea, va_edges);
hold on;
plot(min(MixedVertexArea), 0, 'o')
plot(max(MixedVertexArea), 0, 'o')
