%% Integrates an ensemble of dx = -x, 
% connected through a weighted network with time delays
%
% Uses Heun method
%
% ARGUMENTS:
%           weights -- Matrix of connection weights between nodes
%           delay   -- Matrix of time delays between nodes in milliseconds
%           options -- A structure which can specify the arguments below:
%                     .iters -- Number iterations for the integration
%                     .dt    -- Length of each time step of the integration in milliseconds 
%                     .a     -- 
%                     .csf   -- Scaling of coupling strength
%                     .Qx    -- Noise term 
%                     .InitialConditions -- Specify a non-default initial 
%                                           state for the random number 
%                                           generators:
%                                       .StateRand  
%                                       .StateRandN  
%                                           And/Or Specify non-random 
%                                           initial conditions:
%                                       .X -- must be >= max time delay long 
%
% OUTPUT: 
%           X -- estimated time course
%           t -- vector of time points for which integration was estimated 
%           StateRand  -- The final state of the random number generator
%           StateRandN -- The final state of the Normal dist. random number generator
%
% USAGE:
%{
      %Specify Connectivity to use
       options.Connectivity.WhichMatrix = 'RM_AC';
       options.Connectivity.invel = 1/7;

      %Specify Dynamics to use
       options.Dynamics.WhichModel = 'SNX';

      %Load default parameters for specified connectivity and dynamics
       options.Connectivity = GetConnectivity(options.Connectivity);
       options.Dynamics = SetDynamicParameters(options.Dynamics);
       options = SetIntegrationParameters(options);
       options = SetDerivedParameters(options);
       options = SetInitialConditions(options);

      %Integrate the network using default options (Network of 38N should take about 2s)
       [X t options] = SNX_heun(options);
%}
%
% MODIFICATION HISTORY:
%     VJ/YAR(<dd-mm-yyyy>) -- Original.
%     SAK(27-10-2008) -- Optimise... (speedup ~140x)
%     SAK(04-10-2008) -- Comment/Structure/Generalise.
%     SAK(17-12-2008) -- Incorporated ability to start from Non-random
%                        initial conditions... primarily to allow
%                        continuation of previous run.
%     SAK(19-01-2009) -- Corrected bug I introduced in calculation of W
%                        Corrected noise contribution to be proportional to
%                        sqrt(dt) rather than dt
%     SAK(21-01-2009) -- Modified from fhn_net_rk.m to use heun method for
%                        consistency between solution order for
%                        deterministic and stochastic components...
%     SAK(28-01-2009) -- Save state of random number generators for use
%                        when continuing from previous run
%     SAK(04-09-2009) -- Changed coupling scale factor parameter from c to 
%                        csf, for more straight forward parameter
%                        consitence across functions...
%     SAK(16-09-2009) -- Following discussion with MW implemented delayed
%                        coupling via linear indexing, also made a number
%                        of other minor optimisations... (speedup ~15x)
%     SAK(17-09-2009) -- Default noise => 0. Cleaned up parameter initialisation.
%     SAK(18-03-2010) -- Modified from FHN_heun()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [X t options] = SNXtess_heun(options)

%Set RandStream to a state consistent with InitialConditions.
 options.Dynamics.InitialConditions.ThisRandomStream.State = options.Dynamics.InitialConditions.StateRand;
 if isoctave(),
   rand('state', options.Dynamics.InitialConditions.ThisRandomStream.State);
 else %Presumably Matlab
   RandStream.setDefaultStream(options.Dynamics.InitialConditions.ThisRandomStream);
 end

%Check sufficient history was provided
 if options.Integration.maxdelayiters>size(options.Dynamics.InitialConditions.X, 1), %Initialconditions aren't sufficiently long enough
   error(['BrainNetworkModels:' mfilename ':InitialConditionsTooShort'],'The InitialConditions provided do not contain enough data points for the maximum delay of the system...');
 end
 
%Set initial state vectors
 x = options.Dynamics.InitialConditions.X(end, :);
 
%Initialise array to store fast variable, including it's history
 X = [options.Dynamics.InitialConditions.X((end-options.Integration.maxdelayiters+1):end, :) ; zeros(options.Integration.iters, options.Connectivity.NumberOfVertices)]; 

%% Integrate the Network of FitzHugh-Nagumo oscillators

 RegionAvg_X = zeros(options.Integration.maxdelayiters+options.Integration.iters,options.Connectivity.NumberOfNodes);
 xhist = zeros(1,options.Connectivity.NumberOfVertices); %need this for when csf = 0...
 fprintf(1,'Integrating for %d steps, currently on step:     ', options.Integration.iters);
 for k = 1:options.Integration.iters
   fprintf(1,'\b\b\b\b%4d', k);
  %Calculate coupling term 
   if options.Dynamics.csf~=0,   %Skip it when checking uncoupled dynamics.
     for n = 1:options.Connectivity.NumberOfNodes,
       RegionAvg_X(:,n) = mean(X(:,options.Connectivity.RegionMapping==n),2); %should calc lidelay for X(:,vertices), extract and then just average subset... 
     end
     RegionAvg_xhist(1,:) = sum(options.Connectivity.weights.*RegionAvg_X(options.Integration.lidelay+k), 1);
     for n = 1:options.Connectivity.NumberOfNodes,
       xhist(1,options.Connectivity.RegionMapping==n) = RegionAvg_xhist(1,n);
     end
   end

  %Solve the differential equation (FitzHugh-Nagumo), using Heun scheme. (see, eg, Mannella 2002 "Integration Of SDEs on a Computer")  
   if options.Dynamics.sqrtQxdt~=0,
     Noise_x = options.Dynamics.sqrtQxdt*randn(1,options.Connectivity.NumberOfVertices);
   else
     Noise_x = 0;
   end
   
   %TODO: Need to enable delays and other adaptions... 
   %TODO: optimise, eg, predivide options.Dynamics.LocalCoupling by
   %                    options.Dynamics.VertexDegree 
   LocalCoupling = (X(options.Integration.maxdelayiters+k-1, :) * options.Dynamics.LocalCoupling); 
   LocalCoupling = options.Integration.dt*options.Dynamics.tau * LocalCoupling;
%keyboard     
   Fx0 = -options.Dynamics.a .* x; 
   
   x1 = x + Fx0*options.Integration.dt - options.Dynamics.dtcsf .* xhist + Noise_x + LocalCoupling;
   
   Fx1 = -options.Dynamics.a .* x1; 
   
   nx = x + options.Integration.dtt*(Fx0 + Fx1) - options.Dynamics.dtcsf .* xhist + Noise_x + LocalCoupling; 

  %Store result of calc in variable for output
   X(options.Integration.maxdelayiters+k,:) = nx;
     
  %Update solution in time
   x = nx; %updating x

 end
 fprintf(1,'\n');
 
 X = X((options.Integration.maxdelayiters+1):end,:); %Throw away initial history...
 
 if nargout > 2
   t = 0:options.Integration.dt:(options.Integration.dt*(options.Integration.iters-1)); %time in milliseconds
 end
 
 if nargout > 3 %Store the state of the random number generators, for continuation...
   if isoctave(),
     options.Dynamics.InitialConditions.StateRand  = rand('state');
   else %Presumably Matlab
     options.Dynamics.InitialConditions.StateRand  = options.Dynamics.InitialConditions.ThisRandomStream.State;
   end
 end
 
end %function SNXtess_heun()
