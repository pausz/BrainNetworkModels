%% Load freesufer surfaces, checks, merges hemisphere and other
% stuff.
% 
%
% ARGUMENTS: 
%           Surface --    a structure containing the options, specific to
%                          each mesh. The options common to all
%                          connectivities are:
%
%               .WhichMesh --  A string specifying the surface to
%                              be loaded. 
%                              Default = 'pial'; 
%                              Possible values = {'pial', 'white'};
%               .WhichSubject -- A string specifying the subject code.
%                                No default.
%               .hemisphere --  A string specifying which hemisphere has to
%                              be loaded. 
%                              Default = 'rh'; 
%                              Possible values = {'rh', 'lh', 'bh'};
%                              If 'bh', it will merge both hemispheres
%            
% 
%
%
% OUTPUT: 
%           Surface.tr        --   a matlab TriRep object, representing the surface. 
%           Surface.SummaryInfo -- a structure with relevant info about the
%                                  surface geometry and topology.
%
% REQUIRES: 
%          GetSurfaceSummaryInfo() --
%          CheckSurface()
%          read_annotation - freesurfer
%          read_surf       - freesurfer
%          fread3          - freesurfer 
%
% USAGE:
%{
     
  %Specify bi-hemispheric mesh first patient: PH0036.pial
   Surface.WhichMesh = 'PH0036';
   Surface.hemisphere = 'bh';

  %Load it:
   Surface = GetSurface(Surface); 
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Surface] = GetSurface(Surface)

 Sep = filesep; %Get the appropriate directory separator for this OS
 
 switch Surface.hemisphere,
     case {'lh','rh'}
         meshname = ['Surfaces' Sep Surface.WhichSubject '_' Surface.hemisphere '.' Surface.WhichMesh];
         [v, tri]  = read_surf(meshname);
          
          % Freesurfer indices start at 0, so make them matlab compatible
          % NOTE: don't forget about compatibility with the region mapping
          if min(tri(:))==0,
            tri = tri +1;
          end
         
     case 'bh',
          error(strcat('BrainNetworkModels:', 'bihemispheric',':NotImplemented'), 'Haven''t implemented merging hemispheres...');
 end
        
         
 
 Surface.tr = TriRep(tri, v);
 
 % Check freshly loaded surface
 [IsolatedVertices, PinchedOff, Holes, SurfaceSummaryInfo] = CheckSurface(Surface.tr);
 
 Surface.SummaryInfo = SurfaceSummaryInfo;
 
end % function GetSurface()
 
 
 
 