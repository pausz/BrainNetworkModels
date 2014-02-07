%% write all possible matrices derived from EPFL data
% # subjects: 40
% # parcellations: 2
% # cortical vs thalamus: 2
% # average connectivities '4 '
% # 164 new connectivities.

for s=1:40,
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 'high';
    options.Connectivity.WhichSubject = 'individual';
    options.Connectivity.RemoveThalamus = true;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = s;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    write_connectivity_to_txt(options.Connectivity)
    
    
end