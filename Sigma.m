%% Returns either sigma function, its inverse, or its derivative. 
%
% ARGUMENTS:
%         V     -- Vector of values at which we want to evaluate function. 
%         Qmax  -- Peak value
%         Theta -- Midpoint of transition
%         sigma -- width of transition
%         Variant -- '' || 'inverse' || 'derivative'
%
% OUTPUT: 
%         S -- The 'Variant' of the sigma function evaluated at 'V'
%
% REQUIRES:
%        none
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
% MODIFICATION HISTORY:
%     SAK(17-11-2009) -- Original.
%     SAK(04-12-2009) -- Added inverse...
%     SAK(05-01-2010) -- Added derivative...
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function S = Sigma(V,Qmax,Theta,sigma,Variant)
  if nargin<5,
    Variant = '';
  end
  if nargin<4,
     Theta = 2^-1;
  end
  if nargin<3,
    sigma = 2^-3;
  end
  if nargin<2,
    Qmax = 1;
  end

  PiOnSqrt3 = 1.813799364234217836866491779801435768604278564;
%                              ^?
  S = inf(size(V));
  switch lower(Variant),
    case{'', 'sigmoid'}
      S = Qmax ./ (1 + exp(-PiOnSqrt3.*((V-Theta)./sigma)));
    case {'inverse'},
      Q = V;          % Only for consistency with the notation
      S = Theta + (sigma/PiOnSqrt3) .* (log(Q) - log(Qmax-Q));
    case{'inv_first'} % first order derivative wrt Q
      Q = V;
      S = (sigma/PiOnSqrt3) * ( 1./Q + 1./(Qmax - Q));  
    case{'inv_second'}
      Q = V;
      S = (sigma/PiOnSqrt3) * (1./(Qmax - Q).^2 - 1./Q.^2);
    case{'inv_third'}
      Q = V;
      S = 2*(sigma/PiOnSqrt3) * (1./(Qmax - Q).^3 + 1./Q.^3);
    case{'first'}     % first order derivative wrt V
      w = exp(-PiOnSqrt3.*((V-Theta)./sigma));
      S = (PiOnSqrt3.*Qmax./sigma) .* w ./ ((1+w).*(1+w));
    case{'second'} % second order derivative wrt V
      w  = exp(-PiOnSqrt3.*((V-Theta)./sigma));
      w2 = exp(-2*PiOnSqrt3.*((V-Theta)./sigma));
      S = (((2*Qmax*(PiOnSqrt3)^2) / Theta^2) .* w2) ./ ((1 + w) .* (1 + w) .* (1 + w))  - ...
          ((Qmax*(PiOnSqrt3)^2) / Theta^2) .* w ./ ((1 + w) .* (1 + w));
    case{'third'} % third order derivative wrt V
      w  = exp(-PiOnSqrt3.*((V-Theta)./sigma));
      w2 = exp(-2*PiOnSqrt3.*((V-Theta)./sigma));
      w3 = exp(-3*PiOnSqrt3.*((V-Theta)./sigma));
      K = ((Qmax*(PiOnSqrt3)^3) / Theta^3);
      S = K .* w ./ ((1 + w) .* (1 + w)) -  6 * K .* w2 ./ ((1 + w) .* (1 + w) .* (1 + w)) + 6 * K .* w3 ./ ((1 + w) .* (1 + w) .* (1 + w) .* (1 + w));        
    otherwise
      error(['BrainNetworkModels:' mfilename ':UnknownVariant'],'Unknown variant of the sigma function requested...');
  end
    
end %function Sigma()
