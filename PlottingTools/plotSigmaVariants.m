%% Script to plot the sigmoid function, inverse and derivatives for steadfy state study
%% Plot Sigmoid and its derivatives
Variant = {'', 'first', 'second', 'third'};
YLabels = {'S(V)', 'dS(V) / dV', 'd^{2}S(V) / dV^{2}','d^{3}S(V) / dV^{3}'};
XLabel =  {'V [Volt]'};
N = 100;
V = linspace(-0.01, 0.03, N);
Theta = 0.013;   % V
sigma = 0.0068;  % V
Qmax = 340;      % /s

%% Plot inverse Sigmoid and its derivatives
Variant = {'inverse', 'inv_first', 'inv_second', 'inv_third'};
YLabels = {'S^{-1}(Q)', 'dS(Q) / dQ', 'd^{2}S^{-1}(Q) / dQ^{2}','d^{3}S^{-1}(Q) / dQ^{3}'};
XLabel =  {'Q [s^{-1}]'};
N = 100;
Theta = 0.0013;  % V
sigma = 0.0068;  % V
Qmax = 340;      % /s
V = linspace(0, Qmax, N);

%%
for i = 1:4,
    SigmaFunction = Sigma(V, Qmax, Theta, sigma, Variant{i});
    subplot(2,2,i)
    a = Theta-sigma;
    b = Theta+sigma;
    plot(V, SigmaFunction);
    hold on;
    lims =  axis;
    patch([a b b a],[lims(3) lims(3) lims(4) lims(4)],0.75*ones(1,3),'FaceAlpha', 0.5,'LineStyle','none')
    plot(V, SigmaFunction, 'color', [0 0 1]);
    plot([Theta Theta], [lims(3) lims(4)], 'k--')
    plot([a a], [lims(3) lims(4)], '-.', 'color', 0.65*ones(1,3))
    plot([b b], [lims(3) lims(4)], '-.', 'color', 0.65*ones(1,3))
    xlim([min(V) max(V)])
    ylabel(YLabels{i})
    if i > 2
       xlabel(XLabel{1})
    end
    
end

%%
