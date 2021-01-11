%-------------------------------------------------------------------------------
%                             1. simulation 1
%-------------------------------------------------------------------------------
% Simulation 1: Look at effects of ISI mean on design quality and scan time
% Social influence: we've commented it out because we have an idea
% of what the ISI1, ISI2, mean should be.
% --------------------------------------------------------------------------
%
% iter = 100;
%
% ISI1means = [1.5:.25:3.5]; % 0~4
% ISI2means = [0.25:.25:1.75]; % 0 ~2
% nISI1s = length(ISI1means);
% nISI2s = length(ISI2means);
%
%
% [meanrecipvif, scanduration] = deal(zeros(iter, nISIs));
%
% for k = 1:nISI1s
%     for i = 1:iter
%         [meanrecipvif(i, k), vifs, design_struct] = generate_jittered_er_design_HJ('noplot', 'ISI1mean', ISI1means(k), 'ISI2mean', ISI2means(k));
%         scanduration(i, k) = design_struct.scanlength;
%     end
% end
%
% %%
%
% create_figure('Design multicolinearity', 1, 2);
%
% lineplot_columns(1./meanrecipvif, 'markerfacecolor', [.5 .5 1], 'x', ISImeans);
% title('Design colinearity: Higher is worse');
% xlabel('ISI mean');
% ylabel('Harmonic mean of VIFs');
%
% subplot(1, 2, 2);
%
% lineplot_columns(scanduration, 'markerfacecolor', [0 .5 1], 'x', ISImeans);
% title('Scan duration (2 runs together)');
% xlabel('ISI mean');
% ylabel('Duration (sec)');
% plot_horizontal_line(600);



%-------------------------------------------------------------------------------
%                             2. simulation 2
%-------------------------------------------------------------------------------
%% Simulation 2: Generate a population of designs and pick the best
% --------------------------------------------------------------------------
tic
versions = 1;
iter = 100;
ISI1mean = 2;
ISI2mean = 0;
ISI3mean = 1;
ISI4mean = 1.5;
idealLength = 4644;

[meanrecipvif, scanduration] = deal(zeros(iter, 1));
for ver = 1:versions
for i = 1:iter

%         [meanrecipvif(i, 1), vifs, design_struct] = generate_jittered_er_design_HJ('noplot', 'ISImean', ISImean);
        [meanrecipvif(i, 1), vifs, design_struct] = generate_jitter_type03('noplot', 'ISI1mean', ISI1mean, 'ISI2mean', ISI2mean, 'ISI3mean', ISI3mean, 'ISI4mean', ISI4mean);

        scanduration(i, 1) = design_struct.scanlength;

        % save the best so far.
        if meanrecipvif(i) == max(meanrecipvif)
            best_design_struct = design_struct;
        end

        if scanduration(i) <= idealLength && meanrecipvif(i) == max(meanrecipvif(scanduration <= idealLength))
            best_design_struct_under_idealLength = design_struct;
        end

end

toc

% Figure
% --------------------------------------------------------------------------

create_figure('Design population', 1, 1);

plot(scanduration, 1./meanrecipvif, 'ko', 'MarkerFaceColor', [0 .5 1]);
xlabel('Scan duration');
ylabel('Multicolinearity (lower is better)');

[bestrecipvif, wh] = max(meanrecipvif);

plot(scanduration(wh), 1./meanrecipvif(wh), 'ro', 'MarkerFaceColor', [1 .5 .5], 'MarkerSize', 12);

underIdealLength = (scanduration <= idealLength);
vifunderIdealLength = meanrecipvif(underIdealLength);
scandurunder_idealLength = scanduration(underIdealLength);
[bestrecipvif, wh] = max(vifunderIdealLength);

plot(scandurunder_idealLength(wh), 1./vifunderIdealLength(wh), 'ro', 'MarkerFaceColor', [1 .5 1], 'MarkerSize', 12);

% Save best results
% --------------------------------------------------------------------------
output_dir = '/Users/h/Documents/projects_local/social_influence/design_interleaved/jitter_type03';
% diaryname = sprintf('/Users/h/Dropbox/Projects/social_influence/design/jitter/social_inf_Events_best_design_of_10000_%s.txt', strrep(datestr(datetime), ' ', '_') );
diaryname = sprintf([output_dir,'/social_inf_Events_best_design_of_10000_ver-', num2str(ver,'%03.f'), '.txt'] );
diary(diaryname)
print_matrix(best_design_struct.eventlist, best_design_struct.eventlist_names);
diary off

diaryname = sprintf([output_dir,'/social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-', num2str(ver,'%03.f'),'.txt'] );
diary(diaryname)
print_matrix(best_design_struct_under_idealLength.eventlist, best_design_struct_under_idealLength.eventlist_names);
diary off

save(fullfile(output_dir,'best_design_struct.mat'), 'best_design_struct');
save(fullfile(output_dir,'best_design_struct_under_idealLength.mat'), 'best_design_struct_under_idealLength');

end
