%% write all possible matrices derived from EPFL data
% # subjects: 40
% # parcellations: 2
% # cortical vs thalamus: 2
% # average connectivities '4 '
% # 164 new connectivities.


%%
% parcellation : low
% subject      : average 
% subcortical  : true
% brainstem    : false
% yields       : 82 ROIs matrix
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'low';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)

%%
% parcellation : low
% subject      : average 
% subcortical  : false
% brainstem    : false
% yields       : 68 ROIs matrix
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'low';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = true;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
%%
% parcellation : low
% subject      : individual 
% subcortical  : true
% brainstem    : false
% yields       : 40 x 68 ROIs matrices

for s=1:40,
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'low';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
end

%%
% parcellation : low
% subject      : individual 
% subcortical  : true
% brainstem    : false
% yields       : 40 x 82 ROIs matrices
for s=1:40,
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'low';
    options.Connectivity.WhichSubject = 'individual';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
end

%%
% parcellation : high
% subject      : average 
% subcortical  : true
% brainstem    : false
% yields       : 1014 ROIs matrix
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'high';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)

%%
% parcellation : high
% subject      : average 
% subcortical  : false
% brainstem    : false
% yields       : 1000 ROIs matrix
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'high';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = true;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
%%
% parcellation : high
% subject      : individual 
% subcortical  : true
% brainstem    : false
% yields       : 40 x 1000 ROIs matrices

for s=1:40,
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'high';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
end

%%
% parcellation : high
% subject      : individual 
% subcortical  : true
% brainstem    : false
% yields       : 40 x 1014 ROIs matrices
for s=1:40,
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'high';
    options.Connectivity.WhichSubject = 'individual';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
        
end