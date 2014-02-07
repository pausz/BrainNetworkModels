function write_connectivity_to_txt(Connectivity, saveoptions)
%% Write connectivity data to bzip2'd text files for use as test data in  
% tvb.simulator, also write suplimentary info, but don't bzip2 it. 
% NOTE: This doesn't currently include the additional region area and
%       average orientation information...
%
% ARGUMENTS: 
%          Connectivity -- a structure containing the options, specific to
%                          each matrix.
%          saveoptions  -- a strucutre containing the output format
%          
%
% OUTPUT: 
%           []
%
% USAGE:
%{
 options.Connectivity.WhichMatrix = 'O52R00_IRP2008';
 options.Connectivity.hemisphere = 'both';
 options.Connectivity.RemoveThalamus = true;
 options.Connectivity.invel = 1;
 options.Connectivity = GetConnectivity(options.Connectivity);

%}
%
% MODIFICATION HISTORY:
%     SAK(DD-MM-YYYY) -- Original.




options.Connectivity = Connectivity;

% Set some default saveoptions
if nargin < 2,
   %bzip2 txt files
   saveoptions.bzipit = true;
   %create additional TVB-friendly zip file 
   saveoptions.zipit   = true;
end


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
 DirectoryName = [DirectoryName '_regions_' num2str(options.Connectivity.NumberOfNodes)];
 disp(['Connectivity directory name:  ' DirectoryName])
 
%% Make the directory
 system(['mkdir ' DirectoryName])
 
%% Write weights as bzip2'd text files 
 weights = options.Connectivity.weights;
 save([DirectoryName filesep 'weights.txt'], 'weights', '-ASCII');
 
 if saveoptions.bzipit,
     system(['bzip2 ' DirectoryName filesep 'weights.txt'])
 end

%% Write tract_lengths as bzip2'd text files 
 tract_lengths = options.Connectivity.delay;
 save([DirectoryName filesep 'tract_lengths.txt'], 'tract_lengths', '-ASCII');
 
     if saveoptions.bzipit,
         system(['bzip2 ' DirectoryName filesep 'tract_lengths.txt'])
     end
 

%% Write centres as bzip2'd text files
 centres = options.Connectivity.Position;
 NodeStr = options.Connectivity.NodeStr;
 
 fid = fopen([DirectoryName filesep 'centres.txt'], 'wt');
 for k = 1:length(NodeStr),
   fprintf(fid, '%s %10.6f %10.6f %10.6f \n', NodeStr{k}, centres(k,:))
 end
 fclose(fid);
 if saveoptions.bzipit,
     
    system(['bzip2 ' DirectoryName filesep 'centres.txt'])
 end


%% Write supplementry information as a text file

fid = fopen([DirectoryName filesep 'info.txt'], 'wt');

  if ~isfield(options.Connectivity, 'WhichSubject'),
     fprintf(fid, '%s %s \n', 'Matrix label: ', options.Connectivity.WhichMatrix)
  else
     fprintf(fid, '%s %s \n', 'Matrix label: ', [options.Connectivity.WhichMatrix '_' options.Connectivity.WhichSubject])
  end


  fprintf(fid, '%s %s \n', 'Centres space: ', options.Connectivity.centres)
  fprintf(fid, '%s %d \n', 'Number of regions: ', options.Connectivity.NumberOfNodes)
  
  fprintf(fid, '%s \n', 'Left hemisphere regions:')
  fprintf(fid, '%d', options.Connectivity.LeftNodes)
  
 fclose(fid);
 
 %% Write average region orientations as bzip2'd text files 
if isfield(options.Connectivity, 'AverageOrientation'),
    average_orientations = options.Connectivity.delay;
    save([DirectoryName filesep 'average_orientations.txt'], 'average_orientations', '-ASCII');
    if saveoptions.bzipit,
        system(['bzip2 ' DirectoryName filesep 'average_orientations.txt'])
    end
end
     
%% Write average region orientations as bzip2'd text files 
 if isfield(options.Connectivity, 'Area'),
    areas = options.Connectivity.delay;
    save([DirectoryName filesep 'area.txt'], 'areas', '-ASCII');
    if saveoptions.bzipit,
        system(['bzip2 ' DirectoryName filesep 'areas.txt'])
    end
 end 
 
 %% Write a zip file
 if saveoptions.zipit,
     filelist = {[DirectoryName filesep 'tract_lengths.txt.bz2'], [DirectoryName filesep 'weights.txt.bz2'], [DirectoryName filesep 'centres.txt.bz2']}; 
     zip(DirectoryName, filelist)
 end
 clear options
end
 %%% EoF %%% 