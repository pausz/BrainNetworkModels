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

load('EPFL_diffusion_connectivity_data_07032014_5scales.mat')


% Heuristic to clean 'spurious connections'
connection_threshold = [0.7, 0.65, 0.60, 0.55, 0.5] * 40;

for scale=1:5,

    % get rid of 'spurious' connections
    weights_density = SC_density{scale};
    weights_number  = SC_number{scale};
    tract_lengths = L{scale}; 
    
    weights_density_sum = sum(weights_density ~=0, 3);
    idx  = weights_density_sum < connection_threshold(scale) ;
    idx3 = repmat(idx, [1 1 40]);
    
    weights_density(idx3) = 0;
    weights_number(idx3)  = 0; 

    % get rid of lengths and connections for d > 255 mm
    weights_density(tract_lengths > 255)   = 0;
    weights_number(tract_lengths  > 255)   = 0;
    tract_lengths(tract_lengths   > 255)   = 0; 

    % scale density weights so they are in the range [0, 1], but preserve inter
    % subject variability?
    % weights_density = (weights_density - min(weights_density(:))) / (max(weights_density(:)) - min(weights_density(:))); 

    SC_density{scale} = weights_density;
    SC_number{scale}  = weights_number;
    L{scale} = tract_lengths; 
end
%% 

%% save

save('EPFL_diffusion_connectivity_data_07032014_5scales_corrected.mat', 'L', 'SC_density', 'SC_number', 'age', 'code', 'gender')
