% iteratively go through dataset and pull out last row
% sub-096_task-cognitive_beh_trajectory
sub = [95,96,97,99];
taskname = {'cognitive',  'vicarious_1', 'vicarious_2','pain'};
for i = 1:length(sub)
for task = 1:4
behavioral_dir = fullfile('/Users/h/Documents/projects_local/social_influence/data/', ['sub-', sprintf('%03d', sub(i))], '/beh/');
filename = fullfile(behavioral_dir, ['sub-',sprintf('%03d', sub(i)),'_task-', taskname{task}, '_beh_trajectory.mat']);
load(filename);
new_trajectory = zeros(size(rating_Trajectory,1),2);
% insert it into a csv file per participant?
for trl = 1:size(rating_Trajectory,1)
new_trajectory(trl,:) =  rating_Trajectory{trl,2}(end,:);
end

T = table(new_trajectory);
T2 = splitvars(T);
T2.Properties.VariableNames = {'ptb_coord_x' 'ptb_coord_y'};
saveFileName = fullfile(behavioral_dir,[strcat('sub-', sprintf('%03d', sub(i))), '_task-',taskname{task},'_beh_trajectory_formatted.csv' ]);
writetable(T2,saveFileName)
end

end

