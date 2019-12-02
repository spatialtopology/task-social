function vicarious(sub,input_counterbalance_file, run_num, session)
%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow',p.ptb.screenNumber,p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize',p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval',p.ptb.window);
Screen('BlendFunction', p.ptb.window,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% B. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
taskname                       = 'vicarious';

dir_video                      = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                   = fullfile([main_dir,'stimuli','cue','sch']);
counterbalancefile             = fullfile(main_dir,'design','s04_final_counterbalance_with_jitter', [input_counterbalance_file, '.csv']);
countBalMat                    = readtable(counterbalancefile);

%% C. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir,'stimuli','ratingscale');
image_scale_filename           = ['task-',taskname,'_scale.png'];
image_scale                    = fullfile(image_filepath,image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'param_fmriSession', 'param_counterbalanceVer','param_counterbalanceBlockNum',...
                                'param_videoSubject','param_videoFilename','param_cue_type',...
                                'param_administer_type','param_cond_type'...
                                'p1_fixation_onset','p1_fixation_duration',...
                                'p2_cue_onset','p2_cue_type','p2_cue_filename',...
                                'p3_expect_onset','p3_expect_responseonset','p3_expect_RT', ...
                                'p4_fixation_onset','p4_fixation_duration',...
                                'p5_administer_type','p5_administer_filename','p5_administer_onset',...
                                'p6_actual_onset','p6_actual_responseonset','p6_actual_RT', ...
                                'param_end_instruct_onset', 'param_experimentDuration'};
T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
T.Properties.VariableNames     = vnames;
T.p2_cue_type                  = cell(size(countBalMat,1),1);
T.p2_cue_filename              = cell(size(countBalMat,1),1);
T.p5_administer_type           = cell(size(countBalMat,1),1);


a                              = split(counterbalancefile,filesep);
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.param_fmriSession(:)            = session;
T.param_runNum(:)              = run_num;
T.param_counterbalanceVer(:)   = str2double(version_chunk{1});
T.param_counterbalanceBlockNum(:) = str2double(block_chunk{1});
T.param_videoSubject           = countBalMat.video_subject;
T.param_videoFilename          = countBalMat.video_filename;
T.param_cue_type               = countBalMat.cue_type;
T.param_administer_type        = countBalMat.administer;
T.param_cond_type              = countBalMat.cond_type;
T.p2_cue_type                  = countBalMat.cue_type;
T.p2_cue_filename              = countBalMat.cue_image;
T.p5_administer_type           = countBalMat.administer;
T.p5_administer_filename       = countBalMat.video_filename;

%% E. Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('1!');
p.keys.left                    = KbName('2@');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

%% F. fmri Parameters __________________________________________________________
TR                             = 0.46;
task_duration                  = 6.50;
video_length                   = 4.00;
% %% G. Instructions _____________________________________________________________
% instruct_start                 = 'The mental rotation task is about to start. Please wait for the experimenter';
% instruct_end                   = 'This is the end of the experiment. Please wait for the experimenter';
%
%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);



%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________
Screen('TextSize',p.ptb.window,72);
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);
%% _______________________ Wait for Trigger to Begin ___________________________
DisableKeysForKbCheck([]);
KbTriggerWait(p.keys.start);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
T.param_triggerOnset(:) = KbTriggerWait(p.keys.trigger);
WaitSecs(TR*6);

%% 0. Experimental loop _________________________________________________________
for trl = 1:size(countBalMat,1)


%% 1. Fixtion Jitter 0-4 sec ____________________________________________________
jitter1 = countBalMat.ISI1(trl);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
fStart1 = GetSecs;
Screen('Flip', p.ptb.window);
WaitSecs(jitter1);
fEnd1 = GetSecs;

 T.p1_fixation_onset(trl) = fStart1;
 T.p1_fixation_duration(trl) = fEnd1 - fStart1;


%% 2. cue 1s ___________________________________________________________________
if string(countBalMat.cue_type{trl}) == 'low'
  cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
  cueImage = fullfile(cue_low_dir,countBalMat.cue_image{trl});
elseif string(countBalMat.cue_type{trl}) == 'high'
  cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
  cueImage = fullfile(cue_high_dir,countBalMat.cue_image{trl});
end
imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
Screen('DrawTexture', p.ptb.window, imageTexture, [], [], 0);
T.p2_cue_onset(trl) = Screen('Flip',p.ptb.window);
WaitSecs(1)
T.p2_cue_type{trl}                  = countBalMat.cue_type{trl};
T.p2_cue_filename{trl}              = countBalMat.cue_image{trl};



%% 3. expectation rating _______________________________________________________
imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
[trajectory, rating_onset, RT, buttonPressOnset] = circular_rating_output(4,p,cueImage,'expect');
T.p3_expect_onset(trl) = rating_onset;
rating_Trajectory{trl,1} = trajectory;
T.p3_expect_responseonset(trl) = buttonPressOnset;
T.p3_expect_RT(trl) = RT;


%% 4. Fixtion Jitter 0-4 sec ___________________________________________________
jitter2 = countBalMat.ISI2(trl);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
fStart2 = GetSecs;
Screen('Flip', p.ptb.window);
WaitSecs(jitter2);
fEnd2 = GetSecs;
T.p4_fixation_onset(trl) = fStart2;
T.p4_fixation_duration(trl) = fEnd2 - fStart2;

%% 5. vicarious ________________________________________________________________
video_filename = [countBalMat.video_filename{trl}];
video_file = fullfile(dir_video, video_filename);
movie_time = video_play(video_file , p );
T.p5_administer_onset(trl) = movie_time;
WaitSecs(task_duration-video_length);
T.p5_administer_type{trl}           = countBalMat.video_filename{trl};

%% 6. post evaluation rating ___________________________________________________
T.p6_actual_onset(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale,'actual');
rating_Trajectory{trl,2} = trajectory;
T.p6_actual_responseonset(trl) = buttonPressOnset;
T.p6_actual_RT(trl) = RT;

end


%% ______________________________ Instructions _________________________________
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
KbTriggerWait(p.keys.end);

T.param_experimentDuration(:) = T.param_end_instruct_onset(1) - T.param_triggerOnset(1);

%% save parameter ______________________________________________________________
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)), 'beh' );
if ~exist(sub_save_dir, 'dir')
    mkdir(sub_save_dir)
end

saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), ...
'_task-',taskname,'_beh.csv' ]);
writetable(T,saveFileName);

traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)), ...
'_task-',taskname,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');

psychtoolbox_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)),...
'_task-',taskname,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');

sca;

%% -----------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
% Function by Xiaochun Han
function [Tm] = video_play(moviename,p)
% [p.ptb.window, rect]  = Screen(p.ptb.screenID, 'OpenWindow',p.ptb.bg);
Tt = 0;
rate = 1;
[movie, ~, ~, imgw, imgh] = Screen('OpenMovie', p.ptb.window, moviename);
Screen('PlayMovie', movie, rate);
Tm = GetSecs;
t = 0; dur = 0;
while 1
if ((imgw>0) && (imgh>0))
        tex = Screen('GetMovieImage', p.ptb.window, movie, 1);
t = t + tex;
if tex < 0
break;
end

if tex == 0
WaitSecs('YieldSecs', 0.005);
continue;
end
        Screen('DrawTexture', p.ptb.window, tex);
Screen('Flip', p.ptb.window);
Screen('Close', tex);
end
end
        Screen('Flip', p.ptb.window);
Screen('PlayMovie', movie, 0);
Screen('CloseMovie', movie);
end

end
