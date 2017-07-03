%% Transcendental steady state equation of the
%  corticothalamic model (BRRW).
% ARGUMENTS:
%         qe    -- Initial guess 
%         nus   -- Vector with the eight corticothalamic synaptic weights
%         theta -- Voltage threshold
%         qmax  -- Maximum firing rate
%         sigma -- Width of transition
%         variant -- Variant of the steady state equation: '' or 'derivative'
%
% OUTPUT: 
%         [Fy, Fy_plus, Fy_minus] where Fy Transcendetal equation to find the steady states of
%                    the excitatory population and its bounds (Fy_plus and Fy_minus)
%
% REQUIRES:
%         Sigma()
%
% USAGE:
%{
      N = 1000;
      qe = linspace(0, 340, N);
      theta = 0.003;  % mV
      sigma = 0.001;  % mV
      qmax  = 340;    % /s
      nus   = [0.0078   -0.0099    0.0009    0.0027   -0.0013    0.0066 0.0002    0.0001];
      [Fy, Fyp, Fym] = GetRoots(qe, nus, qmax, theta, (pi/sqrt(3))*sigma);
      figure, plot(qe, [Fy; Fy_plus; Fy_minus);
      hold on;
      [dFy, ~, ~] = GetRoots(qe, nus, qmax, theta, (pi/sqrt(3))*sigma, 'derivative');
      figure, plot(qe, [Fy; Fy_plus; Fy_minus);
      
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Fy, Fy_plus, Fy_minus] = GetRoots(qe, nus, qmax, theta, sigma, variant)%#OK

if nargin < 6,
    variant = '';
end

% Assign nus to new variables so it is easier to compare with Eqs in papers
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