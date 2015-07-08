%% LBO tests on a plane
%  Requires matlabmesh, BrainNetworkModels MeshLGPGit
%  Read installation requirements for each toolbox.
%  From *matlabmesh*:
%        + vadd
%        + makeMesh
%        + genpoints
%        + cart2sphY
%        + makeOneRingWeights
%        + vertexArea
%  From *BNM*
%        + AnalyticFunction
%        + WriteOFF
%        + read_off
% From *stimBOLD*
%        + calculateLaplaceBeltramiOperator
%        +
% Parameters that affect the quality: number of points, type of cell area,
% size of neighbourhood.

% Fixed seed PRNG so we can repeat computations
rng(1702925028, 'twister');

NumberOfPoints = 36^2;
MeshType = 'Spherical'; %'Planar', 'Spherical'
FunctionType = 'Trigonometric';
WhichLaplacian = 'belkin'; % 'cot', 'stimbold', 'bnm', 'belkin';

switch MeshType,
    case 'Planar',
        Meshes = {'unit_square_grid', 'unit_square_stratified', 'unit_square_uniform'};
        
    case 'Spherical',
        Meshes = {'sphere_semireg_500', 'sphere_semireg_1000', 'sphere_semireg_2000'};
end
%figure(333)
for ThisMesh=1:size(Meshes,2);
    
%     if generate_planes,
%         % Generate points in a plane
%         uv = genpoints(NumberOfPoints, 2, Meshes{Meshes});
%         uv = vadd(2*uv,[-1,-1]);
%         % Get effective number of points
%         NumberOfPoints  = size(uv,1);
%         TRI = delaunay(uv(:,1), uv(:,2));
%         mesh = makeMesh([uv,zeros(NumberOfPoints,1)], TRI, repmat([0,0,1],NumberOfPoints,1));
%         P  = mesh.v;
%         Pn = mesh.n;
%         n  = size(P,1);
%     else
switch MeshType,
    case 'Planar'
        
        prefix = Meshes{ThisMesh};
        filename=sprintf('./%s.off', prefix);
        [v, f] = read_off(filename);
        mesh.v = v.';
        mesh.f = f.';
        P = mesh.v;
        n  = size(P,1);
        % Should get rid of the redundance and stick to one method.
    case 'Spherical',
        
        prefix = Meshes{ThisMesh};
        filename=sprintf('%s.obj', prefix);
        mesh=readMesh(filename);
        P = mesh.v;
        n  = size(P,1);

end
    
    %Plot for check
