function cognitive(sub,input_counterbalance_file, run_num)

%% -----------------------------------------------------------------------------
%                                Parameters
% ______________________________________________________________________________

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
counterbalancefile              = fullfile(main_dir, 'design', 's04_final_counterbalance_with_jitter', [input_counterbalance_file, '.csv']);
countBalMat                     = readtable(counterbalancefile);

sub_save_dir                    = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)), 'beh' );
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
%% G. Instructions _____________________________________________________________
% instruct_start                 = 'The mental rotation task is about to start. Please wait for the experimenter';
% instruct_end                   = 'This is the end of the experiment. Please wait for the experimenter';

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
%% -----------------------------------------------------------------------------
%                              Start Experiment
% ______________________________________________________________________________
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

%% ___________________________ 0. Experimental loop ____________________________
for trl = 1:size(countBalMat,1)


%% _________________________ 1. Fixtion Jitter 0-4 sec _________________________
jitter1 = countBalMat.ISI1(trl);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
T.p1_fixation_onset(trl) = Screen('Flip', p.ptb.window);
WaitSecs(jitter1);
fEnd1 = GetSecs;
T.p1_fixation_duration(trl) = fEnd1 - T.p1_fixation_onset(trl);

%% ________________________________ 2. cue 1s __________________________________
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


%% __________________________ 3. expectation rating ____________________________
imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
T.p3_expect_onset(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,cueImage,'expect');
rating_Trajectory{trl,1} = trajectory;
T.p3_expect_responseonset(trl) = buttonPressOnset;
T.p3_expect_RT(trl) = RT;


%% _________________________ 4. Fixtion Jitter 0-4 sec _________________________
jitter2 = countBalMat.ISI2(trl);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
T.p4_fixation_onset(trl) = Screen('Flip', p.ptb.window);
WaitSecs(jitter2);
fEnd2 = GetSecs;
T.p4_fixation_duration(trl) = fEnd2- T.p4_fixation_onset(trl);


%% ____________________________ 5. cognitive ___________________________________
respToBeMade = true;
image_filepath = fullfile(main_dir,'stimuli','cognitive');
image_filename = char(countBalMat.image_filename(trl));
image_rotation = fullfile(image_filepath,image_filename);

% while respToBeMade == true
% 5-1. present rotate image ____________________________________________________
rotTexture = Screen('MakeTexture', p.ptb.window, imread(image_rotation));
Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);

% 5-2. present scale lines _____________________________________________________
Yc = 300; % Y coord
cDist = 20; % vertical line depth
lXc = -200; % left X coord
rXc = 200; % right X coord
lineCoords = [lXc lXc lXc rXc rXc rXc; Yc-cDist Yc+cDist Yc Yc Yc-cDist Yc+cDist];
Screen('DrawLines', p.ptb.window, lineCoords,...
p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);

% 5-3. present same diff text __________________________________________________
textDiff = 'Diff';
textSame = 'Same';
textYc = p.ptb.yCenter + Yc + cDist*4;
textRXc = p.ptb.xCenter + rXc;
textLXc = p.ptb.xCenter - rXc;
DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen

% 5-4. flip screen _____________________________________________________________
timing.initialized = Screen('Flip',p.ptb.window);
T.p5_administer_onset(trl) = timing.initialized;
% duration = 4;
while GetSecs - timing.initialized < task_duration
    response = 99;
    % 5-5. key press --------------------------------------------------------------------
%     [keyIsDown,secs, keyCode] = GetMouse;
    [~,~,buttonpressed] = GetMouse;
%     if keyCode(p.keys.esc)
%     ShowCursor;
%     sca;
%     return
%     elseif keyCode(p.keys.left)
    if buttonpressed(1) % equivalent of elseif keyCode(p.keys.left)
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

    remainder_time = task_duration-0.5-RT;
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    WaitSecs(remainder_time);

    elseif buttonpressed(2)%     elseif keyCode(p.keys.right)

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
    remainder_time = task_duration-0.5-RT;
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    Screen('Flip', p.ptb.window);
    WaitSecs(remainder_time);
    end
end

%% ________________________ 6. post evaluation rating __________________________
T.p6_actual_onset(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale,'actual');
rating_Trajectory{trl,2} = trajectory;
T.p6_actual_responseonset(trl) = buttonPressOnset;
T.p6_actual_RT(trl) = RT;
tmpFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_TEMPbeh.csv' ]);
writetable(T,tmpFileName);
end



%% __________________________ save parameter ___________________________________
saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_beh.csv' ]);
writetable(T,saveFileName);

traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');

psychtoolbox_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');

%% ______________________________ Instructions _________________________________
% Screen('TextSize',p.ptb.window,72);
% DrawFormattedText(p.ptb.window,instruct_end,'center',p.ptb.screenYpixels/2+150,255);
% Screen('Flip',p.ptb.window);

start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
% placement
% dspl.cscale.rect = [...
%     [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
%     [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);
KbTriggerWait(p.keys.end);

close all;
sca;

end
