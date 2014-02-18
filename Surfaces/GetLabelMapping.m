%% Get the label mapping from the annotation files.
%
% 1) read surface as set of nodes and vertexes 
% 2) read annotation file, which contains annotation for each vertex of the
%    corresponding surface. Note that for resolution 500 we need to open 3
%    distinct annot files (P1_16, P17_28 and P29_36). Each annot file
%    contains a mixture of high resolution (small) regions and low
%    resolution (big) region. The names of the regions belonging to the
%    high resolution contain an '_' in the name: this is the criteria used
%    to distiguish between small and big regions in the three files.
%
% ARGUMENTS: - path_surf_rh
%        - base_path_annot_rh (the path cut before the P1_16/P17_28/P29_36 nomenclature)
%        - path_surf_lh
%        - base_path_annot_lh (the path cut before the P1_16/P17_28/P29_36 nomenclature)
%        - addview: additional views, boolean 1/0
%        - CM: user colormap (it is assumed not to contain subcortical ROIs) [optional]
%              Note: CM can have 1 or 3 columns.
%        - llist: list of regions (names) in CM order [optional]
% OUTPUT: returns the handle or vector of handles to the generated figure(s) objects (h) 
% REQUIRES: 
%          read_annotation - freesurfer
%          read_surf       - freesurfer
%          fread3          - freesurfer 
% USAGE:
%{
     
  %Somme comment
   <command>
   <command>
   <command>

  %Somme comment
   <command>
%}
% MODIFICATION HISTORY:
%     Alessandra Griffa -- Original.
%     XX(dd-mm-yyyy)   -- git.

function [h, vIndex_rh, vIndex_lh] = GetLabelMapping(path_surf_rh, base_path_annot_rh, path_surf_lh, base_path_annot_lh, addview, CM, llist)

% Set a flag for provided colormap: the one in the annot file or a random one
randomcolor = 1;

% Load example dataset
% path_surf_rh = 'C:\Users\agriffa\Documents\DATA\PH0036_FreeSurfer\FREESURFER\surf\rh.pial';
% path_surf_lh = 'C:\Users\agriffa\Documents\DATA\PH0036_FreeSurfer\FREESURFER\surf\lh.pial';
% base_path_annot_rh = 'C:\Users\agriffa\Documents\DATA\PH0036_FreeSurfer\FREESURFER\label\rh.myaparc';
% base_path_annot_lh = 'C:\Users\agriffa\Documents\DATA\PH0036_FreeSurfer\FREESURFER\label\lh.myaparc';

ll =load('llist_cortical_Lausanne2008.mat');
% LOAD Right hemisphere
[v_rh,f_rh] = read_surf(path_surf_rh); % v: vertices; f: faces of trangles
nv_rh = size(v_rh,1); % number of vertices
if min(f_rh(:)) == 0  %faces in freesurfer start at 0 (in matlab, they start at 1);
    f_rh = f_rh + 1;
end
path_annot_rh = strcat(base_path_annot_rh,'P1_16.annot');
disp(path_annot_rh);
[dummy,l1_rh,c1_rh] = read_annotation(path_annot_rh);
path_annot_rh = strcat(base_path_annot_rh,'P17_28.annot');
[dummy,l2_rh,c2_rh] = read_annotation(path_annot_rh);
path_annot_rh = strcat(base_path_annot_rh,'P29_36.annot');
[dummy,l3_rh,c3_rh] = read_annotation(path_annot_rh);
path_annot_rh = strcat(base_path_annot_rh,'_36');
[dummy,l4_rh,c4_rh] = read_annotation(path_annot_rh);

% LOAD Left hemisphere
[v_lh,f_lh] = read_surf(path_surf_lh);
nv_lh = size(v_lh,1); % number of vertices
if min(f_lh(:)) == 0  %faces in freesurfer start at 0 (in matlab, they start at 1);
    f_lh = f_lh + 1;
end
path_annot_lh = strcat(base_path_annot_lh,'P1_16.annot');
[dummy,l1_lh,c1_lh] = read_annotation(path_annot_lh);
path_annot_lh = strcat(base_path_annot_lh,'P17_28.annot');
[dummy,l2_lh,c2_lh] = read_annotation(path_annot_lh);
path_annot_lh = strcat(base_path_annot_lh,'P29_36.annot');
[dummy,l3_lh,c3_lh] = read_annotation(path_annot_lh);
path_annot_lh = strcat(base_path_annot_lh,'_36.annot');
[dummy,l4_lh,c4_lh] = read_annotation(path_annot_lh);

% Take care of user colortable if provided
if nargin >= 6
    count_rh = 0;
    count_lh = 0;
    i_rh = [];
    i_lh = [];
    for i = 1:1:length(llist{1})
        char(llist{1}(i))
        if findstr(char(llist{1}(i)),'rh_')
            count_rh = count_rh + 1;
            i_rh = [i_rh i];
            llist_rh{count_rh} = llist{1}(i);
        elseif findstr(char(llist{1}(i)),'lh_')
            count_lh = count_lh + 1;
            i_lh = [i_lh i];
            llist_lh{count_lh} = llist{1}(i);
        end
    end
    
    % Generate separate custom colormaps for right and left hemisphere
    CM_rh = CM(i_rh,:); 
    CM_lh = CM(i_lh,:);
