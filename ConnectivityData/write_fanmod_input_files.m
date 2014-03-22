function write_fanmod_input_files(options)
%% Generate a matrix of integers. The first two integers code the start and stop node of an edge. 
%  The third an fourth number denote the vertex colours. Write the results
%  in an ascii file.
%
%
% ARGUMENTS: 
%          options.Connectivity -- a structure containing the options, specific to
%                                  each matrix.
%          
%
% OUTPUT: 
%           []
%
% USAGE:
%{
    
    options.Connectivity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = 1;
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.RemoveBrainStem = false;
    options.Connectivity.invel = 1;
    options.Connectivity.subject = 1;
    options.Connectivity.AddCorpusCallosum = false;
    options.Connectivity = GetConnectivity(options.Connectivity);
    write_fanmod_input_files(options)

%}



%% Create a directory name
 DirectoryName = lower(options.Connectivity.WhichMatrix);
 if ~isfield(options.Connectivity, 'WhichSubject'),
        DirectoryName = [DirectoryName '_hemisphere_' lower(options.Connectivity.hemisphere)];
 else
     DirectoryName = [DirectoryName '_' lower(options.Connectivity.WhichSubject) '_hemisphere_' lower(options.Connectivity.hemisphere)];
 end
 if options.Connectivity.RemoveThalamus,
   DirectoryName = [DirectoryName '_subcortical_false'];
 else
   DirectoryName = [DirectoryName '_subcortical_true'];
 end
 DirectoryName= [DirectoryName '_regions_' num2str(options.Connectivity.NumberOfNodes)];
 disp(['Connectivity directory name:  ' DirectoryName])

%% Create the colour matrix
% node colours
% rh - cx    = 0
% rh - subcx = 1
% lh - cx    = 2
% lh - subcx = 3
% lh - bs    = 4

[sink_nodes, source_nodes] = find(options.Connectivity.weights);

nodecolours = zeros(length(sink_nodes), 4);

% start node
nodecolours(:, 1) = source_nodes;
nodecolours(:, 2) = sink_nodes;

for k=1:1:options.Connectivity.NumberOfNodes,
    nodecolours(source_nodes == k, 3) = options.Connectivity.NodeColours(k);
    nodecolours(sink_nodes == k, 4)   = options.Connectivity.NodeColours(k);
    
end

% node colours consistent with the legend above, plus fanmod expect
% zero-based indexing.
nodecolours = nodecolours -1;


%% Make the directory

system(['mkdir ' DirectoryName])
 
fid = fopen([DirectoryName filesep 'fanmod_input.txt'], 'wt');
for k = 1:length(sink_nodes),
   fprintf(fid, '%d %d %d %d \n',nodecolours(k,:));
end

%save([DirectoryName filesep 'fanmod_input.txt'], 'nodecolours', '-ASCII');
%fprintf(fid, '%d ', nodecolours', '-ASCII');
fclose(fid);

 

 %%% EoF %%% 