function cognitive(sub,input_counterbalance_file, run_num)

%% A. Psychtoolsbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens                         = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber              = max(screens); % Draw to the external screen if avaliable
p.ptb.white                     = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                     = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]      = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                       = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter]  = RectCenter(p.ptb.rect);
p.fix.sizePix                   = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix              = 4; % Set the line width for our fixation cross
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
p.fix.xCoords                   = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                   = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                 = [p.fix.xCoords; p.fix.yCoords];

%% B. Directories ______________________________________________________________
task_dir                        = pwd;
main_dir                        = fileparts(fileparts(task_dir));
taskname                        = 'cognitive';

dir_video                       = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
cue_low_dir                     = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                    = fullfile([main_dir,'stimuli','cue','sch']);
counterbalancefile              = fullfile(main_dir, 'design', [input_counterbalance_file, '.csv']);
countBalMat                     = readtable(counterbalancefile);

% Save onset time
sub_save_dir                    = fullfile(main_dir, 'data', strcat('sub-', sprintf('%03d', sub)), 'beh' );
if ~exist(sub_save_dir, 'dir')
    mkdir(sub_save_dir)
end


%% C. Circular rating scale _____________________________________________________
image_filepath                  = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename            = ['task-', taskname, '_scale.png'];
image_scale                     = fullfile(image_filepath, image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'param_fmriSession', 'param_counterbalanceVer','param_counterbalanceBlockNum',...
                                'param_videoSubject','param_videoFilename','param_cue_type',...
                                'param_administer_type','param_cond_type'...
                                'p1_fixation_onset','p1_fixation_duration',...
                                'p2_cue_onset','p2_cue_type','p2_cue_filename',...
                                'p3_expect_onset','p3_expect_responseonset','p3_expect_RT', ...
                                'p4_fixation_onset','p4_fixation_duration',...
                                'p5_administer_type','p5_administer_filename','p5_administer_onset',...
                                'p6_actual_onset','p6_actual_responseonset','p6_actual_RT'};
T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
T.Properties.VariableNames     = vnames;

a                              = split(counterbalancefile,filesep); % full path filename components
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.param_runNum(:)              = run_num;
T.param_counterbalanceVer(:)   = str2double(version_chunk{1});
T.param_counterbalanceBlockNum(:) = str2double(block_chunk{1});
T.param_cogStimNum             = countBalMat.stimuli_num;
T.param_cogStimMatch           = countBalMat.match;
T.param_cogStimFilename        = countBalMat.image_filename;
T.param_cue_type               = countBalMat.cue_type;
T.param_administer_type        = countBalMat.administer;
T.param_cond_type              = countBalMat.cond_type;
T.p2_cue_type                  = countBalMat.cue_type;
T.p2_cue_filename              = countBalMat.cue_image;
T.p5_administer_type           = countBalMat.administer;
T.p5_administer_filename       = countBalMat.image_filename;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('j');
p.keys.left                    = KbName('f');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');

%% ------------------------------------------------------------------------------
%                              Start Experiment
%________________________________________________________________________________


%% 0. Experimental loop _________________________________________________________
for trl = 1:size(countBalMat,1)


%% 1. Fixtion Jitter 0-4 sec ____________________________________________________
jitter1 = 4;
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
T.p1_fixation_onset(trl) = Screen('Flip', p.ptb.window);
WaitSecs(jitter1);
fEnd1 = GetSecs;
T.p1_fixation_duration(trl) = fEnd1 - T.p1_fixation_onset(trl);


%% 2. cue 1s ___________________________________________________________________
if string(countBalMat.cue_type{trl}) == 'low'
  cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
  cueImage = fullfile(cue_low_dir,countBalMat.cue_image{trl});
elseif string(countBalMat.cue_type{trl}) == 'high'
  cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
  cueImage = fullfile(cue_high_dir,countBalMat.cue_image{trl});

imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
Screen('DrawTexture', p.ptb.window, imageTexture, [], [], 0);
T.p2_cue_onset(trl) = Screen('Flip',p.ptb.window);
WaitSecs(1)


%% 3. expectation rating _______________________________________________________
imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
T.p3_expect_onset(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,cueImage,'expect');
rating_Trajectory{trl,1} = trajectory;
T.p3_expect_responseonset(trl) = buttonPressOnset;
T.p3_expect_RT(trl) = RT;


%% 4. Fixtion Jitter 0-4 sec ___________________________________________________
jitter2 = 1;
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
T.p4_fixation_onset(trl) = Screen('Flip', p.ptb.window);
WaitSecs(jitter2);
fEnd2 = GetSecs;
T.p4_fixation_duration(trl) = fEnd2- T.p4_fixation_onset(trl);


%% 5. cognitive ________________________________________________________________
respToBeMade = true;
image_filepath = fullfile(main_dir,'stimuli','cognitive');
image_filename = char(countBalMat.image_filename(trl));
image_rotation = fullfile(image_filepath,image_filename);

% while respToBeMade == true
% present rotate image ---------------------------------------------------------
rotTexture = Screen('MakeTexture', p.ptb.window, imread(image_rotation));
Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);
% present scale lines ----------------------------------------------------------
Yc = 300; % Y coord
cDist = 20; % vertical line depth
lXc = -200; % left X coord
rXc = 200; % right X coord
lineCoords = [lXc lXc lXc rXc rXc rXc; Yc-cDist Yc+cDist Yc Yc Yc-cDist Yc+cDist];
Screen('DrawLines', p.ptb.window, lineCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
% present same diff text -------------------------------------------------------
textDiff = 'Diff';
textSame = 'Same';
textYc = p.ptb.yCenter + Yc + cDist*4;
textRXc = p.ptb.xCenter + rXc;
textLXc = p.ptb.xCenter - rXc;
DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen

% flip screen  -----------------------------------------------------------------
timing.initialized = Screen('Flip',p.ptb.window);
T.p5_administer_onset(trl) = timing.initialized;
duration = 4;
while GetSecs < timing.initialized + duration

% key press --------------------------------------------------------------------
[keyIsDown,secs, keyCode] = KbCheck;
if keyCode(p.keys.esc)
ShowCursor;
sca;
return
elseif keyCode(p.keys.left)
RT = GetSecs - timing.initialized;
response = 1;

% respToBeMade = false;
Screen('DrawLines', p.ptb.window, lineCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, [255 0 0]);
Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);
Screen('Flip',p.ptb.window);

WaitSecs(0.5);

remainder_time = duration-0.5-RT;
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
WaitSecs(remainder_time);

elseif keyCode(p.keys.right)

RT = GetSecs - timing.initialized;
response = 2;
% respToBeMade = false;
Screen('DrawLines', p.ptb.window, lineCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, p.ptb.white);
DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, [255 0 0]);
Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);
Screen('Flip',p.ptb.window);
WaitSecs(0.5);
% fill in with fixation cross
remainder_time = duration-0.5-RT;
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
WaitSecs(remainder_time);
end
end
T.p5_administer_responseonset(trl) = secs;
T.p5_administer_responsekey(trl) = response;
T.p5_administer_RT(trl) = secs - timing.initialized;


%% 6. post evaluation rating ___________________________________________________
T.p6_actual_onset(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale,'actual');
rating_Trajectory{trl,2} = trajectory;
T.p6_actual_responseonset(trl) = buttonPressOnset;
T.p6_actual_RT(trl) = RT;
tmpFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%03d', sub)), '_task-',taskname,'_TEMPbeh.csv' ]);
writetable(T,tmpFileName);
end
end

%% save parameter ______________________________________________________________
saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%03d', sub)), '_task-',taskname,'_beh.csv' ]);
writetable(T,saveFileName);

traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%03d', sub)), '_task-',taskname,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');

psychtoolbox_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%03d', sub)), '_task-',taskname,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');

% Clear the screen
close all;
sca;
