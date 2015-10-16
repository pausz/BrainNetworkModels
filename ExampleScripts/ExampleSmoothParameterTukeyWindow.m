
% Used in surface_afr_focal_absence_seizure_no_noise_tukey.py
% Absence parameters
LinearlyStable_nu_se = 10.0e2; 
Supercritical_nu_se  = 18.0e2;
FirstPeriodDoubling_nu_se = 34.0e2; 
SecondPeriodDoubling_nu_se = 42.0e2;
BeyondAbsenceValue_nu_se = 50.0e2;

dt = 2^-4; %ms
simulation_length = 25000; %ms

fc = 5000;
lc = 5000;

first_chunk = LinearlyStable_nu_se * ones(fc / dt, 1);
last_chunk  = LinearlyStable_nu_se * ones(lc / dt, 1);
w = tukeywin((simulation_length - (fc+lc)) / dt, 0.15);

nu_se = cat(1, first_chunk, w * (BeyondAbsenceValue_nu_se - LinearlyStable_nu_se) + LinearlyStable_nu_se, last_chunk);
time = 0:dt:simulation_length-dt;
plot(time, nu_se)