%     figure(333)
%     subplot(2, 3, ThisPlane)
%     scatter3(P(:,1),P(:,2),P(:,3));
%     ylabel('y')
%     xlabel('x')
%     view(2)
%     axis equal
%     xlim([-1, 1])
%     ylim([-1, 1])
%     
%     subplot(2, 3, ThisPlane+3)
%     plotMesh(mesh);
%     xlim([-1, 1])
%     ylim([-1, 1])
    
    
    %  Only want to use real interior verts, because estimation near boundary is
    %  very bad in most cases.
    dthresh = 0.6;
    interiorv = (mesh.v(:,1) > -dthresh) &  (mesh.v(:,1) < dthresh)  &   (mesh.v(:,2) > -dthresh)  &    (mesh.v(:,2) < dthresh);
    
    % Get anlaytic results
    [f, LBf] = AnalyticFunction(P, FunctionType);
    Mesh = TriRep(mesh.f, mesh.v);

    switch WhichLaplacian
        case 'cot'
            Wcot = makeOneRingWeights(mesh, 'dcp');
            Dcot = sparse(1:n,1:n,sum(Wcot,2),n,n); 
            Amix = vertexArea(mesh,[],'mixed');
            LBl = -(Dcot-Wcot)*f ./ (2*Amix);
        case 'stimbold'
            [L, A] = calculateLaplaceBeltramiOperator(mesh.v,mesh.f);
            LBl = -L*f ./ (2*A);
        case 'bnm',
            % This one may file for meshes with boundary if the
            % neighbourhood is too large.
            [LapOp, Convergence] = MeshLaplacian(Mesh, 10);
            %Amix = vertexArea(mesh,[],'mixed');
            LBl = LapOp*f;
        case 'belkin',
            % write file to off for read
            %dummy_name = strcat(Planes{ThisPlane}, '.off');
            %WriteOFF(dummy_name, mesh.v, mesh.f)
            opt.dtype='geodesic';
            opt.htype='ddr';
            opt.hs = 8;
            opt.rho = 5;    
            prefix = Meshes{ThisMesh};
            filename=sprintf('./%s.off', prefix);
            [W, A, h] = symmshlp_matrix(filename, opt);
            L = sparse(diag(1./A) * W);
            LBl = L*f;
            
        case 'heat',
            
            % heat-kernel L-B, use all vertices
            % 
            h = 0.04/4;
            AreaT = faceArea(mesh);
            LBl = zeros(size(LBf));
            for k = 1:n
            if mod(k,100) == 0
                fprintf('%d / %d finished (%3.2f%%)\n', k, n, (k/n)*100);
            end
            w = mesh.v(k,:);
            W = exp( -vmag2(vadd(mesh.v, -w)) / (4*h) );
            F = vadd(f,-f(k));
            WF = W .* F;
            ksum = 0;
                for fi = 1:numel(mesh.fidx)
                ti = mesh.f(fi,:);
                tsum = sum( WF(ti) );
                ksum = ksum + tsum * AreaT(fi)/3;
                end
            LBl(k) = ksum / (4*pi*h^2);
            end

            L2 = norm(LBf - LBl) / norm(LBf);
            Lmax = max(abs(LBf - LBl)) / max(abs(LBf));
            fprintf('[heatAll] Normalized L2: %f  Lmax: %f  \n', L2,Lmax);
            
        %case 'my_new_laplacian',
            % parameters for the implementation
            % LBl = A * B *f;
    end

    % Compute L2 norm
    if norm(LBf) == 0
        L2      = norm(LBf-LBl);
        L2int   = norm(LBf(interiorv)-LBl(interiorv));
        Lmax    = max(abs(LBf - LBl));
        Lmaxint = max(abs(LBf(interiorv) - LBl(interiorv)));
        fprintf('L2: %f  L2int: %f  Lmax: %f  Lmaxint: %f\n', L2,L2int, Lmax,Lmaxint);
    % Compute L-inf norm
    else 
        L2      = norm(LBf - LBl) / norm(LBf);
        L2int   = norm(LBf(interiorv)-LBl(interiorv)) / norm(LBf(interiorv));
        Lmax    = max(abs(LBf - LBl)) / max(abs(LBf));
        Lmaxint = max(abs(LBf(interiorv) - LBl(interiorv))) / max(abs(LBf(interiorv)));
        fprintf('#P=%d,COT Normalized L2: %f  L2int: %f  Lmax: %f  Lmaxint: %f\n', NumberOfPoints, L2,L2int, Lmax,Lmaxint);
    end    
    figure(42)
    subplot(2, 3, ThisMesh);
    %surf(reshape(abs(LBlcot-LBf), sqrt(NumberOfPoints), sqrt(NumberOfPoints)));
    SurfaceMesh(Mesh, LBf.')
    colormap(brewermap([], '*RdBu'))
    Clip = max(abs(LBf));
    if Clip ==0;
        Clip=1;
    end
    caxis([-Clip, Clip])
    %caxis([-Clip+max(LBf), Clip+max(LBf)])
    colorbar
    xlim([-1, 1])
    ylim([-1, 1])
    title('LBf')
    
    subplot(2, 3, ThisMesh+3);
    %surf(reshape(abs(LBlcot-LBf), sqrt(NumberOfPoints), sqrt(NumberOfPoints)));
    Mesh = TriRep(mesh.f, mesh.v);
    SurfaceMesh(Mesh, LBl.')
    colormap(brewermap([], '*RdBu'))
    caxis([-Clip, Clip])
    %caxis([-Clip+max(LBf), Clip+max(LBf)])
    colorbar
    xlim([-1, 1])
    ylim([-1, 1])
    title(WhichLaplacian)

end
