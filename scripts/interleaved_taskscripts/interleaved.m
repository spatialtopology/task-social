function interleaved(sub,input_counterbalance_file, run_num, session, biopac, debug)
%% -----------------------------------------------------------------------------
%                                 parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);

if debug
    ListenChar(0);
    PsychDebugWindowConfiguration;
end
screens                        = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber             = max(screens); % Draw to the external screen if avaliable
p.ptb.white                    = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                    = BlackIndex(p.ptb.screenNumber);
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');
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

p.resp.remainder                = 0.5; % time to show response before flipping a new fixation screen

%% B. Biopac parameters ________________________________________________________
% biopac channel
channel = struct;
channel.biopac = biopac;

channel.trigger    = 0;
channel.fixation1  = 1;
channel.cue        = 2;
channel.expect     = 3;
channel.fixation2  = 4;
channel.administer = 5;
channel.actual     = 6;

if channel.biopac == 1
    script_dir = pwd;
    cd('/home/spacetop/repos/labjackpython');
    pe = pyenv;
    try
        py.importlib.import_module('u3');
    catch
        warning("u3 already imported!");
    end
    % Check to see if u3 was imported correctly
    % py.help('u3')
    channel.d = py.u3.U3();
    % set every channel to 0
    channel.d.configIO(pyargs('FIOAnalog', int64(0), 'EIOAnalog', int64(0)));
    for FIONUM = 0:7
        channel.d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
    end
    cd(script_dir);
end


% NOTE TO DO C. load directory ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
bids_string                    = [strcat('spacetop_task-social'),...
    strcat('_ses-',sprintf('%02d', session)),...
    strcat('_sub-', sprintf('%04d', sub)), ...
    '_run-',run_num];
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    strcat('ses-',sprintf('%02d', session)), 'beh' );
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    'task-social');

if ~exist(sub_save_dir, 'dir');    mkdir(sub_save_dir);     end
if ~exist(repo_save_dir, 'dir');    mkdir(repo_save_dir);   end

dir_cognitive                  = fullfile(main_dir, 'stimuli', 'cognitive');
dir_video                      = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                   = fullfile(main_dir,'stimuli','cue','sch');
counterbalancefile             = fullfile(main_dir, 'design_interleaved', 'design_csv',[input_counterbalance_file, '.csv']);
countBalMat                    = readtable(counterbalancefile);


% NOTE TO DO D. circular rating ______________________________________________________________
% NOTE TO DO design matrix (counterbalanced parameters)
% NOTE TO DO D. create table

T.event03_response_key(:) = NaN; T.event03_response_keyname(:)	= 'NA'; T.event03_RT(:) = NaN;
T.RAW_e3_response_onset(:) = NaN;


mr = struct;
task_dur = 8;
plateau = 5;
wait_time = (task_dur - plateau)/2;
mr.key.left = 1;
mr.key.right = 3;

%% E. Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('3#');
p.keys.left                    = KbName('1!');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

[id, name]                     = GetKeyboardIndices;
trigger_index                  = find(contains(name, 'Current Designs'));
trigger_inputDevice            = id(trigger_index);

keyboard_index                 = find(contains(name, 'AT Translated Set 2 Keyboard'));
keyboard_inputDevice           = id(keyboard_index);

%% F. fmri Parameters __________________________________________________________
TR                             = 0.46;
task_duration                  = 6.50;


% H: load pretex
% NOTE [ ] 1) P: fixation_P, fixation during heat delivery
% NOTE [ ] 2) V: fixation_V, video
% NOTE [x] 3) C: vixation_C, mental rotation image

