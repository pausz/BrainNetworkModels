%% Collect summary information for a connectivity.
%
% ARGUMENTS:
%           Connectivity -- a Connectivity structure
%
% OUTPUT: 
%           SurfaceSummaryInfo -- NumberOfConnections
%                                 minEdgeLength
%                                 maxEdgeLength
%                                 meanEdgeLength
%                                 meanTriangleArea
%                                 minDegree
%                                 maxDegree
%                                 medianDegree
%
% USAGE:
%{
    options.Connetvitity.WhichMatrix = 'EPFL';
    options.Connectivity.Parcellation = '1';
    options.Connectivity.WhichSubject = 'average';
    options.Connectivity.RemoveThalamus = false;
    options.Connectivity.invel = 1;
    options.Connectivity = GetConnectivity(options.Connectivity);
    
    ConnectivitySummaryInfo = GetSurfaceSummaryInfo(options.Connectivity);

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ConnectivitySummaryInfo] = GetConnectivitySummaryInfo(Connectivity)
  
 %% NumberOf...
 ConnectivitySummaryInfo.NumberOfConnections = sum(sum(Connectivity.weights~=0));

 
 %% Lengths
 ConnectivitySummaryInfo.minEdgeLength = min(Connectivity.delay >0);
 ConnectivitySumlaryInfo.maxEdgeLength = max(Connectivity.delay >0);
 ConnectivitySummaryInfo.meanEdgeLength = mean(Connectivity.delay >0);
 ConenctivitySummaryInfo.meanEdgeLength = mean(Connectivity.delay >0);
 
  
 %% Symmetry
 DiffWeights = Connectivity.weights-Connectivity.weights';
 if max(DiffWeights(:)) == 0,
     ConnectivitySummaryInfo.IsDirected = False;
 else
     ConnectivitySummaryInfo.IsDirected = True;
 end
    
 
 %% Degree
 Degree = sum((Connectivity.weights~=0) , 2);% this would be in-degree if the matrix was directed
 ConnectivitySummaryInfo.minDegree = min(Degree);
 ConnectivitySummaryInfo.maxDegree = max(Degree);
 ConnectivitySummaryInfo.medianDegree   = median(Degree);


end %function GetconnectivitySummaryInfo()