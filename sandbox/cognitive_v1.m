% start from scratch


%----------------------------------------------------------------------
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
Screen('TextSize', p.ptb.window, 20);

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
taskname = 'cognitive';
counterbalancefile = fullfile(main_dir, 'design', ['task-', taskname, '_counterbalance_ver-01_block-01.csv']);
countBalMat = readtable(counterbalancefile);

%----------------------------------------------------------------------
%                       Load Circular scale
%----------------------------------------------------------------------
% image_filepath = fullfile(main_dir, filesep, 'stimuli');
% image_scale_filename = ['task-', taskname, '_scale.jpg'];
% image_scale = fullfile(image_filepath, filesep, image_scale_filename);

image_filepath = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename = ['task-', taskname, '_scale.jpg'];
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

% 1) get jitter
jitter1 = 4;
% 2) Draw the fixation cross in p.ptb.p.ptb.white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
fStart1 = GetSecs;
WaitSecs(jitter1);
fEnd1 = GetSecs;
% save Parameters
p1_fixationPresent(trl) = fStart1;
p1_jitter(trl) = fEnd1 - fStart1;

%-------------------------------------------------------------------------------
%                                  2. cue 1s
%-------------------------------------------------------------------------------

if string(countBalMat.cue_type{trl}) == 'low'
  cue_low_dir = fullfile(main_dir,'stimuli','cue','scl');
  cueImage = which(fullfile(cue_low_dir,countBalMat.image_filename{trl}));
elseif string(countBalMat.cue_type{trl}) == 'high'
  cue_high_dir = fullfile(main_dir,'stimuli','cue','sch');
  cueImage = which(fullfile(cue_high_dir,countBalMat.image_filename{trl}));

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
rating_Trajectory{trl,1} = trajectory;
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
Screen('Flip', p.ptb.window);
fStart2 = GetSecs;
WaitSecs(jitter2);
fEnd2 = GetSecs;
% save Parameters
p4_fixationPresent(trl) = fStart2;
p4_jitter(trl) = fEnd2 - fStart2;

%-------------------------------------------------------------------------------
%                                  5. cognitive
%-------------------------------------------------------------------------------
% STEPS
% 0) question Same Different
% 1) load image
% 2) response

% OUTPUT
% p5_administer
% 1) log pain start time
respToBeMade = true;

image_filepath = strcat([main_dir '/stimuli/cognitive']);
image_filename = char(countBalMat.image_filename(trl));
image_rotation = strcat([image_filepath filesep image_filename]);

while respToBeMade == true
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
Screen('Flip',p.ptb.window);
p5_administer(trl) = GetSecs;

% key press --------------------------------------------------------------------
[keyIsDown,secs, keyCode] = KbCheck;
if keyCode(p.keys.esc)
    ShowCursor;
    sca;
    return
elseif keyCode(p.keys.left)
    response = 1;
    respToBeMade = false;
    Screen('DrawLines', p.ptb.window, lineCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, [255 0 0]);
    Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);
    Screen('Flip',p.ptb.window);
elseif keyCode(p.keys.right)
    response = 2;
    respToBeMade = false;
    Screen('DrawLines', p.ptb.window, lineCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-250-60, textYc, p.ptb.white);
    DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, [255 0 0]);
    Screen('DrawTexture', p.ptb.window, rotTexture, [], [], 0);
    Screen('Flip',p.ptb.window);
end
end

p5_responseOnset(trl) = secs;
p5_responseKey(trl) = response;
p5_RT(trl) = p5_responseOnset(trl) - p5_administer(trl);
p5_imageAttr = [];
WaitSecs(0.5);

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

p6_ratingPresent(trl) = GetSecs;
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale);
p6_ratingDecideOnset(trl) = buttonPressOnset;
rating_Trajectory{trl,2} = trajectory;
p6_decisionRT(trl) = RT;

end
end

%-------------------------------------------------------------------------------
%                                   save parameter
%-------------------------------------------------------------------------------
% Save onset time
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%02d', sub)), 'beh' );

T = table(p1_fixationPresent,p1_jitter,p2_cue,p3_ratingPresent,...
p3_ratingDecideOnset,p3_decisionRT,p4_fixationPresent,p4_jitter,p5_responseOnset,...
p5_responseKey,p5_RT,p6_ratingPresent,p6_ratingDecideOnset,p6_decisionRT);
saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%02d', sub)), '_task-',taskname,'_beh.csv' ]);
writetable(T,saveFileName)
% save mouse trajectory
trajectory_table = rating_Trajectory;

traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%02d', sub)), '_task-',taskname,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');

% Clear the screen
sca;
