%% Clean data. Connections with high fiber length are probably spurious. 
% Tough, we do not have an exact criteria to identify false positive on the 
% basis of the fiber length. A combination of a high fiber length and a low 
% streamlines number could be an indicator of false positive.
% In order to limit false positive and when working with a single group of 
% subject, discard connections which are not present in at least a certain 
% percentage (e.g. 75%) of the subjects, knowing that this percentage 
% should be relaxed in the case of high resolution parcellation (e.g 50%)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load('EPFL_diffusion_connectivity_data_04022014.mat')

%% clean the 83 ROIs data


weights_density = SC_density{1};
weights_number  = SC_number{1};
tract_lengths = L{1}; 

% get rid of connections that are not present in 75% of the group
weights_density(weights_density > 0) = 1;  % binarize
weights_density_sum = sum(weights_density, 3);
idx = weights_density_sum < 30 ;
idx3 = repmat(idx, [1 1 40]);

weights_density = SC_density{1};
weights_density(idx3) = 0;
weights_number(idx3) = 0; 

% get rid of lengths and connections for d > 250 mm
weights_density(tract_lengths > 250) = 0;
weights_number(tract_lengths > 250) = 0;
tract_lengths(tract_lengths > 250)   = 0;   % binarize

% 
SC_density{1} = weights_density;
SC_number{1} = weights_number;
L{1} = tract_lengths; 

%% clean the 1015 ROIs data

weights_density = SC_density{2};
weights_number  = SC_number{2};
tract_lengths   = L{2}; 

% get rid of connections that are not present in 50% of the group
weights_density(weights_density > 0) = 1;  % binarize
weights_density_sum = sum(weights_density, 3);
idx  = weights_density_sum < 20 ;
idx3 = repmat(idx, [1 1 40]);

weights_density = SC_density{2};
weights_density(idx3) = 0; 
weights_number(idx3) = 0; 

% get rid of lengths and connections for d > 250 mm
weights_density(tract_lengths > 250) = 0;
weights_number(tract_lengths > 250) = 0;
tract_lengths(tract_lengths > 250)   = 0;   % binarize

% 
SC_density{2} = weights_density;
SC_number{2} = weights_number;
L{2} = tract_lengths; 

%% save

save('EPFL_diffusion_connectivity_data_04022014_corrected.mat', 'L', 'SC_density', 'SC_number', 'age', 'code', 'gender')