% H. Make Images Into Textures ________________________________________________
%% C. Circular rating scale _____________________________________________________
image_filepath                  = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename            = ['task-', taskname, '_scale.png'];
image_scale                     = fullfile(image_filepath, image_scale_filename);
fix_filename = fullfile();
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
for trl = 1:length(countBalMat.cue_type)
    % cue texture
    if string(countBalMat.cue_type{trl}) == 'low'
        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
        cue_image = fullfile(cue_low_dir,countBalMat.cue_image{trl});
    elseif string(countBalMat.cue_type{trl}) == 'high'
        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
        cue_image = fullfile(cue_high_dir,countBalMat.cue_image{trl});
    end

    % expect image texture
    cue_tex{trl}                          = Screen('MakeTexture', p.ptb.window, imread(cue_image));

    % mental rotation texture
    cog_image_filepath = fullfile(main_dir,'stimuli','cognitive');
    cog_filename = char(countBalMat.image_filename(trl));
    cog_fullfile = fullfile(cog_image_filepath,cog_filename);
    mr.cognitive_tex{trl} = Screen('MakeTexture', p.ptb.window, imread(cog_fullfile));

    % instruction, actual texture
    actual_tex = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    fixTex      = Screen('MakeTexture', p.ptb.window, imread(fix_filename));
    start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    end_tex  = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(countBalMat.cue_type))),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end

% cognitive struct

% 5-2. present scale lines _____________________________________________________
Yc = 180; % Y coord
cDist = 20; % vertical line depth
lXc = -200; % left X coord
rXc = 200; % right X coord
lineCoords = [lXc lXc lXc rXc rXc rXc; Yc-cDist Yc+cDist Yc Yc Yc-cDist Yc+cDist];
% Screen('DrawLines', p.ptb.window, lineCoords,...
% p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);

% 5-3. present same diff text __________________________________________________
mr.textDiff = 'Diff';
mr.textSame = 'Same';
mr.textYc = p.ptb.yCenter + Yc + cDist*4;
mr.textRXc = p.ptb.xCenter + rXc;
mr.textLXc = p.ptb.xCenter - rXc;



%% -----------------------------------------------------------------------------
%                               experiment start
% ------------------------------------------------------------------------------
% """
% jitter > cue > expect rating > jitter > administered stimuli > jitter > actual rating
% One trial is composed of 3 jitters, a social cue, expect rating, actual stimuli, actual rating
% on average, a trial would be 21.5 seconds long
% The whole experiment is expected to be 774 seconds long, i.e. 12 min and 54 seconds long
% """
% fixation (PVC icon) - jitter 2s
% cue 1s
% expect rating - 4s
% jitter 1s

%% _________________________ 1. Fixtion Jitter 0-4 sec _________________________


jitter1 = countBalMat.ISI1(trl);
% Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
%     p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
% if pain load pain pretex
% elif vicarious load vicarious pretex
% elif cognitive load cognitive pretex
T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
T.event01_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel, channel.fixation1, 1);
WaitSecs('UntilTime', T.event01_fixation_onset(trl) + countBalMat.ISI1(trl));
jitter1_end                           = biopac_linux_matlab(biopac, channel, channel.fixation1, 0);
T.event01_fixation_duration(trl)      = jitter1_end - T.event01_fixation_onset(trl);


%% ________________________________ 2. cue 1s __________________________________
if pain; main(ip, port, 1, temp); end;
biopac_linux_matlab(biopac, channel, channel.cue, 0);
Screen('DrawTexture', p.ptb.window, cue_tex{trl}, [], [], 0);
T.event02_cue_onset(trl)              = Screen('Flip',p.ptb.window);
T.event02_cue_biopac(trl)             = biopac_linux_matlab(biopac, channel, channel.cue, 1);
WaitSecs('UntilTime', T.event01_fixation_onset(trl) + countBalMat.ISI1(trl) + 1.00);
biopac_linux_matlab(biopac, channel,  channel.cue, 0);


%% __________________________ 3. expectation rating ____________________________

Screen('TextSize', p.ptb.window, 36);
[trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, cue_tex{trl},'expect', biopac, channel, channel.expect);
biopac_linux_matlab(biopac, channel, channel.expect, 0);
rating_trajectory{trl,1}              = trajectory;
T.event03_expect_displayonset(trl)    = display_onset;
T.event03_expect_RT(trl)              = RT;
T.event03_expect_responseonset(trl)   = response_onset;
T.event03_expect_biopac(trl)          = biopac_display_onset;


