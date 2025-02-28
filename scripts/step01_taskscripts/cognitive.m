function cognitive(sub,input_counterbalance_file, run_num, session, biopac, debug)

% code by Heejung Jung
% heejung.jung@colorado.edu
% Jan.21.2021


%% -----------------------------------------------------------------------------
%                                Parameters
% ------------------------------------------------------------------------------
%% B. Biopac parameters ________________________________________________________
% biopac channel
channel = struct;
channel.biopac = biopac;

channel.trigger    = 0;
channel.fixation  = 1;
channel.cue        = 2;
channel.expect     = 3;
%channel.fixation  = 4;
channel.administer = 4;
channel.actual     = 5;


% channel.trigger    = 8;
% channel.fixation  = 9;
% channel.cue        = 10;
% channel.expect     = 11;
% %channel.fixation  = 4;
% channel.administer = 12;
% channel.actual     = 13;

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
    for FIONUM = 0:15
        channel.d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
    end
    cd(script_dir);
end


%% A. Psychtoolsbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);

if debug
    ListenChar(0);
    PsychDebugWindowConfiguration;
end
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

p.resp.remainder                = 0.5; % time to show response before flipping a new fixation screen


%% B. Directories ______________________________________________________________
task_dir                        = pwd;
main_dir                        = fileparts(fileparts(task_dir));
repo_dir                        = fileparts(fileparts(fileparts(task_dir)));
taskname                        = 'cognitive';
% bids_string ___________  example: sub-0001_ses-01_task-social_run-cognitive-01
bids_string                     = [strcat('sub-', sprintf('%04d', sub)), ...
strcat('_ses-',sprintf('%02d', session)),...
strcat('_task-social'),...
strcat('_run-', sprintf('%02d', run_num),'-', taskname)];
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
strcat('ses-',sprintf('%02d', session)),...
    'beh'  );
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    'task-social', strcat('ses-',sprintf('%02d', session)));
if ~exist(sub_save_dir, 'dir');    mkdir(sub_save_dir);     end
if ~exist(repo_save_dir, 'dir');    mkdir(repo_save_dir);   end

counterbalancefile              = fullfile(main_dir, 'design', 's04_counterbalance_with_onset', [input_counterbalance_file, '.csv']);
design_file                     = readtable(counterbalancefile);


%% C. Circular rating scale _____________________________________________________
image_filepath                  = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename            = ['task-', taskname, '_scale.png'];
image_scale                     = fullfile(image_filepath, image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id','param_task_name','param_run_num','param_counterbalance_ver',...
    'param_counterbalance_block_num','param_cue_type','param_stimulus_type',...
    'param_cond_type','param_trigger_onset','param_start_biopac',...
    'ITI_onset','ITI_biopac','ITI_duration',...
    'event01_cue_onset','event01_cue_biopac','event01_cue_type','event01_cue_filename',... % event 01
    'ISI01_onset','ISI01_biopac','ISI01_duration',... % ISI 01
    'event02_expect_displayonset','event02_expect_biopac','event02_expect_responseonset','event02_expect_RT',...
    'event02_expect_angle','event02_expect_angle_label',... % event 02
    'ISI02_onset','ISI02_biopac','ISI02_duration',... % ISI 02
    'event03_stimulus_type','event03_stimulus_displayonset','event03_stimulus_biopac',...
    'event03_stimulus_C_stim_match', ...
    'event03_stimulusC_response','event03_stimulusC_responsekeyname','event03_stimulusC_reseponseonset','event03_stimulusC_RT',...
    'ISI03_onset','ISI03_biopac','ISI03_duration',... % ISI 03
    'event04_actual_displayonset','event04_actual_biopac','event04_actual_responseonset','event04_actual_RT',...
    'event04_actual_angle','event04_actual_angle_label',... % event 04
    'param_end_instruct_onset','param_end_biopac','param_experiment_duration',...
    'event03_stimulus_P_trigger','event03_stimulus_P_delay_between_medoc',...
    'event03_stimulus_V_patientid','event03_stimulus_V_filename',...
    'event03_stimulus_C_stim_num', 'event03_stimulus_C_stim_filename'};


