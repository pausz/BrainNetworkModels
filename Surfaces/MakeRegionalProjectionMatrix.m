%% Generate a 'regional' projection matrix from the surface projection
%  matrix. 

%
% ARGUMENTS:
%           options.Connectivity -- <description>
%           
%           Mapping         
%             
%               .ProjectionMatrix -- a surface projection matrix of
%                                    dimensions sensors x sources.
%           modality              -- a string to select the projection
%                                    matrix modality. 
%                                    Default= 'eeg';
%                                    Possible values = {'eeg', 'meg'}
%
% OUTPUT: 
%           Mapping.ProjectionMatrix -- a regional projection matrix. Using 
%                                       the RegionMapping, sum over nodes for the surface projection matrix.
%
% USAGE:
%{

  
  %Load surface
  ThisSurface = 'reg13';
  load(['Cortex_' ThisSurface '.mat'], 'Vertices', 'Triangles'); %Contains: 'Vertices', 'Triangles', 'VertexNormals', 'TriangleNormals'
 
  %Load connectivity matrix
  ThisConnectivity = 'O52R00_IRP2008';
  options.Connectivity.WhichMatrix = ThisConnectivity;
  options.Connectivity.hemisphere = 'both';
  options.Connectivity.RemoveThalamus = true; %Dynamic model includes a thalamus...
  options.Connectivity = GetConnectivity(options.Connectivity);

  NumberOfVertices = length(Vertices);
  options.Connectivity.NumberOfVertices = NumberOfVertices;
 
  %Region mapping
  load(['RegionMapping_' ThisSurface '_' ThisConnectivity '.mat'])
  options.Connectivity.RegionMapping = RegionMapping;

  %Neuroimaging modality
  modality = 'meg';

  %System
  ThisSystem = strcat(modality, '_sys');

  %ProjectionMatrix
  load('tvb-lead-fields.mat', modality, ThisSystem); 
  Mapping.ProjectionMatrix = eval(modality);
  ThisSystem = eval(ThisSystem);
 
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Simple regional projection matrix.
NumberOfRegions  = options.Connectivity.NumberOfNodes;
NumberOfVertices = options.Connectivity.NumberOfVertices;
NumberOfSources  = size(Mapping.ProjectionMatrix,2);
NumberOfSensors  = size(Mapping.ProjectionMatrix,1);

%Check if there are NaNs
if isnan(Mapping.ProjectionMatrix),
    warning(strcat('BrainNetworkModels:', mfilename,':NaNsInTheProjectionMatrix'), 'There are NaNs in the projection matrix, will set them to 0..');
    Mapping.ProjectionMatrix(isnan(Mapping.ProjectionMatrix)) = 0;
end

%Check if the number of sources matches the number of vertices -- assumes a
%region mapping with only cortical regions

if NumberOfVertices ~= NumberOfSources,
            error(strcat('BrainNetworkModels:', mfilename,':DimensionMismatch'), ['The number of vertices (' NumberOfVertices ') does not match with the number of sources ( ' NumberOfSources ' )' ]);
end
RegionalProjectionMatrix = zeros(NumberOfSensors, NumberOfRegions);
for k=1:NumberOfRegions, 
    ThisRegionVertices = options.Connectivity.RegionMapping==k;
    RegionalProjectionMatrix(:, k) = sum(Mapping.ProjectionMatrix(:, ThisRegionVertices), 2);
     %approx vector sum
end

save(['ProjectionMatrix_' ThisConnectivity '_' ThisSystem '_sensors_' num2str(NumberOfSensors) '_regions_' num2str(NumberOfRegions) '.mat'], 'RegionalProjectionMatrix')