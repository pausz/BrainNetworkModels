%% Transition in and out of an absence seizure for the spatially uniform case as presented in 
% [1] Breakspear et al., (2005 
% A Unifying Explanation of Primary Generalized Seizures Through Nonlinear Brain Modelling and Bifurcation Analysis.
% Crebral Cortex

% Approximate runtime: 80 [s] workstation March 2015
% Approximate memory:  500 MB
% Approximate storage: XX

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
 options.Dynamics.BrainState = 'absence';

  
%%Load default parameters for specified connectivity and dynamics
options.Connectivity = GetConnectivity(options.Connectivity);
options.Dynamics = SetDynamicParameters(options.Dynamics);
options = SetIntegrationParameters(options);

%% Integration   
options.Integration.dt = 2^-3;
options.Integration.iters = 2^14;


%% Update Parameters  
options = SetDerivedParameters(options);
options = SetInitialConditions(options); 

%% Nu_se values
LinearlyStable_nu_se = 1000;
Supercritical_nu_se  = 1800;
FirstPeriodDoubling_nu_se = 3400;
SecondPeriodDoubling_nu_se = 4200;
SeizureRegion = '1';
SeizureRegionIndex = find(strcmpi(options.Connectivity.NodeStr, SeizureRegion));
 
 %% Other
 % Increased verbosity, here it enables the integration step counter.
 % options.Other.verbosity = 1;
 
options.Dynamics.nu_se = LinearlyStable_nu_se;
options = SetInitialConditions(options);


%% Output
DSF_t = 1;  %with dt = 2^-3 and iters 2^14 each continuation has a durationof 2048ms 
cont = 16;  % total number of continuations to store 
tpts = (options.Integration.iters / DSF_t) * cont;
Store_phi_e = [];
 
%% Initial integration, to clear transient
 Continuations = 8;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for initial integration...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   options = UpdateInitialConditions(options);
   
 end

 
%% Pre seizure
 Continuations = 2;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for pre seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end,:)];
   options = UpdateInitialConditions(options);
 end


%% Supercritical instability
 options.Dynamics.nu_se(:) =  Supercritical_nu_se;
 Continuations = 4;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for middle seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end


%% First Period Doubling
 options.Dynamics.nu_se(:) =  FirstPeriodDoubling_nu_se; 
 Continuations = 4;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for full seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end
 
 
%% Second Period Doubling
 options.Dynamics.nu_se(:) =  SecondPeriodDoubling_nu_se; 
 Continuations = 4;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for full seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end

 
%% Post seizure
 options.Dynamics.nu_se =LinearlyStable_nu_se;
 Continuations = 2;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for post seizure...'])
   [phi_e, dphi_e, V_e, dV_e, V_s, dV_s, V_r, dV_r, t, options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, :)];
   options = UpdateInitialConditions(options);
 end

toc;

%% Plot

PlotTimeSeries(Store_phi_e)

%%%EoF%%%