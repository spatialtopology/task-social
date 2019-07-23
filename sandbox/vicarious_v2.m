% start from scratch


%---------------------------------- ------------------------------------
%                       Window Parameters
%----------------------------------------------------------------------

% Clear the workspace and the screen
sca;
close all;
clearvars;

global p
% Here we call some default settings  for setting up Psychtoolbox
PsychDefaultSetup(2);

% p = ptbInit;
% Get the screen numbers
screens                       = Screen('Screens');

% Draw to the external screen if avaliable
p.ptb.screenNumber            = max(screens);

% Define black and white
p.ptb.white                   = WhiteIndex(p.ptb.screenNumber);
p.ptb.black                   = BlackIndex(p.ptb.screenNumber);

% Open an on screen window
[p.ptb.window, p.ptb.rect]    = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);

% Get the size of the on screen window
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);

% Query the frame duration
p.ptb.ifi                      = Screen('GetFlipInterval', p.ptb.window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);

% Get the centre coordinate of the window
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);

% Here we set the size of the arms of our fixation cross
p.fix.sizePix                  = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

% Set the line width for our fixation cross
p.fix.lineWidthPix = 4;

%----------------------------------------------------------------------
%                       Load Design Matrix Parameters
%----------------------------------------------------------------------
main_dir = '/Users/h/Dropbox/Projects/socialPain';
dir_video = strcat([main_dir, '/stimuli/36_videos_lanlan/']);
cue_low_dir =  '/Users/h/Dropbox/Projects/socialPain/stimuli/cue/scl';
cue_high_dir = '/Users/h/Dropbox/Projects/socialPain/stimuli/cue/sch';
taskname = 'vicarious';
counterbalancefile = fullfile(main_dir, 'design', ['task-', taskname, '_counterbalance_ver-01_block-01_HML.csv']);
countBalMat = readtable(counterbalancefile);

%----------------------------------------------------------------------
%                       Load Circular scale
%----------------------------------------------------------------------
image_filepath = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename = ['task-', countBalMat.condition_name{1}, '_scale.jpg'];
image_scale = fullfile(image_filepath, image_scale_filename);


%----------------------------------------------------------------------
%                       Load Jitter Matrix
%----------------------------------------------------------------------


sub = 1;

p1_fixationPresent = zeros(size(countBalMat,1),1);
p1_jitter = zeros(size(countBalMat,1),1);
p2_cue = zeros(size(countBalMat,1),1);
p3_ratingPresent = zeros(size(countBalMat,1),1);
p3_ratingDecideOnset  = zeros(size(countBalMat,1),1);
% p3_ratingTrajectory  = cell(size(countBalMat,1),1); % Cell
p3_decisionRT  = zeros(size(countBalMat,1),1);
p4_fixationPresent  = zeros(size(countBalMat,1),1);
p4_jitter  = zeros(size(countBalMat,1),1);
p5_responseOnset  = zeros(size(countBalMat,1),1);
p5_responseKey  = zeros(size(countBalMat,1),1);
p5_RT  = zeros(size(countBalMat,1),1);
p5_imageAttr  = zeros(size(countBalMat,1),1);
p6_ratingPresent = zeros(size(countBalMat,1),1);
p6_ratingDecideOnset = zeros(size(countBalMat,1),1);
% p6_ratingTrajectory = cell(size(countBalMat,1),1); % Cell
p6_decisionRT = zeros(size(countBalMat,1),1);

rating_Trajectory = cell(size(countBalMat,1),2);
%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key

% leftKey = KbName('f');
% rightKey = KbName('j');

KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('j');
p.keys.left                    = KbName('f');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');

%-------------------------------------------------------------------------------
%                            0. Experimental loop
%-------------------------------------------------------------------------------
for trl = 1:size(countBalMat,1)

%-------------------------------------------------------------------------------
%                             1. Fixtion Jitter 0-4 sec
%-------------------------------------------------------------------------------
% #############
% FORLOOPSTART
% ##############
% 1) get jitter
jitter1 = 4;
% 2) Draw the fixation cross in p.ptb.p.ptb.white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
fStart1 = GetSecs;
Screen('Flip', p.ptb.window);
WaitSecs(jitter1);
fEnd1 = GetSecs;
% save Parameters
p1_fixationPresent(trl) = fStart1;
p1_jitter(trl) = fEnd1 - fStart1;

%-------------------------------------------------------------------------------
%                                  2. cue 1s
%-------------------------------------------------------------------------------
% 1) log cue presentation time
cueImage = fullfile(cue_low_dir,countBalMat.cue_image{trl});
% instructTex = Screen('MakeTexture', w.win, imread([defaults.path.stimpractice filesep 'instruction.jpg']));
imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
Screen('DrawTexture', p.ptb.window, imageTexture, [], [], 0);
Screen('Flip',p.ptb.window);
p2_cue(trl) = GetSecs; % save output
WaitSecs(1);
% 10 random social bars

%-------------------------------------------------------------------------------
%                             3. expectation rating
%-------------------------------------------------------------------------------
% OUTPUT:
% p3_ratingPresent
% p3_ratingDecideOnset
% p3_behavioralDecision
% p3_decisionRT

% 1) log rating presentation time
% 2) log rat ing decision time
% 3) log rating decision RT time
% 4) remove onscreen after 4 sec

p3_ratingPresent(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale);

p3_ratingDecideOnset(trl) = buttonPressOnset;
% p3_behavioralDecision(trl) = trajectory;
p3_decisionRT(trl) = RT;

%-------------------------------------------------------------------------------
%                             4. Fixtion Jitter 0-4 sec
%-------------------------------------------------------------------------------

% 1) get jitter
jitter2 = 1;
% 2) Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
fStart2 = GetSecs;
Screen('Flip', p.ptb.window);
WaitSecs(jitter2);
fEnd2 = GetSecs;
% save Parameters
p4_fixationPresent(trl) = fStart2;
p4_jitter(trl) = fEnd2 - fStart2;

%-------------------------------------------------------------------------------
%                                  5. vicarious
%-------------------------------------------------------------------------------
% STEPS
% 0) question Same Different
% 1) load image
% 2) response

% OUTPUT
% p5_administer
% 1) video
video_filename = [countBalMat.video_filename{trl}];
video_file = fullfile(dir_video, video_filename);

% videoFile = strcat([main_dir filesep 'vw121t1aeaff_1-180_.mp4']);
movie_time = video_Xiaochun(video_file , p );
p5_video(trl) = movie_time

%-------------------------------------------------------------------------------
%                                6. post evaluation rating
%-------------------------------------------------------------------------------
% OUTPUT
% p6_ratingPresent
% p6_ratingDecideOnset
% p6_behavioralDecision
% p6_decisionRT
% 1) log rating presentation time
% 2) log rat ing decision time
% 3) log rating decision RT time
% 4) remove onscreen after 4 sec

p6_ratingPresent = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale);

p6_ratingDecideOnset(trl) = buttonPressOnset;
% p6_behavioralDecision(trl) = trajectory;
p6_decisionRT(trl) = RT;

end
%-------------------------------------------------------------------------------
%                                   save parameter
%-------------------------------------------------------------------------------

T = table(p1_fixationPresent , p1_jitter,p2_cue,p3_ratingPresent,p3_ratingDecideOnset,p3_decisionRT,p4_fixationPresent,p4_jitter,...
p5_video,p6_ratingPresent,p6_ratingDecideOnset,p6_decisionRT);

saveDir = main_dir;
saveFileName = fullfile(saveDir, [strcat(sub), '_testparameters_video.csv']);
writetable(T,saveFileName)
% end
% Clear the screen
sca;
