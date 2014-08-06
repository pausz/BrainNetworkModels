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
%%
% Heuristic to clean 'spurious connections' -- false positives
% 

connection_threshold = [0.7, 0.65, 0.60, 0.55, 0.5] * 40;


% distance boundaries [mm]
lo =  12;
hi = 300;

resample_weights = 'true';

for scale=1:5,

    % get rid of 'spurious' connections
    weights_density = SC_density{scale};
    %weights_number  = SC_number{scale};
    tract_lengths = L{scale}; 
    
    weights_density_sum = sum(weights_density ~=0, 3);
    idx  = weights_density_sum < connection_threshold(scale) ;
    idx3 = repmat(idx, [1 1 40]);
    
    weights_density(idx3) = 0;
    %weights_number(idx3)  = 0; 
     

    % get rid of lengths and connections for d < lo mm
    weights_density(tract_lengths < lo)   = 0;
    %weights_number(tract_lengths  < lo)   = 0;
    tract_lengths(tract_lengths   < lo)   = 0;
    
    % get rid of lengths and connections for d > hi mm
    weights_density(tract_lengths > hi)   = 0;
    %weights_number(tract_lengths  > hi)   = 0;
    tract_lengths(tract_lengths   > hi)   = 0;
    
    if resample_weights,
    
        % restart random number generator, so we always obtain the same
        % numbers.
        
        % Matlab 2014
        % rng('default')
        % Older versions
        randn('seed', 42)
        mu       = 0.5;
        sigma    = 0.1;
        idx      = find(weights_density);
        nsamples = length(idx); 
        new_weights = mu + sigma *randn(nsamples, 1);
        weights_density(idx) = new_weights;
    end
    
        
    SC_density{scale} = weights_density;
    %SC_number{scale}  = weights_number;
    L{scale} = tract_lengths; 
    SC_density_sum{scale} = weights_density_sum;
    clear weights_density weights_density_sum idx idx3 new_weights
end


%% 

%% save

save('EPFL_diffusion_connectivity_data_07032014_5scales_corrected_and_resampled_20140806.mat', 'L', 'SC_density', 'SC_density_sum', 'age', 'code', 'gender')
