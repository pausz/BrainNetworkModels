%% Set options.Bifurcation based on the Model, ie options.Dynamics.WhichModel
%
% NOTE: A COMPLETE SET OF DEFAULTS FOR ALL MODELS HASN'T BEEN FILLED IN YET...
%
% ARGUMENTS:
%           options -- options structure
%
% OUTPUT: 
%           options -- updated with the default bifurcation parameters.
%
% REQUIRES: 
%        MergeStructures() -- 
%
% USAGE:
%{
      <example-commands-to-make-this-function-run>
%}
%
% MODIFICATION HISTORY:
%     SAK(06-01-2010) -- Original.
%     SAK(Nov 2013)   -- Move to git, future modification history is
%                        there...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function options = SetBifurcationOptions(options)

  switch options.Dynamics.WhichModel
    case {'BRRW'}
      defaults.Integrator           = 'BRRW_heun';
      switch lower(options.Dynamics.BrainState)
        case{'eo'}
          defaults.BifurcationParameter = 'csf';
        
        case{'ec'}
          defaults.BifurcationParameter = 'csf';
        
        case{'sleepstage1' 'ss1'}
        case{'sleepstage3' 'ss2'}
        case{'sleepstage2' 'ss3'}
        
        case{'absence' 'petitmal'}
          defaults.BifurcationParameter          = 'nu_se';
          defaults.InitialControlValue           =  9.0e2; %Must be strongly stable fixed point...
          defaults.BifurcationParameterIncrement =  0.625e2;
          defaults.TargetControlValue            = 50.0e2;
          defaults.ErrorTolerance                =  1.0e-6;
          
          defaults.MaxContinuations = 65; %set to 0 for interactive
          defaults.IntegrationsToMergeForNonstable = 10; 
          defaults.AttemptForceFixedPoint = false;
        
        case{'tonicclonic' 'grandmal'}
          defaults.BifurcationParameter = 'csf';
        
        case{'hyperarousal', 'ha'}
            switch lower(options.Bifurcation.BifurcationParameter)
                case{'nu_sn'}
                    defaults.InitialControlValue           = 25e2; %Must be strongly stable fixed point...
                    defaults.BifurcationParameterIncrement =  0.625e2;
                    defaults.TargetControlValue            = 45.0e2;
                case{'nu_ee'}
                    defaults.InitialControlValue           = 24.0e2; %Must be strongly stable fixed point...
                    defaults.BifurcationParameterIncrement =  0.625e2;
                    defaults.TargetControlValue            = 25.0e2;
                case{'nu_sr'}
                    defaults.InitialControlValue           = -25.0e2; %Must be strongly stable fixed point...
                    defaults.BifurcationParameterIncrement =  0.625e2;
                    defaults.TargetControlValue            = -18.0e2;
                case{'nu_se'}
                    defaults.InitialControlValue           =  20.0e2; %Must be strongly stable fixed point...
                    defaults.BifurcationParameterIncrement =  0.625e2;
                    defaults.TargetControlValue            =  45.0e2;
            end
          defaults.ErrorTolerance                =  1.0e-6;
          defaults.MaxContinuations = 65; %set to 0 for interactive
          defaults.IntegrationsToMergeForNonstable = 10; 
          defaults.AttemptForceFixedPoint = false;
        
        otherwise
      end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'FHN'}
%% 
     defaults.Integrator           = 'FHN_heun';
     defaults.BifurcationParameter = 'csf'; %NOTE: When varying csf it's Connectivity dependent.
     defaults.BifurcationParameterIncrement = 0.00025;
     defaults.InitialControlValue  = 0.012; %Must be strongly stable fixed point...
     defaults.TargetControlValue   = 0.030;
     defaults.ErrorTolerance       = 2.000e-7; 
     
     defaults.MaxContinuations = 65; %set to 0 for interactive
     defaults.IntegrationsToMergeForNonstable = 10; 
     defaults.AttemptForceFixedPoint = false;

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedFHN'}
     defaults.Integrator           = 'ReducedFHN_heun';
     defaults.BifurcationParameter = 'csf';
     defaults.BifurcationParameterIncrement = 0.0005;
      options.Bifurcation.ErrorTolerance = 1e-6;
     
     defaults.MaxContinuations = 27; %set to 0 for interactive
     defaults.IntegrationsToMergeForNonstable = 10; 
     defaults.AttemptForceFixedPoint = false;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
   case {'ReducedHMR'}
     defaults.Integrator           = 'ReducedHMR_heun';
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
% % %    case {'<WhichModel>'}
% % % %% Default parameters 
% % %      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     
   otherwise
 end

 if isfield(options,'Bifurcation'),
   options.Bifurcation = MergeStructures(options.Bifurcation, defaults);
 else
   options.Bifurcation = defaults;
 end
 
end %function SetBifurcationOptions()
