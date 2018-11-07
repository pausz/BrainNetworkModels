%% Calculate bifurcation as a function of nu_se for BRRW-absence.
%
% Calculation is done using NodeBifurcation() and subsequent
% visualisation uses PlotNodeBifurcation().
%
% Approximate runtime: 2h15m , Octave, Workstation circa 2012
% Approximate memory:  < 500MB
% Approximate storage: <?>MB 
% From command line:
% matlab -nodesktop -nosplash -r AbsenceBifurcationScriptTwoNodes

%% Some details of our environment...
  %Where is the code
  CodeDir = '..';        %can be full or relative directory path
  ScriptDir = pwd;       %get full path to this script
  cd(CodeDir)            %Change to code directory
  FullPathCodeDir = pwd; %get full path of CodeDir
  ThisScript = mfilename; %which script is being run
  
  %When and Where did we start:
  disp(['Script started: ' when()]) 
  if strcmp(filesep,'/'), %on a *nix machine, write machine details log...
    system('uname -a') 
  end 
  disp(['Running: ' ThisScript])
  disp(['Script directory: ' ScriptDir])
  disp(['Code directory: ' FullPathCodeDir])
 
%% Do the stuff...
  
  %Specify Connectivity to use
  options.Connectivity.WhichMatrix = 'Random';
  options.Connectivity.NumberOfNodes = 2;
  %options.Connectivity.RemoveThalamus = true;
  options.Connectivity.invel = 1.0/7.0;
  
  %Specify Dynamics to use
  options.Dynamics.WhichModel = 'BRRW';
  options.Dynamics.BrainState = 'absence';
  
  %Load default parameters for specified connectivity and dynamics
  options.Connectivity = GetConnectivity(options.Connectivity);
  options.Dynamics = SetDynamicParameters(options.Dynamics);
  options = SetIntegrationParameters(options);
  
  % Change r_ee and v_ee
  options.Dynamics.v =   6;
  options.Dynamics.r_e =150;
  
  % Set intregration
  options.Integration.dt = 2^-3;
  options.Integration.iters = 2^14;
  
  % Set derived parameters
  options = SetDerivedParameters(options);
  options = SetInitialConditions(options);
  
  addpath(genpath('./Bifurcations'))
  options = SetBifurcationOptions(options);
  options.Bifurcation.BifurcationParameterIncrement =  0.625e2;
  options.Bifurcation.ErrorTolerance = 1.0e-6; 
  options.Bifurcation.MaxContinuations = 77;
  options.Bifurcation.AttemptForceFixedPoint = false;
  
  addpath(genpath('./PlottingTools')) %Need this if using interactive mode
  options.Other.verbosity = 4; %42;
  
  %Calcualte the bifurcation
  [ForwardFxdPts, BackwardFxdPts, options] = NodeBifurcation(options);


%% When did we finish:
  disp(['Script ended: ' when()])
%% Save the results
  save(ThisScript, 'ForwardFxdPts', 'BackwardFxdPts', 'options')
%% 
exit
%% Plotting
  %% Select a few nodes
  options.Plotting.OnlyNodes = {'1'};
  
  % plot them
  FigureHandles = PlotNodeBifurcation(ForwardFxdPts, options);
  %%
  %Optionally over plot the Extrema found by back tracking
  options.Plotting.FigureHandles = FigureHandles;
  FigureHandles = PlotNodeBifurcation(BackwardFxdPts, options);

%%%EoF%%%