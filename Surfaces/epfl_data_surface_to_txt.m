%% Load cortical surface data - LH
load('Surfaces/Cortex_PH0036pial_lh.mat') 

%% Vertices
fid = fopen('Surfaces/vertices_cortex_ph0036pial_lh.txt','wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', Surface.vertices.')
fclose(fid);
system('bzip2 Surfaces/vertices_cortex_ph0036pial_lh.txt')

%% Triangles

fid = fopen('Surfaces/triangles_cortex_ph0036pial_lh.txt','wt');
fprintf(fid, '%d %d %d \n', Surface.triangles.' - 1)
fclose(fid);
system('bzip2 Surfaces/triangles_cortex_ph0036pial_lh.txt')


%% Load cortical surface data - RH

load('Surfaces/Cortex_PH0036pial_rh.mat') 

%% Vertices
fid = fopen('Surfaces/vertices_cortex_ph0036pial_rh.txt','wt');
fprintf(fid, '%10.6f %10.6f %10.6f \n', Surface.vertices.')
fclose(fid);
system('bzip2 Surfaces/vertices_cortex_ph0036pial_rh.txt')

%% Triangles

fid = fopen('Surfaces/triangles_cortex_ph0036pial_rh.txt','wt');
fprintf(fid, '%d %d %d \n', Surface.triangles.'-1)
fclose(fid);
system('bzip2 Surfaces/triangles_cortex_ph0036pial_rh.txt')