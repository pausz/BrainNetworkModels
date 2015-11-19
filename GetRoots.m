%% Transcendental steady state equation of the
%  corticothalamic model (BRRW).
% ARGUMENTS:
%         qe    -- Initial guess 
%         nus   -- Vector with the eight corticothalamic synaptic weights
%         theta -- Voltage threshold
%         qmax  -- Maximum firing rate
%         sigma -- Width of transition
%         variant -- Variant of the steady state equation. '' or 'derivative'
%
% OUTPUT: 
%         Fy=f(y) -- Transcendetal equation to find the steady states of
%                    the excitatory population
%
% REQUIRES:
%         Sigma()
%
% USAGE:
%{
      N = 100;
      V = linspace(0, 6, N);
      Theta = 3; % mV
      sigma = 1; % mV
      SigmaFunction = Sigma(V, 1, Theta, sigma);
      figure, plot(V, SigmaFunction); 
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fy, Fy_plus, Fy_minus] = GetRoots(qe, nus, qmax, theta, sigma, variant)%#OK

if nargin < 6,
    variant = '';
end
  
nuee = nus(1);
nuei = nus(2);
nues = nus(3);
nuse = nus(4);
nusr = nus(5);
nusn = nus(6);
nure = nus(7);
nurs = nus(8);

A = nuee + nuei;
B = nurs / nues;

% Sigmoid
S   = @(V) Sigma(V, qmax, theta, sigma, '');
% First derivative of Sigmoid
dS  = @(V) Sigma(V, qmax, theta, sigma, 'first'); 
% Inverse of Sigmoid
iS  = @(Q) Sigma(Q, qmax, theta, sigma, 'inverse'); 
% First derivative of Inverse of Sigmoid
diS = @(Q) Sigma(Q, qmax, theta, sigma, 'inv_first');

Fy_plus  = [];
Fy_minus = []; 
% This equation assumes phin = 1; /s
switch variant
    case{''}
        Fy       = iS(qe) - A .* qe - nues .*S(nuse  .* qe + nusr.* S(nure .*qe + B .* (iS(qe) - A .* qe)) + nusn);
        Fy_plus  = iS(qe) - A .* qe - nues .* qmax;
        Fy_minus = iS(qe) - A .* qe;
    case{'derivative'}
        Fy = diS(qe) - A + (-nuse * dS(nuse  .* qe + nusr.* S(nure .*qe + B .* (iS(qe) - A .* qe)) + nusn)) .* ((nuse + nusr .* dS(nure .*qe + B .* (iS(qe) - A .* qe)) .* (nure + B .* (diS(qe) - A))));

end

end