vtypes = { 'double','double','string','double','double','double','string','string',...
'double','double','double',... % param
  'double','double','double',... % ITI
'double','double','string','string',... % event 01
'double','double','double',... % ISI 01
'double','double','double','double','double','string',... % event 02
'double','double','double',... % ISI 02
'string','double','double','string','double','string','double','double', ... % event 03
'double','double','double',... % ISI 03
'double','double','double','double','double','string',... % event 04
'double','double','double',... % param
'string','double','string','string','double','string'};
T = table('Size', [size(design_file,1), size(vnames,2)], 'VariableNames', vnames, 'VariableTypes', vtypes);

a                              = split(counterbalancefile,filesep); % full path filename components
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.src_subject_id(:)            = sub;
T.session_id(:)                = session;
if session == 4;       run_num = run_num-3; end
T.param_run_num(:)             = run_num;
T.param_counterbalance_ver(:)  = str2double(version_chunk{1});
T.param_counterbalance_block_num(:) = str2double(block_chunk{1});
T.param_task_name(:)           = taskname;
T.param_C_stim_num             = design_file.stim_num;
T.event03_C_stim_match           = design_file.same_diff;
T.event03_C_stim_filename        = design_file.image_filename;
T.param_cue_type               = design_file.cue;
T.param_stimulus_type          = design_file.stimulus_intensity;
T.param_cond_type              = design_file.trial_type;
T.event01_cue_type             = design_file.cue;
T.event01_cue_filename         = design_file.cue_image;
T.event03_stimulus_type        = design_file.stimulus_intensity;



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
task_duration                  = 9.00;

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_trigger_name          = ['task-', taskname, '_trigger.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_trigger               = fullfile(instruct_filepath, instruct_trigger_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);
HideCursor;
% H. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
for trl = 1:length(design_file.cue)
    % cue texture
    if string(design_file.cue{trl}) == 'low_cue'
        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
        cue_image = fullfile(cue_low_dir,design_file.cue_image{trl});
    elseif string(design_file.cue{trl}) == 'high_cue'
        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
        cue_image = fullfile(cue_high_dir,design_file.cue_image{trl});
    end

    % expect image texture
    cue_tex{trl}                          = Screen('MakeTexture', p.ptb.window, imread(cue_image));

    % mental rotation texture
    image_filepath = fullfile(main_dir,'stimuli','cognitive');
    image_filename = char(design_file.image_filename(trl));
    image_rotation = fullfile(image_filepath,image_filename);
    rotation_tex{trl} = Screen('MakeTexture', p.ptb.window, imread(image_rotation));

    % instruction, actual texture
    actual_tex = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    trigger_tex     = Screen('MakeTexture',p.ptb.window, imread(instruct_trigger));
    end_tex  = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(design_file.cue))),'center','center',p.ptb.white);
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
mr = struct;
task_dur = 9;
plateau = 5;
wait_time = (task_dur - plateau)/2;
mr.key.left = 1;
mr.key.right = 3;
mr.textDiff = 'Diff';
mr.textSame = 'Same';
mr.textYc = p.ptb.yCenter + Yc + cDist*4;
mr.textRXc = p.ptb.xCenter + rXc;
mr.textLXc = p.ptb.xCenter - rXc;



%% -----------------------------------------------------------------------------
%                              Start Experiment
% ______________________________________________________________________________


%% ______________________________ Instructions _________________________________

Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);
WaitKeyPress(p.keys.start); % press s
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
WaitKeyPress(p.keys.trigger);
% T.param_trigger_onset(:)                = KbTriggerWait(p.keys.trigger, trigger_inputDevice);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_linux_matlab(channel, 0, 1);

