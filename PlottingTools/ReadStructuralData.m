%%
%          StructuralData                -- a structure containing the structural data, specific to
%                                           the 5 anatomical parcellations.
%              .StructuralConnectivity   -- Cell array with structural connectivity matrices
%                                           of 40 different subjects and 5
%                                           different parcellation scales.
%              .Centroids                -- cell array with triplets with the x, y, z
%                                           coordinates of every region. 
%              .NodeStrIntuitive         -- A cell array containing strings for labelling each
%                                           region in the functional or
%                                           structural matrix.

%% Load the data
             
load('EPFL_diffusion_connectivity_data_5scales_07032014_2016')


%% Compute the average structural connectivity matrix
parc_scale   = 1; % 1 to 5
subject      = 1; % 1 to 40

SC = StructuralData.StructuralConnectivity{scale}(:, :, subject);

figure(1)
imagesc(SC)

%% Use the centroids

x = StructuralData.Centroids{parc_scale}(:, 1, subject);
y = StructuralData.Centroids{parc_scale}(:, 2, subject);
z = StructuralData.Centroids{parc_scale}(:, 3, subject);

AdjacencyMatrix = SC > 0; 

[r c] = find(AdjacencyMatrix);
p = [r c]';

figure(2)
plot3(x(p), y(p), z(p), 'LineWidth', 1.5, 'Color', [0.5 0.5 0.5 0.25], 'Marker', 'o', 'Markersize', 10, ...
    'MarkerFaceColor', 'b', 'MarkerEdgecolor', 'b')

text(x, y, z, StructuralData.NodeStrIntuitive{scale}, ...
    'EdgeColor', 'r', 'BackgroundColor', [252/255, 146/255, 114/255], ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left')

axis equal
axis vis3d, box on, view(3)


xlabel('x'),ylabel('y'), zlabel('z')

