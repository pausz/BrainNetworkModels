%% Generates a tesselated plane using Delaunay triangulation.
%
% ARGUMENTS:
%        n    -- number of grid points along one axis.
%        type -- type of surface. Default is 'plane'. Options are 'plane'
%        or 'saddle'.
%
% OUTPUT: 
%        Vertices -- <description> 
%        Triangles --
%
% REQUIRES: 
%        DelaunayTri() -- Not yet available in Octave... To be removed in 
%                         future releases of matlab
%
% USAGE:
%{
      [Vertices, Triangles] = MakeTesselatedPlane(12, 'saddle');
%}
%
% MODIFICATION HISTORY:
%     SAK(29-09-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [Vertices, Triangles]=MakeTesselatedPlane(n, type)
  % Set any argument that weren't specified
  if nargin < 1,
    n = 10;
    type = 'plane';
  end
  
  if nargin < 2,
    type = 'plane';
  end
  
  % 
  [X, Y] = ind2sub(size(ones(n)), find(ones(n)));
  DT = DelaunayTri(X,Y);
  Triangles = DT.Triangulation;
  
  switch type,
      case 'plane'
      Vertices  = [X Y ones(size(X))];
      
      case 'saddle'
      Z = X.^2 -  Y.^2;
      Vertices  = [X Y Z];
  end
  %TR = TriRep(DT.Triangulation, X, Y, ones(size(X)));

end %function MakeTesselatedPlane()
