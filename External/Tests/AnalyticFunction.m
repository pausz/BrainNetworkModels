%% Functions with know analytic solution for the LBO
%
%
% ARGUMENTS:
%        Vertices     -- Array of size NumberOfVertices x (2 or 3) 
%                        with the locations of the vertices of a triangulation.
%        FunctionType -- Anlaytic function with known Laplacian.
%
% OUTPUT: 
%        AnalyticFunction   -- The resulting value of FunctionType
%        AnalyticLaplacian  -- The value of the corresponding Analytic
%                              Laplacian.
%
% REQUIRES: 
%        cart2sphY
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%


function [AnalyticFunction, AnalyticLaplacian] = AnalyticFunction(Vertices, FunctionType)


% Check dimension, plane dim==2, sphere dim==3

if size(Vertices, 2) == 2,
    x = Vertices(:, 1);
    y = Vertices(:, 2);
elseif size(Vertices, 2) == 3,
    x = Vertices(:, 1);
    y = Vertices(:, 2);
    z = Vertices(:, 3);
end

% Functions on a plane
Linear = @(x) 2*x;
Parabolic = @(x) x.^2;
Exponential = @(x, y) exp(x + y);
Trigonometric = @(x, y) x.^2 + y.^2;

% Functions on a sphere

switch FunctionType,
    case 'Linear',
        %  f = 2x
        AnalyticFunction  = Linear(x);
        %  f_xx + f_yy = 0
        AnalyticLaplacian = zeros(size(AnalyticFunction));
    
    case 'Parabolic',
        %  f = x^2
        AnalyticFunction = Parabolic(x);
        %  f_xx + f_yy = 2
        AnalyticLaplacian = 2*ones(size(AnalyticFunction));
        
    case 'Exponential',
        % f = e^(x+y)
        AnalyticFunction = Exponential(x, y);
        % f_xx + f_yy = 2e^(x+y)
        AnalyticLaplacian = 2*AnalyticFunction;
        
    case 'Trigonometric',
        [~,phi,~] = cart2sphY(x, y, z);
        % f = x^2 + y^2
        AnalyticFunction = Trigonometric(x, y);
        % I think this is wrong. They use the wrong combination of
        % spherical parametrization and def of Laplacian.
        % Even in that case my derivation gives 2*(cos(phi).^(2) - *sin(phi).^2)
        %AnalyticLaplacian = 4*cos(phi).^(2) - 2*sin(phi).^2;
        % This is using the right parametrization and def of Laplacian.
        AnalyticLaplacian = 3*(cos(phi).^2 - sin(phi).^2) + 1;

end %function AnalyticFunction()