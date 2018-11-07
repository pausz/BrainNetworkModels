%% Transition in and out of an absence seizure for the spatially uniform case as presented in 
% [1] Breakspear et al., (2005) 
% A Unifying Explanation of Primary Generalized Seizures Through Nonlinear Brain Modelling and Bifurcation Analysis.
% Crebral Cortex

% Approximate runtime: ~ 80 [s] workstation March 2015
% Approximate memory:  500 MB
% Approximate storage: 5.4 MB

%% Description of the simulation
% This simulation intends to reproduce key results shown in Figure 3 of
% [1].
% 
% a) There are two uncoupled nodes, so in principle, their dynamics should be identical.
% b) The model is initialized with the parameters for an absence seizure as
%    described in Table 1 in [1].
% c) The connectivity parameter 'nu_se' is increased from a base value to an 
%    end value in 3 steps.   

tic;
%% Connectivity
 options.Connectivity.WhichMatrix = 'Random';
 options.Connectivity.NumberOfNodes = 2;
 options.Connectivity.invel = 1/7;

%% Model
 options.Dynamics.WhichModel = 'BRRW';
 options.Dynamics.BrainState = 'ha';

  
%%Load default parameters for specified connectivity and dynamics
options.Connectivity = GetConnectivity(options.Connectivity);
options.Dynamics = SetDynamicParameters(options.Dynamics);
options = SetIntegrationParameters(options);

%% Integration   
options.Integration.dt = 2^-6;
options.Integration.iters = 2^15;


%% Update Parameters  
options = SetDerivedParameters(options);
options = SetInitialConditions(options); 

%% Nu_se values
FirstFixedPoint_nu_sn  = 5000;
SecondFixedPoint_nu_sn = 6000;
LimitCycle_nu_sn = 8500;
SeizureRegion = '1';
SeizureRegionIndex = find(strcmpi(options.Connectivity.NodeStr, SeizureRegion));
 
 %% Other
 % Increased verbosity, here it enables the integration step counter.
 % options.Other.verbosity = 1;
 
options = SetInitialConditions(options);


%% Output
DSF_t = 1;  %with dt = 2^-3 and iters 2^14 each continuation has a durationof 2048ms 
cont = 16;  % total number of continuations to store 
tpts = (options.Integration.iters / DSF_t) * cont;
 
%% Initial integration, to clear transient
 Continuations = 8;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for initial integration...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   %Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end,:)];
   options = UpdateInitialConditions(options);
   
 end

%%
Store_phi_e = [];

%% First fixed point
options.Dynamics.nu_sn(:) =  FirstFixedPoint_nu_sn;
Continuations = 16;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for pre seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end,:)];
   options = UpdateInitialConditions(options);
 end


%% Second fixed point
 options.Dynamics.nu_sn(:) =  SecondFixedPoint_nu_sn;
 Continuations = 16;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for supercritical instability ...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end


%% Limit cycle
 options.Dynamics.nu_sn(:) =  LimitCycle_nu_sn; 
 Continuations = 32;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for seizure onset, first period doubling ...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end
  

toc;

%% Plot

PlotTimeSeries(Store_phi_e)

%% Save results
% Save everything
% save('ContinuationSeizureScript')
% % Save options
% save('ContinuationSeizureScriptOptions', 'options')
% % Save initial conditions for python
% InitialConditions = options.Dynamics.InitialConditions;
% save('AbsenceInitialConditions', 'InitialConditions')

%%%EoF%%%