names = {'Cphh','Cphm','Cphl','Cplh','Cplm','Cpll',...
	'Cvhh','Cvhm','Cvhl','Cvlh','Cvlm','Cvll',...
  'Cchh','Cchm','Cchl','Cclh','Cclm','Ccll',...
  'Ephh','Ephm','Ephl','Eplh','Eplm','Epll',...
  'Evhh','Evhm','Evhl','Evlh','Evlm','Evll',...
  'Echh','Echm','Echl','Eclh','Eclm','Ecll',...
  'Sphh','Sphm','Sphl','Splh','Splm','Spll',...
  'Svhh','Svhm','Svhl','Svlh','Svlm','Svll',...
  'Schh','Schm','Schl','Sclh','Sclm','Scll',...
  'Jpjj','Jpjm','Jphl','Jplh','Jplm','Jpll',...
  'Jvhh','Jvhm','Jvhl','Jvlh','Jvlm','Jvll',...
  'Jchh','Jchm','Jchl','Jclh','Jclm','Jcll'};
connames = {'overall cue','overall linear stim','overall interaction',...
'P cue effect','P cue effect_stim','P stim linear',...
'P stim interaction','P judgement linear','P judgment cue interaction',...
'V cue effect','V cue effect_stim','V stim linear',...
'V stiminteraction','V judgement linear','V judgment cue interaction',...
'C cue effect','C cue effect_stim','C stim linear',...
'C stiminteraction','C judgement linear','C judgment cue interaction',...
'P stim dummy','V stim dummy','C stim dummy','P localizer'};

T = readtable('/Users/h/Documents/projects_local/social_influence/design_interleaved/72regressors.csv', 'HeaderLines',1);
cons = table2array(T)';
% cons = [1	1	1	-1	-1	-1	0	0	0	0	0	0	0	0	0	0	0	0;
% 0	0	0	0	0	0	1	1	1	-1	-1	-1	0	0	0	0	0	0;
% 0	0	0	0	0	0	1	0	-1	1	0	-1	0	0	0	0	0	0;
% 0	0	0	0	0	0	1	0	-1	-1	0	1	0	0	0	0	0	0;
% 0	0	0	0	0	0	0	0	0	0	0	0	1	0	-1	1	0	-1;
% 0	0	0	0	0	0	0	0	0	0	0	0	1	0	1	-1	0	-1];   % StimLvH_stim

load('/Users/h/Documents/projects_local/social_influence/design_interleaved/jitter_type05/best_design_struct.mat');

% con = cons';

%% Vanilla - HRF is exactly correct, no epochs

true_eff_size = [0.1 0.3 0.5 0.7 1 1.3 1.5 1.8 2];
OUT = {};

for i = 1:length(true_eff_size)

    fprintf('%d ', i)

    OUT{i} = onsets2power(best_design_struct.ons, 'TR', best_design_struct.TR, 'contrasts', cons, 'n_iter', 50, 'true_effect_size', true_eff_size(i));

end

%

for i = 1:length(true_eff_size)

    power05(i, :) = OUT{i}.contrasts.power_est05;

    power001(i, :) = OUT{i}.contrasts.power_est001;

    powerfwer(i, :) = OUT{i}.contrasts.power_estfwer;

end

create_figure('con power', 1, 3);
plot(true_eff_size, power05);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);
legend(connames)

subplot(1, 3, 2)
plot(true_eff_size, power001);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

subplot(1, 3, 3)
plot(true_eff_size, powerfwer);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

drawnow

%% With HRF mismodeling, no epochs

true_eff_size = [0.1 0.3 0.5 0.7 1 1.3 1.5 1.8 2];
OUThrfmis = {};

for i = 1:length(true_eff_size)

    fprintf('%d ', i)

    OUThrfmis{i} = onsets2power(best_design_struct.ons, 'TR', best_design_struct.TR, 'hrfshape', 'contrasts', cons, 'n_iter', 50, 'true_effect_size', true_eff_size(i));

end

%

for i = 1:length(true_eff_size)

    power05(i, :) = OUThrfmis{i}.contrasts.power_est05;

    power001(i, :) = OUThrfmis{i}.contrasts.power_est001;

    powerfwer(i, :) = OUThrfmis{i}.contrasts.power_estfwer;

end

create_figure('con power with hrf misspec', 1, 3);
plot(true_eff_size, power05);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);
legend(connames)

subplot(1, 3, 2)
plot(true_eff_size, power001);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

subplot(1, 3, 3)
plot(true_eff_size, powerfwer);
xlabel('True effect size');
ylabel('Power');
axis tight;
set(gca, 'YLim', [0 1]);

drawnow
