% start from scratch


%---------------------------------- ------------------------------------
%                       Window Parameters
%----------------------------------------------------------------------

% Clear the workspace and the screen
% sca;
% close all;
% clearvars;

prompt = 'subject number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);

global p
% debug     = 0;   % PTB Debugging
% 
% AssertOpenGL;
% commandwindow;
% ListenChar(2);
% if debug
%     ListenChar(0);
%     PsychDebugWindowConfiguration;
% end
Screen('Preference', 'SkipSyncTests', 1);
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
main_dir = '/Users/h/Documents/projects_local/social_influence';
% main_dir = '/Users/h/Dropbox/Projects/socialPain';
% main_dir = 'C:\Users\RTNF\Documents\GitHub\social_influence';
cue_low_dir =  strcat([main_dir, '/stimuli/cue/scl']);%'/Users/h/Dropbox/Projects/socialPain/stimuli/cue2/scl';
cue_high_dir =  strcat([main_dir, '/stimuli/cue/sch']);
taskname = 'pain';
counterbalancefile = fullfile(main_dir, 'design', ['task-', taskname, '_counterbalance_ver-01_block-02.csv']);
countBalMat = readtable(counterbalancefile);


%----------------------------------------------------------------------
%                       Load Circular scale
%----------------------------------------------------------------------
image_filepath = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename = ['task-', taskname, '_scale.png'];
image_scale = fullfile(image_filepath, image_scale_filename);


%----------------------------------------------------------------------
%                       Load Jitter Matrix
%----------------------------------------------------------------------





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
fStart1 = GetSecs;
Screen('Flip', p.ptb.window);
WaitSecs(jitter1);
fEnd1 = GetSecs;
% save Parameters
p1_fixationPresent(trl) = fStart1;
p1_jitter(trl) = fEnd1 - fStart1;

%-------------------------------------------------------------------------------
%                            5. pain
%-------------------------------------------------------------------------------
% STEPS
% 0) question Same Different
% 1) load image
% 2) response

% OUTPUT
% p5_administer
% 1) log pain start time
% 1) get jitter
jitter3 = 4;
TEMP = countBalMat.administer(trl);
fStart2 = GetSecs;
Screen('Flip', p.ptb.window);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
% pilot trigger thermode Luke Chang's lab

ip = '192.168.1.3';
newtemp = TEMP+10;
port = 20121;
main(ip, port, 1, newtemp);
% TriggerThermode2(TEMP);
% 2) Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
WaitSecs(jitter3);
fEnd2 = GetSecs;
% save Parameters
p5_fixationPresent(trl) = fStart2;
p5_jitter(trl) = fEnd2 - fStart2;

% jitter - wait after thermode
TEMP = countBalMat.administer(trl);
fStart2 = GetSecs;
Screen('Flip', p.ptb.window);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
   p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
WaitSecs(8);

main(ip, port, 5, newtemp);

% ERASE LATER
% fStart3 = GetSecs;
% the word heat on screen
% textString = ['Heat'];
% DrawFormattedText(window, textString, 'center', 'center', white); % Text output of mouse position draw in the centre of the screen
% Screen('Flip', window);

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
[trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale,'actual');
p6_ratingDecideOnset(trl) = buttonPressOnset;
rating_Trajectory{trl,2} = trajectory;
p6_decisionRT(trl) = RT;




end

%-------------------------------------------------------------------------------
%                                   save parameter
%-------------------------------------------------------------------------------
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

% end
% Clear the screen
sca;


%-------------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------

function TriggerThermode2(temp)
ip = '192.168.1.3';
newtemp = temp+10;
port = 20121;
main(ip, port, 1, newtemp);

% main(ip, port, 4, newtemp);
% t = GetSecs;
% main(ip, port, 5, newtemp);
end
%
%
% function [t] = TriggerThermodeSocial(temp, varargin)
%     USE_BIOPAC = false;
%
%     for i = 1:length(varargin)
%         switch varargin{i}
%             case 'USE_BIOPAC'
%                 USE_BIOPAC = varargin{i+1};
%         end
%     end
%
%     ljasm = NET.addAssembly('LJUDDotNet');
%     ljudObj = LabJack.LabJackUD.LJUD;
%
%     [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
%     ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
%
%     % calculate byte code
%     % Integer values are simply converted to binary, non integer values are
%     % incremented by 128 and converted to binary. So 45 is bin(45) while
%     % 45.5 is bin(45+128).
%     temp = temp + 100;
%     if(mod(temp,1))
%         % note: this will treat all decimal values the same. Specific
%         % temperature mapping is determined in PATHWAY software
%         temp = floor(temp) + 128;
%     end
%     bytecode=sprintf('%08.0f',str2double(dec2bin(temp)))-'0';
%
%     for i=0:7
%         % Initiate FIO0 to FIO7 output
%         ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, bytecode(i+1), 0, 0);
%
%         if USE_BIOPAC
%             % Initiate CIO3 and EIO7 output (biopac)
%             ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);
%         end
%     end
%
%     % Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
%     % Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.
%     ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);
%
%
%
%     for i=0:7
%           % Terminate FIO0 to FIO7 output (reset to 0)
%           ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i, 0, 0, 0);
%
%           if USE_BIOPAC
%               % Terminate CIO3 and EIO7 output (reset to 0)
%               % Note: this sends a binary code to biopac channels (likely
%               % D8-D15).
%               ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8,0, 0, 0);
%           end
%     end
%
%     t = GetSecs;
%     % Perform the operations/requests
%     ljudObj.GoOne(ljhandle);
% end
