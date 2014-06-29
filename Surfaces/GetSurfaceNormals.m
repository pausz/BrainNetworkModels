function [VertexNormals TriangleNormals] = GetSurfaceNormals(Vertices, Triangles) 

%% Get triangle normals and estimate vertex normals
% TODO: weight normals.
% ARGUMENTS:
%           Vertices  -- A NumberOfVertices  x 3 array with the positions of the vertices of a mesh. 
%           Triangles -- A NumberOftriangles x 3 array with the vertex
%                        indices making up the triangular faces of a mesh
%
%                
% OUTPUT: 
%           VertexNormals   -- a NumberOfVertices x 3 array, with the unit
%                              vectors of the normals at a given vertex.  
%           TriangleNormals -- a NumberOfTriangles x 3 array, with the unit
%                              vectors of the normals perpednicular to a triangle.  
%
% USAGE:
%{
      [VertexNormals TriangleNormals] = GetSurfaceNormals(Vertices, Triangles);
%}
%



 
if size(Vertices, 1) > 3,
     Vertices = Vertices';
end
 
if size(Triangles, 1) > 3,
     Triangles = Triangles';
end

NumberOfVertices  = size(Vertices, 2);
NumberOfTriangles = size(Triangles, 2);
 
VertexNormals   = zeros(3, NumberOfVertices);

% Compute TRIANGLE normals
TriangleNormals = crossp( Vertices(:, Triangles(2,:) )-Vertices(:,Triangles(1,:)), ...
                  Vertices(:,Triangles(3,:))-Vertices(:,Triangles(1,:)) );

% NORMALIZE 
NormTriangleNormals = sqrt( sum(TriangleNormals.^2,1) ); 
% Avoid division by zero
NormTriangleNormals(NormTriangleNormals < eps) = 1;
TriangleNormals = TriangleNormals ./ repmat( NormTriangleNormals, 3, 1 );



% Compute unweighted VERTEX normals
for i=1:NumberOfTriangles
    ThisTriangle = Triangles(:,i);
    for j=1:3
        VertexNormals(:, ThisTriangle(j)) = VertexNormals(:, ThisTriangle(j)) + TriangleNormals(:, i);
    end
end

% NORMALIZE
NormVertexNormals = sqrt( sum(VertexNormals.^2,1) ); 
% Avoid division by zero
NormVertexNormals(NormVertexNormals < eps) = 1;
VertexNormals = VertexNormals ./ repmat( NormVertexNormals, 3, 1 );


% Check if normals are inwards - make them outwards
% NOTE: Maybe some vertices are oriented clockwise, some are counter-clockwise. 
%       To correct this consider using: meshcheckrepair(node,face) from iso2mesh
%       to get consistent orientations.

ZeroCenteredVertices = Vertices - repmat(mean(Vertices,1), 3, 1);

s = sum( ZeroCenteredVertices.* VertexNormals, 2);

if sum(s > 0) < sum(s < 0)
    % flip
    VertexNormals   = - VertexNormals;
    TriangleNormals = - TriangleNormals;
end


%% Auxiliary function - crossproduct

function z = crossp(x, y)
% x and y are (3, m) dimensional
z = x;
z(1,:) = x(2,:).*y(3,:) - x(3,:).*y(2,:);
z(2,:) = x(3,:).*y(1,:) - x(1,:).*y(3,:);
z(3,:) = x(1,:).*y(2,:) - x(2,:).*y(1,:);
end 
end%function GetSurfaceNormals()