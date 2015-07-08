opt.dtype='geodesic';
opt.htype='ddr';
opt.hs = 2;
opt.rho = 3;
nev = 3;


prefix = 'off_files/Saddle'
filename=sprintf('./%s.off', prefix);
[W, A, h] = symmshlp_matrix(filename, opt);
L = sparse(diag(1./A) * W);
Am = sparse(1:length(A), 1:length(A), A);
[evecs, evals] = eigs(L, Am,nev, -1e-5);
evals = diag(evals);
%sort evecs
evals = abs(real(evals));
[evals,idx] = sort(evals);
evecs = evecs(:,idx);
evecs = real(evecs);


filename=sprintf('./%s_sym_dt_%s_ht_%s_hs%d_rho%d', prefix, opt.dtype, opt.htype, opt.hs, opt.rho);
save(filename, 'W', 'A', 'L', 'evecs', 'evals', 'h', 'opt');