end


%% RIGHT HEMISPHERE
% Generate a matrix vColor(#verices x 3), where each line contains the
% color of the corresponding vertex.
if nargin < 6  % if CM and llist are not provided, use random colors or annot colortable
    vColor_rh = zeros(nv_rh,3);
    
    
%     for i=1:c1_rh.numEntries
%         if strfind(c1_rh.struct_names{i},'_')
%             indexVerticesRoi_rh = find(l1_rh == c1_rh.table(i,5));
%             if randomcolor
%                 thisColor_rh = rand([1 3]);
%             else
%                 thisColor_rh = c1_rh.table(i,1:3);
%             end
%             vColor_rh(indexVerticesRoi_rh,1:3) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
%             vIndex_rh(indexVerticesRoi_rh) =  c1_rh.struct_names{i}; 
%         end
%     end
%     
%     for i=1:c2_rh.numEntries
%         if strfind(c2_rh.struct_names{i},'_')
%             indexVerticesRoi_rh = find(l2_rh == c2_rh.table(i,5));
%             if randomcolor
%                 thisColor_rh = rand([1 3]);
%             else
%                 thisColor_rh = c2_rh.table(i,1:3);
%             end
%             vColor_rh(indexVerticesRoi_rh,1:3) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
%         end
%     end
%     
%     for i=1:c3_rh.numEntries
%         if strfind(c3_rh.struct_names{i},'_')
%             indexVerticesRoi_rh = find(l3_rh == c3_rh.table(i,5));
%             if randomcolor
%                 thisColor_rh = rand([1 3]);
%             else
%                 thisColor_rh = c3_rh.table(i,1:3);
%             end
%             vColor_rh(indexVerticesRoi_rh,1:3) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
%         end
%     end
    
    for i=1:c4_rh.numEntries
        %if strfind(c4_rh.struct_names{i},'_')
         indexVerticesRoi_rh = find(l4_rh == c4_rh.table(i,5));
         if randomcolor
            thisColor_rh = rand([1 3]);
         else
            thisColor_rh = c4_rh.table(i,1:3);
         end
            vColor_rh(indexVerticesRoi_rh,1:3) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
            [vIndex_rh{indexVerticesRoi_rh}]  = deal(c4_rh.struct_names{i});
        %end
    end
else    % CM and llist provided by the user
    vColor_rh = zeros(nv_rh,size(CM,2));
    for i=1:c1_rh.numEntries
        if strfind(c1_rh.struct_names{i},'_')
            index_rh = find(strcmp(llist_rh,c1_rh.struct_names{i}));
            if ~isempty(index_rh)
                indexVerticesRoi_rh = find(l1_rh == c1_rh.table(i,5));
                thisColor_rh = CM_rh(index_rh,1:end);
                vColor_rh(indexVerticesRoi_rh,1:end) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
            end
        end
    end
    
    for i=1:c2_rh.numEntries
        if strfind(c2_rh.struct_names{i},'_')
            index_rh = find(strcmp(llist_rh,c2_rh.struct_names{i}));
            if ~isempty(index_rh)
                indexVerticesRoi_rh = find(l2_rh == c2_rh.table(i,5));
                thisColor_rh = CM_rh(index_rh,1:end);
                vColor_rh(indexVerticesRoi_rh,1:end) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
            end
        end
    end    

    for i=1:c3_rh.numEntries
        if strfind(c3_rh.struct_names{i},'_')
            index_rh = find(strcmp(llist_rh,c3_rh.struct_names{i}));
            if ~isempty(index_rh)
                indexVerticesRoi_rh = find(l3_rh == c3_rh.table(i,5));
                thisColor_rh = CM_rh(index_rh,1:end);
                vColor_rh(indexVerticesRoi_rh,1:end) = repmat(thisColor_rh,length(indexVerticesRoi_rh),1);
            end
        end
    end    
end

% Surface plot according to vColor colortable
if addview
    h(1) = figure('Visible','on');
    %clear temp;
    p = patch('faces',f_rh,'vertices',v_rh,'facecolor','flat','edgecolor','none','facealpha',1);
    %for i = 1:1:3
    %    temp(:,:,i) = vColor_rh(:,i);
    %end    
    set(p,'FaceVertexCData',vColor_rh);
    daspect([1 1 1]);
    view([90 0]); % sets the viewpoint to the Cartesian coordinates x, y, and z
    camlight; % creates a light right and up from camera
    lighting gouraud; % specify lighting algorithm
    axis off;
end



%% LEFT HEMISPHERE
% Generate a matrix vColor(#verices x 3), where each line contains the
% color of the corresponding vertex.
if nargin < 6 % if CM and llist are not provided, use FreeSurfer colortable
    vColor_lh = zeros(nv_lh,3);
%     for i=1:c1_lh.numEntries
%         if strfind(c1_lh.struct_names{i},'_')
%             indexVerticesRoi_lh = find(l1_lh == c1_lh.table(i,5));
%             if randomcolor
%                 thisColor_lh = rand([1 3]);
%             else
%                 thisColor_lh = c1_lh.table(i,1:3);
%             end
%             vColor_lh(indexVerticesRoi_lh,1:3) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
%         end
%     end
%     
%     for i=1:c2_lh.numEntries
%         if strfind(c2_lh.struct_names{i},'_')
%             indexVerticesRoi_lh = find(l2_lh == c2_lh.table(i,5));
%             if randomcolor
%                 thisColor_lh = rand([1 3]);
%             else
%                 thisColor_lh = c2_lh.table(i,1:3);
%             end
%             vColor_lh(indexVerticesRoi_lh,1:3) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
%         end
%     end
%     
%     for i=1:c3_lh.numEntries
%         if strfind(c3_lh.struct_names{i},'_')
%             indexVerticesRoi_lh = find(l3_lh == c3_lh.table(i,5));
%             if randomcolor
%                 thisColor_lh = rand([1 3]);
%             else
%                 thisColor_lh = c3_lh.table(i,1:3);
%             end
%             vColor_lh(indexVerticesRoi_lh,1:3) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
%         end
%     end
    for i=1:c4_lh.numEntries
        
        %if strfind(c4_lh.struct_names{i},'_')
            indexVerticesRoi_lh = find(l4_lh == c4_lh.table(i,5));
            if randomcolor
                thisColor_lh = rand([1 3]);
            else
                thisColor_lh = c4_lh.table(i,1:3);
            end
            vColor_lh(indexVerticesRoi_lh,1:3) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
            [vIndex_lh{indexVerticesRoi_lh}]  = deal(c4_lh.struct_names{i});
        %end
    end
else % CM and llist provided by the user
    vColor_lh = zeros(nv_lh,size(CM,2));
    for i=1:c1_lh.numEntries
        if strfind(c1_lh.struct_names{i},'_')
            index_lh = find(strcmp(llist_lh,c1_lh.struct_names{i}));
            if ~isempty(index_lh)
                indexVerticesRoi_lh = find(l1_lh == c1_lh.table(i,5));
                thisColor_lh = CM_lh(index_lh,1:end);
                vColor_lh(indexVerticesRoi_lh,1:end) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
            end
        end
    end
    
    for i=1:c2_lh.numEntries
        if strfind(c2_lh.struct_names{i},'_')
            index_lh = find(strcmp(llist_lh,c2_lh.struct_names{i}));
            if ~isempty(index_lh)
                indexVerticesRoi_lh = find(l2_lh == c2_lh.table(i,5));
                thisColor_lh = CM_lh(index_lh,1:end);
                vColor_lh(indexVerticesRoi_lh,1:end) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
            end
        end
    end    

    for i=1:c3_lh.numEntries
        if strfind(c3_lh.struct_names{i},'_')
            index_lh = find(strcmp(llist_lh,c3_lh.struct_names{i}));
            if ~isempty(index_lh)
                indexVerticesRoi_lh = find(l3_lh == c3_lh.table(i,5));
                thisColor_lh = CM_lh(index_lh,1:end);
                vColor_lh(indexVerticesRoi_lh,1:end) = repmat(thisColor_lh,length(indexVerticesRoi_lh),1);
            end
        end
    end 
end

% Surface plot according to vColor colortable
if addview
    h(2) = figure('Visible','on');
    p = patch('faces',f_lh,'vertices',v_lh,'facecolor','flat','edgecolor','none','facealpha',1); 
    set(p,'FaceVertexCData',vColor_lh);
    daspect([1 1 1]);
    view([90 0]); % sets the viewpoint to the Cartesian coordinates x, y, and z
    camlight; % creates a light right and up from camera
    lighting gouraud; % specify lighting algorithm
    axis off;
end


% PLOT BOTH HEMISPHERES
% Surface plot according to vColor colortable
if addview
    h(3) = figure('Visible','on');
else
    h = figure('Visible','on');
end
% patch create filled polygones and adds a filled patch objects to the current axes
p = patch('faces',f_rh,'vertices',v_rh,'facecolor','flat','edgecolor','none','facealpha',1);
set(p,'FaceVertexCData',vColor_rh);
p = patch('faces',f_lh,'vertices',v_lh,'facecolor','flat','edgecolor','none','facealpha',1);
set(p,'FaceVertexCData',vColor_lh);
daspect([1 1 1]);
view([0 90]); % sets the viewpoint to the Cartesian coordinates x, y, and z
camlight;     % creates a light right and up from camera
lighting gouraud; % specify lighting algorithm
axis off;




