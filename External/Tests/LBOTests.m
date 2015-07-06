
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
% Parameters that affect the quality: number of points, type of cell area,
% size of neighbourhood.

% Fixed seed PRNG so we can repeat computations
rng(1702925028, 'twister');

NumberOfPoints = 36^2;
FunctionType = 'Linear';
WhichLaplacian= 'stimbold'; % 'cot', 'stimbold', 'bnm', 'belkin';

Planes = {'grid_unit_square', 'stratified_unit_square', 'uniform_unit_square'};
figure(333)
for ThisPlane=1:size(Planes,2);
    % Generate points in a plane
    uv = genpoints(NumberOfPoints, 2, Planes{ThisPlane});
    uv = vadd(2*uv,[-1,-1]);
    % Get effective number of points
    NumberOfPoints  = size(uv,1);
    TRI = delaunay(uv(:,1), uv(:,2));
    mesh = makeMesh([uv,zeros(NumberOfPoints,1)], TRI, repmat([0,0,1],NumberOfPoints,1));
    P  = mesh.v;
    Pn = mesh.n;
    n  = size(P,1);
    
    %Plot for check
    figure(333)
    subplot(2, 3, ThisPlane)
    scatter3(P(:,1),P(:,2),P(:,3));
    ylabel('y')
    xlabel('x')
    view(2)
    axis equal
    xlim([-1, 1])
    ylim([-1, 1])
    
    subplot(2, 3, ThisPlane+3)
    plotMesh(mesh);
    xlim([-1, 1])
    ylim([-1, 1])
    
    
    %  Only want to use real interior verts, because estimation near boundary is
    %  very bad in most cases.
    dthresh = 0.6;
    interiorv = (mesh.v(:,1) > -dthresh) &  (mesh.v(:,1) < dthresh)  &   (mesh.v(:,2) > -dthresh)  &    (mesh.v(:,2) < dthresh);
    
    % Get anlaytic results
    [f, LBf] = AnalyticFunction(P, FunctionType);

    switch WhichLaplacian
        case 'cot'
            LBO Cotangent
            Wcot = makeOneRingWeights(mesh, 'dcp');
            Dcot = sparse(1:n,1:n,sum(Wcot,2),n,n); 
            Amix = vertexArea(mesh,[],'mixed');
            LBl = -(Dcot-Wcot)*f ./ (2*Amix);
        
        case 'stimbold'
            [L, A] = calculateLaplaceBeltramiOperator(mesh.v,mesh.f);
            LBl = -L*f ./ (2*A);
        case 'bnm'
            LBl = 0;
        case 'belkin'
            LBl=0;
   

    % Compute L2 norm
    if norm(LBf) == 0
        L2 = norm(LBf-LBl);
        L2int = norm(LBf(interiorv)-LBl(interiorv));
        Lmax = max(abs(LBf - LBl));
        Lmaxint = max(abs(LBf(interiorv) - LBl(interiorv)));
        fprintf('L2: %f  L2int: %f  Lmax: %f  Lmaxint: %f\n', L2,L2int, Lmax,Lmaxint);
    % Compute L-inf norm
    else 
        L2 = norm(LBf - LBl) / norm(LBf);
        L2int = norm(LBf(interiorv)-LBl(interiorv)) / norm(LBf(interiorv));
        Lmax = max(abs(LBf - LBl)) / max(abs(LBf));
        Lmaxint = max(abs(LBf(interiorv) - LBl(interiorv))) / max(abs(LBf(interiorv)));
        fprintf('#P=%d,COT Normalized L2: %f  L2int: %f  Lmax: %f  Lmaxint: %f\n', NumberOfPoints, L2,L2int, Lmax,Lmaxint);
    end    
    figure(42)
    subplot(2, 3, ThisPlane);
    %surf(reshape(abs(LBlcot-LBf), sqrt(NumberOfPoints), sqrt(NumberOfPoints)));
    Mesh = TriRep(mesh.f, mesh.v);
    SurfaceMesh(Mesh, LBf.')
    colormap(brewermap([], '*RdBu'))
    Clip = max(abs(LBf));
    if Clip ==0;
        Clip=1;
    end
    caxis([-Clip+max(LBf), Clip+max(LBf)])
    colorbar
    xlim([-1, 1])
    ylim([-1, 1])
    title('LBf')
    
    subplot(2, 3, ThisPlane+3);
    %surf(reshape(abs(LBlcot-LBf), sqrt(NumberOfPoints), sqrt(NumberOfPoints)));
    Mesh = TriRep(mesh.f, mesh.v);
    SurfaceMesh(Mesh, LBl.')
    colormap(brewermap([], '*RdBu'))
    caxis([-Clip+max(LBf), Clip+max(LBf)])
    colorbar
    xlim([-1, 1])
    ylim([-1, 1])
    title(WhichLaplacian)

    end
end