%% ___________________________ Dummy scans ____________________________
Screen('DrawTexture',p.ptb.window,trigger_tex,[],[]);
Screen('Flip',p.ptb.window);
WaitSecs(TR*6);
anchor = GetSecs;

%% ________________________ 0. Experimental loop ___________________________________
for trl = 1:size(design_file,1)

    %% ____________________ 1. jitter 01 - ITI 4.5 s _________________________________
    jitter1 = design_file.ISI1(trl);
    T.ITI_onset(trl)         = trial_fixation(p);
    %T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.ITI_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter01 = WaitSecs('UntilTime', anchor + design_file.onset_ITI(trl));
    % WaitSecs('UntilTime', T.ITI_onset(trl) + design_file.ISI1(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ITI_duration(trl)      = end_jitter01 - T.ITI_onset(trl);


    %% ____________________ 2. event 01 - cue 1 s __________________________________

    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, cue_tex{trl}, [], [], 0);
    T.event01_cue_onset(trl)               = Screen('Flip',p.ptb.window);
    T.event01_cue_biopac(trl)              = biopac_linux_matlab(channel, channel.cue, 1);
    end_event01 = WaitSecs('UntilTime', anchor + design_file.onset_ev01(trl));
    %end_event01                            = WaitSecs('UntilTime', T.ITI_onset(trl) + design_file.ISI1(trl) + 1.00);
    biopac_linux_matlab(channel, channel.cue, 0);


    %% ____________________ 3. jitter 02 - ISI1 1.5 sec __________________

    %T.ISI01_onset(trl)         = fixation_cross(p);
    T.ISI01_onset(trl)         = GetSecs;
    T.ISI01_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter02 = WaitSecs('UntilTime', anchor + design_file.onset_ISI1(trl));
    % end_jitter02                           = WaitSecs('UntilTime', end_event01 + design_file.ISI1(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI01_duration(trl)      = end_jitter02 - T.ISI01_onset(trl);


    %% ____________________ 4. event 02 - Expect 4 s _____________________

    Screen('TextSize', p.ptb.window, 36);
    event02_endtime = anchor + design_file.onset_ev02(trl);
    [trajectory, display_onset, RT, response_onset, biopac_display_onset, angle]  = circular_rating_output(4,p,cue_tex{trl},'expect', channel, channel.expect);
    end_event02                           = biopac_linux_matlab(channel, channel.expect, 0);
    rating_Trajectory{trl,1}              = trajectory;
    T.event02_expect_displayonset(trl)    = display_onset;
    T.event02_expect_RT(trl)              = RT;
    T.event02_expect_responseonset(trl)   = response_onset;
    T.event02_expect_biopac(trl)          = biopac_display_onset;
    T.event02_expect_angle(trl)           = angle;
    T.event02_expect_angle_label(trl)     = 'FIX';

    %% ____________________ 5. jitter 03 - ISI2 4.5 sec ____________________

    T.ISI02_onset(trl)        = fixation_cross(p);
    T.ISI02_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter03 = WaitSecs('UntilTime', anchor + design_file.onset_ISI2(trl));
    %end_jitter03                          = WaitSecs('UntilTime', end_event02 + design_file.ISI2(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI02_duration(trl)     = end_jitter03 - T.ISI02_onset(trl);


    %% ____________________ 6. event 03 - stimulus - cognitive _______________________

    % match plateau
    %WaitSecs('UntilTime', end_jitter03 + wait_time); % equivalent to ramp-up time
    WaitSecs('UntilTime',anchor + design_file.onset_ISI2(trl)+  wait_time);
    respToBeMade = true;
    mr.initialized = [];
    % 5-1. present rotate image ____________________________________________________
    Screen('DrawTexture', p.ptb.window, rotation_tex{trl}, [], [], 0);

    % 5-2. present scale lines _____________________________________________________

    % 5-3. present same diff text __________________________________________________
    Screen('TextSize', p.ptb.window, 48);
    DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
    DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen

    % 5-4. flip screen _____________________________________________________________
    mr.initialized = Screen('Flip',p.ptb.window);

    T.event03_stimulus_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);
    % wait for response
    event03_endtime = anchor + design_file.onset_ev03(trl) - wait_time;
    [resp, resp_keyname, resp_onset, RT]  = cognitive_resp(p, channel, plateau, mr, rotation_tex{trl}, event03_endtime);
    T.event03_stimulus_displayonset(trl) = mr.initialized;
    %T.event03_stimulus_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);


    fixation_cross(p);
    %Screen('DrawTexture',p.ptb.window, fixTex);
    end_event03_stimulus = WaitSecs('UntilTime', anchor + design_file.onset_ev03(trl));
    %end_event03_stimulus = WaitSecs('UntilTime', end_jitter03 + task_dur);
    biopac_linux_matlab(channel, channel.administer, 0);
    biopac_linux_matlab(channel, channel.fixation, 0);
    % record response
    T.event03_stimulusC_response(trl)       = resp;
    T.event03_stimulusC_responsekeyname(trl) = resp_keyname;
    T.event03_stimulusC_reseponseonset(trl) = resp_onset;
    T.event03_stimulusC_RT(trl)             = RT;


    %% ___________________ 7. jitter 04 Fixtion Jitter 0-2 sec _________________________

    T.ISI03_onset(trl)        = fixation_cross(p);
    T.ISI03_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter04 = WaitSecs('UntilTime', anchor + design_file.onset_ISI3(trl));
    %end_jitter04                          = WaitSecs('UntilTime', end_event03_stimulus + design_file.ISI3(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI03_duration(trl)     = end_jitter04 - T.ISI03_onset(trl);


    %% ___________________ 8. event 04 post evaluation rating 4 s __________________________
    Screen('TextSize', p.ptb.window, 36);
    %T.event04_actual_biopac(trl)          = biopac_linux_matlab(channel, channel.actual, 1);
    event04_endtime = anchor + design_file.onset_ev04(trl);
    [trajectory, display_onset, RT, response_onset, biopac_display_onset, angle] = circular_rating_output(4, p, actual_tex,'actual', channel, channel.actual);
    biopac_linux_matlab(channel, channel.actual, 0);
    rating_Trajectory{trl,2}              = trajectory;
    T.event04_actual_displayonset(trl)    = display_onset;
        T.event04_actual_RT(trl)          = RT;
    T.event04_actual_responseonset(trl)   = response_onset;
    T.event04_actual_biopac(trl)          = biopac_display_onset;
    T.event04_actual_angle(trl)           = angle;
    T.event04_actual_angle_label(trl)     = 'FIX';


    %% _________________________ 7. temporarily save file _______________________
    tmp_file_name = fullfile(sub_save_dir,strcat(bids_string,'_TEMPbeh.csv' ));
    writetable(T,tmp_file_name);
end


%% -----------------------------------------------------------------------------
%                              End of Experiment
% ------------------------------------------------------------------------------

%% _________________________ A. End Instructions _______________________________

Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:)                = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                        = biopac_linux_matlab(channel, channel.trigger, 0);
WaitKeyPress(p.keys.end);

T.param_experiment_duration(:)               = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);


%% _________________________ B. Save files _____________________________________
% onset + response file
saveFileName = fullfile(sub_save_dir,[bids_string,'_beh.csv' ]);
repoFileName = fullfile(repo_save_dir,[bids_string,'_beh.csv' ]);
writetable(T,saveFileName);
writetable(T,repoFileName);

% trajectory data
traject_saveFileName = fullfile(sub_save_dir, [bids_string,'_beh_trajectory.mat' ]);
traject_repoFileName = fullfile(repo_save_dir, [bids_string,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_Trajectory');
save(traject_repoFileName, 'rating_Trajectory');

% ptb parameters
psychtoolbox_saveFileName = fullfile(sub_save_dir, [bids_string,'_psychtoolbox_params.mat' ]);
psychtoolbox_repoFileName = fullfile(repo_save_dir, [bids_string,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');
save(psychtoolbox_repoFileName, 'p');

%% _________________________ C. Clear parameters _______________________________

if channel.biopac;  channel.d.close();  end
clear p; clearvars; Screen('Close'); close all; sca;
%% -----------------------------------------------------------------------------
%                                Function
% ______________________________________________________________________________
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
                % make sure keys released
                while KbCheck(-3); end
            end
        end
    end

    %function [time] = biopac_linux_matlab(biopac, channel_num, state_num)
    %    if biopac
    %        d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
    %        time = GetSecs;
    %    else
    %        time = GetSecs;
    %        return
    %    end
    %end

    function [time] = fixation_cross(p)
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        time = Screen('Flip', p.ptb.window);
    end

    function [time] = trial_fixation(p)
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            p.fix.lineWidthPix, [0 255 255], [p.ptb.xCenter p.ptb.yCenter], 2);
        time = Screen('Flip', p.ptb.window);
    end

    function [resp, resp_keyname, resp_onset, RT] = cognitive_resp(p, channel, plateau, mr, rt, end_time)

      % NOTE input
      % * p: psychtoolbox parameters (will need the ptb.window parameter)
      % * channel: biopac parameters (whether biopac == 1, and if so, which channels to use)
      % * plateau: How long is the response duration for the mental rotation task?
      % * mr: mental rotation parameters (distance between key words, which color changes red when pressed etc)
      % * rt: rotation texture (feed in the preloaded mental rotation image. should be different per trial)

      % NOTE output
      % * resp: 1 = left, 2 = right
      % * resp_keyname: left, right
      % * resp_onset: The moment the button was pressed (GetMouse does not return timing, therefore, GetSecs immediately after the button is pressed)

      resp = NaN; resp_keyname = 'NaN'; resp_onset = NaN; RT = NaN;
      %biopac_linux_matlab(channel, channel.administer, 1);
      while GetSecs - mr.initialized < plateau % 5s
          response = 99;

          % 5-5. key press _____________________________________________________________
          [~,~,buttonpressed] = GetMouse;


          FlushEvents('keyDown');
          count = 0;
          if buttonpressed(1)% equivalent of elseif keyCode(p.keys.left)
              resp_onset = GetSecs;
              RT = resp_onset - mr.initialized;
              resp = 1;          resp_keyname = 'left';
              biopac_linux_matlab(channel, channel.administer, 0);
              DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
              DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, [255 0 0]);
              Screen('DrawTexture', p.ptb.window, rt, [], [], 0);
              Screen('Flip',p.ptb.window);
              WaitSecs(p.resp.remainder);

              fixation_cross(p);
              biopac_linux_matlab(channel, channel.fixation, 1);
              WaitSecs('UntilTime', end_time)
              count = count + 1;

          elseif buttonpressed(3)%     elseif keyCode(p.keys.right)
              resp_onset = GetSecs;
              RT = resp_onset - mr.initialized;
              resp = 2;          resp_keyname = 'right';
              biopac_linux_matlab(channel, channel.administer, 0);
              DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90,  mr.textYc, p.ptb.white);
              DrawFormattedText(p.ptb.window,  mr.textSame, p.ptb.xCenter+120,  mr.textYc, [255 0 0]);
              Screen('DrawTexture', p.ptb.window, rt, [], [], 0);
              Screen('Flip',p.ptb.window);
              WaitSecs(p.resp.remainder);

              fixation_cross(p);
              biopac_linux_matlab(channel,  channel.fixation, 1);
              WaitSecs('UntilTime',end_time);
              % count = count +1;
          end
          biopac_linux_matlab(channel, channel.administer, 0);
          biopac_linux_matlab(channel, channel.fixation, 0);
    end

end
end