%% _________________________ 4. Fixtion Jitter 0-2 sec _____________________

%     jitter2 = countBalMat.array(trl,"ISI2"); % octave
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
T.event04_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
T.event04_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel, channel.fixation2, 1);
% WaitSecs(jitter2);
WaitSecs('UntilTime', T.event04_fixation_onset(trl)  + countBalMat.ISI2(trl));
end_jitter2                           = biopac_linux_matlab(biopac, channel, channel.fixation2, 0);
T.event04_fixation_duration(trl)      = end_jitter2 - T.event04_fixation_onset(trl) ;

%% ______________________________ administer - 8s _______________________________
if pain % ______________________________________________________________
  % trigger
  % NOTE: need a way to select the program ahead of time, but do it 1 trial ahead (not hang for 5 minutes until the next stimuli pops up)
  % when the design matrix is loaded, find all indices of "pain" and identify the n-1 trial
  % if trl == n-1 pain trial
  % OR we could just preload it during the cue period.
  main(ip, port, 4, temp);
  Screen('DrawTexture',p.ptb.window, fixTex);
  T.event05_administer_displayonset(trl) = GetSecs;
  T.event05_administer_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);
  WaitSecs('UntilTime', end_jitter2 + task_dur)
  biopac_linux_matlab(biopac, channel, channel.administer, 0);

elseif cognitive % ______________________________________________________________
  % match plateau

  WaitSecs('UntilTime', end_jitter2 + wait_time); % equivalent to ramp-up time
  mr.initialized = [];
  % 5-1. present rotate image and text ____________________________________________________
  Screen('DrawTexture', p.ptb.window, cognitive_tex{trl}, [], [], 0);
  Screen('TextSize', p.ptb.window, 48);
  DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
  DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
  mr.initialized = Screen('Flip',p.ptb.window);
  % wait for response
  [resp, resp_onset, RT] = cognitive_resp(p, channel, plateau, mr, mr.cognitive_tex{trl});
  T.event05_administer_displayonset(trl) = mr.initialized;
  T.event05_administer_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);
  Screen('DrawTexture',p.ptb.window, fixTex);
  WaitSecs('UntilTime', end_jitter2 + task_dur);
  % record response
  T.event05_administerC_response(trl)       = resp;
  T.event05_administerC_reseponseonset(trl) = resp_onset;
  T.event05_administerC_RT(trl)             = RT;

elseif vicarious % ______________________________________________________________
  video_filename                        = [countBalMat.video_filename{trl}];
  WaitSecs('UntilTime', end_jitter2 + wait_time);
  T.event05_administer_biopac(trl)      = biopac_linux_matlab(biopac, channel, channel.administer, 1);
  video_file                            = fullfile(dir_video, video_filename);
  movie_time                            = video_play(video_file , p , movie{trl}, imgw{trl}*2, imgh{trl}*2);
  biopac_linux_matlab(biopac, channel, channel.administer, 0);
  T.event05_administer_displayonset(trl)       = movie_time;  % 5sec
  Screen('DrawTexture',p.ptb.window, fixTex);
  WaitSecs('UntilTime', end_jitter2 + task_dur);
end


%% ________________________ 6. post evaluation rating __________________________
[trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, actual_tex,'actual', biopac, channel, channel.actual);
biopac_linux_matlab(channel, channel.actual, 0);

rating_trajectory{trl,2}              = trajectory;
T.event06_actual_displayonset(trl)    = display_onset;
T.event06_actual_RT(trl)              = RT;
T.event06_actual_responseonset(trl)   = response_onset;
T.event06_actual_biopac(trl)          = biopac_display_onset;
% end
% clear
%% -----------------------------------------------------------------------------
%                                experiment end
% ------------------------------------------------------------------------------
if channel.biopac;  channel.d.close();  end
clear p; clearvars; Screen('Close'); close all; sca;
%% -----------------------------------------------------------------------------
%                                   function
% ------------------------------------------------------------------------------

