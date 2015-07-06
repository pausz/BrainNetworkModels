%% Quick and dirty version, without smooth transition in and out of
%% seizure for the global case
%
% Approximate runtime: XX workstation circa 2012
% Approximate memory: XX
% Approximate storage: XX


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

%% Check phi_n
plot(options.Dynamics.phi_n)

%%Seizure values
Base_nu_se = 1000;
Middle_nu_se = 2000;
Seizure_nu_se = 4400;
SeizureRegion = '1';
SeizureRegionIndex = find(strcmpi(options.Connectivity.NodeStr, SeizureRegion));
 
 %% Other
 % Increased verbosity, here it enables the integration step counter.
 % options.Other.verbosity = 1;
 
 
options.Dynamics.nu_se = Base_nu_se;
options = SetInitialConditions(options);


%% Output
DSF_t = 1;  %with dt = 2^-3 and iters 2^14 each continuation has a duration of 2048ms 
DSF_x = 1;
Store_phi_e = [];
Store_phi_e = [];
 
 
%% Initial integration, to clear transient
 Continuations = 8;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for initial integration...'])
   %options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
   options = UpdateInitialConditions(options);
   
 end

 
%% Pre seizure
 Continuations = 2;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for pre seizure...'])
   %options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end,1:DSF_x:end)];
   options = UpdateInitialConditions(options);
 end


%% Seizure Middle
 options.Dynamics.nu_se(:) =  Middle_nu_se;
 Continuations = 8;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for middle seizure...'])
   %options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, 1:DSF_x:end)];
   options = UpdateInitialConditions(options);
 end


%% Seizure Full
 options.Dynamics.nu_se(:) =  Seizure_nu_se; 
 Continuations = 8;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for full seizure...'])
   %options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end, 1:DSF_x:end)];
   options = UpdateInitialConditions(options);
 end

 
%% Post seizure
 options.Dynamics.nu_se = Base_nu_se;
 Continuations = 2;
 for k = 1:Continuations,
   disp(['Continuation ' num2str(k) ' of ' num2str(Continuations) ' for post seizure...'])
   %options.Dynamics.phi_n = 1e-3.*ones(options.Integration.iters+options.Integration.maxdelayiters, options.Connectivity.NumberOfNodes);
   [phi_e dphi_e V_e dV_e V_s dV_s V_r dV_r t options] = BRRW_heun(options);
   Store_phi_e = [Store_phi_e ; phi_e(1:DSF_t:end,1:DSF_x:end)];
   options = UpdateInitialConditions(options);
 end


%% Plot

PlotTimeSeries(Store_phi_e)

%%%EoF%%%