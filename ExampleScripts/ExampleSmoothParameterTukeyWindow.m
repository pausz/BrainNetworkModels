
% Used in surface_afr_focal_absence_seizure_no_noise_tukey.py
% Absence parameters
LinearlyStable_nu_se = 10.0e2; 
Supercritical_nu_se  = 18.0e2;
FirstPeriodDoubling_nu_se = 34.0e2; 
SecondPeriodDoubling_nu_se = 42.0e2;
BeyondAbsenceValue_nu_se = 50.0e2;

dt = 2^-3; %ms
simulation_length = 25000; %ms

first_chunk = LinearlyStable_nu_se * ones(5000 / dt);
last_chunk  = first_chunk;
w = tukeywin(simulation_length / dt, 0.75);

nu_se = w * (BeyondAbsenceValue_nu_se - LinearlyStable_nu_se) + LinearlyStable_nu_se;

plot(nu_se)