function WaitKeyPress(kID)
    while KbCheck(-3); end  % Wait until all keys are released.

    while 1
        % Check the state of the keyboard.
        [ keyIsDown, ~, keyCode ] = KbCheck(-3);
        % If the user is pressing a key, then display its code number and name.
        if keyIsDown

            if keyCode(p.keys.esc)
                cleanup; break;
            elseif keyCode(kID)
                break;
            end
            % make sure key's released
            while KbCheck(-3); end
        end
    end
end

function [time] = biopac_linux_matlab(channel, channel_num, state_num)
  if channel.biopac
      channel.d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
      time = GetSecs;
  else
      time = GetSecs;
      return
  end
end

function [resp, resp_keyname, resp_onset, RT] = cognitive_resp(p, channel, plateau, mr, rt)

  % NOTE input
  % * p: psychtoolbox parameters (will need the ptb.window parameter)
  % * channel: biopac parameters (whether biopac == 1, and if so, which channels to use)
  % * plateau: How long is the response duration for the mental rotation task?
  % * mr: mental rotation parameters (distance between key words, which color changes red when pressed etc)
  % * rt: rotation texture (feed in the preloaded mental rotation image. should be different per trial)

  % NOTE output
  % * resp: 1 = left, 2 = right
  % * resp_keyname: 'left', 'right
  % * resp_onset: The moment the button was pressed (GetMouse does not return timing, therefore, GetSecs immediately after the button is pressed)

  resp = NaN; resp_keyname = 'NaN'; resp_onset = NaN; RT = NaN;
  while GetSecs - mr.initialized < plateau % 5s
      response = 99;

      % 5-5. key press _____________________________________________________________
      [~,~,buttonpressed] = GetMouse;
      resp_onset = GetSecs;
      RT = resp_onset - mr.initialized;
      FlushEvents('keyDown');
      count = 0;
      if buttonpressed(1)% equivalent of elseif keyCode(p.keys.left)
          resp = 1;          resp_keyname = 'left';
          biopac_linux_matlab(channel, channel.administer, 0);
          DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
          DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, [255 0 0]);
          Screen('DrawTexture', p.ptb.window, rt, [], [], 0);
          Screen('Flip',p.ptb.window);
          WaitSecs(p.resp.remainder);

          %remainder_time = task_duration-0.5-RT;
          % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
          %     p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
          % Screen('Flip', p.ptb.window);
          Screen('DrawTexture',p.ptb.window, fixTex);
          biopac_linux_matlab(channel, channel.fixation2, 1);
          WaitSecs('UntilTime', mr.initialized + plateau)
          count = count + 1;

      elseif buttonpressed(3)%     elseif keyCode(p.keys.right)
          resp = 2;          resp_keyname = 'right';
          biopac_linux_matlab(channel, channel.administer, 0);
          DrawFormattedText(p.ptb.window, textDiff, p.ptb.xCenter-120-90, textYc, p.ptb.white);
          DrawFormattedText(p.ptb.window, textSame, p.ptb.xCenter+120, textYc, [255 0 0]);
          Screen('DrawTexture', p.ptb.window, rt, [], [], 0);
          Screen('Flip',p.ptb.window);
          WaitSecs(p.resp.remainder);

          % fill in with fixation cross
          %remainder_time = task_duration-0.5-RT;
          % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
          %     p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
          % Screen('Flip', p.ptb.window);
          Screen('DrawTexture',p.ptb.window, fixTex);
          biopac_linux_matlab(channel,  channel.fixation2, 1);
          WaitSecs('UntilTime', mr.initialized + plateau);
          % count = count +1;
      end
      biopac_linux_matlab(channel, channel.administer, 0);
      biopac_linux_matlab(channel, channel.fixation2, 0);
end
end
end
