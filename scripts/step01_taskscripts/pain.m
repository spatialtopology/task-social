function pain(sub,input_counterbalance_file, run_num, session, biopac, debug)

% code by Heejung Jung
% heejung.jung@colorado.edu
% Jan.21.2020

%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------

%% A. Psychtoolbox parameters _________________________________________________
% ip_address = '192.168.0.114'; %ROOM 406 Medoc
ip_address = '10.64.1.10'; % DBIC MRI MEDOC

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
[p.ptb.window, p.ptb.rect]     = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                      = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);
p.fix.sizePix                  = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix             = 4; % Set the line width for our fixation cross
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
p.fix.xCoords                  = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                  = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                = [p.fix.xCoords; p.fix.yCoords];

%% B. Biopac parameters ________________________________________________________
% biopac channel
channel = struct;
channel.biopac = biopac;

channel.trigger    = 0;
channel.fixation  = 1;
channel.cue        = 2;
channel.expect     = 3;
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

%% B. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
taskname                       = 'pain';
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

cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                   = fullfile([main_dir,'stimuli','cue','sch']);
counterbalancefile              = fullfile(main_dir, 'design', 's04_counterbalance_with_onset', [input_counterbalance_file, '.csv']);
design_file                     = readtable(counterbalancefile);
%% C. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename           = ['task-', taskname, '_scale.png'];
image_scale                    = fullfile(image_filepath, image_scale_filename);


%% D. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id','param_task_name','param_run_num','param_counterbalance_ver',...
    'param_counterbalance_block_num','param_cue_type','param_stimulus_type',...
    'param_cond_type','param_trigger_onset','param_start_biopac',...
    'ITI_onset','ITI_biopac','ITI_duration',...
    'event01_cue_onset','event01_cue_biopac','event01_cue_type','event01_cue_filename',...
    'ISI01_onset','ISI01_biopac','ISI01_duration',...
    'event02_expect_displayonset','event02_expect_biopac','event02_expect_responseonset','event02_expect_RT',...
    'ISI02_onset','ISI02_biopac','ISI02_duration',...
    'event03_stimulus_type','event03_stimulus_displayonset','event03_stimulus_biopac',...
    'event03_C_stim_match', ...
    'event03_stimulusC_response','event03_stimulusC_responsekeyname','event03_stimulusC_reseponseonset','event03_stimulusC_RT',...
    'ISI03_onset','ISI03_biopac','ISI03_duration',...
    'event04_actual_displayonset','event04_actual_biopac','event04_actual_responseonset','event04_actual_RT',...
    'param_end_instruct_onset','param_end_biopac','param_experiment_duration'};
    'event03_P_trigger', 'event03_P_delay_between_medoc', 'event03_C_stim_num', 'event03_C_stim_filename',


vtypes = {  'double','double','string','double','double','double','string','string',... % param
'double','double','double',... % param
'double','double','double',... % ITI
'double','double','string','string',... % event 01
'double','double','double',... % ISI 01
'double','double','double','double',... % event 02
'double','double','double',... % ISI 02
'string','double','double',... % event 03
'string',...
'double','string','double','double',... % event 03
'double','double','double',... % ISI 03
'double','double','double','double',... % event 04
'double','double','double'}; % param
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
T.param_cue_type               = design_file.cue;
T.param_stimulus_type          = design_file.stimulus_intensity;
T.param_cond_type              = design_file.trial_type;
T.event01_cue_type                  = design_file.cue;
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
video_length                   = 4.00;
task_dur = 9;
plateau = 5;
wait_time = (task_dur - plateau)/2;
ip = ip_address;
port = 20121;

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);

HideCursor;

%% H. Make Images Into Textures ________________________________________________
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

    cue_tex{trl} = Screen('MakeTexture', p.ptb.window, imread(cue_image));

    % instruction, actual texture ______________________________________________
    actual_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));

    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(design_file.cue))),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);

end

%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________
HideCursor;
Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);
WaitKeyPress(p.keys.start);
fixation_cross(p);
WaitKeyPress(p.keys.trigger);
% T.param_trigger_onset(:)                = KbTriggerWait(p.keys.trigger, trigger_inputDevice);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);
key_set = {'low_stim', 'med_stim', 'high_stim'};
bit8_set = [97, 98, 99];
M = containers.Map(key_set, bit8_set);
%% ___________________________ Dummy scans ____________________________
WaitSecs(TR*6);
anchor = GetSecs;
%% ___________________________ 0. Experimental loop ____________________________
for trl = 1:size(design_file,1)
    %disp(trl)


    %% ____________________ 1. jitter 01 - 0-4 sec _________________________________

    T.ITI_onset(trl)         = fixation_cross(p);
    T.ITI_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    WaitSecs('UntilTime', anchor + design_file.onset_ITI(trl));
    %WaitSecs('UntilTime', T.jitter01_fixation_onset(trl) + design_file.ISI1(trl)); % CHANGE
    end_jitter01                           = biopac_linux_matlab(channel, channel.fixation, 0);
    T.ITI_duration(trl)      = end_jitter01 - T.ITI_onset(trl);


    %% ____________________ 2. event 01 - cue 1 s __________________________________
    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, cue_tex{trl}, [], [], 0);
    T.event01_cue_onset(trl)            = Screen('Flip',p.ptb.window);
    T.event01_cue_biopac(trl)             = biopac_linux_matlab(channel, channel.cue, 1);
    temp = M(string(design_file.stimulus_intensity(trl)));
    main(ip, port, 1, temp);
    %end_event01 = WaitSecs('UntilTime', end_jitter01 + 1.00);
    end_event01 = WaitSecs('UntilTime', anchor + design_file.onset_ev01(trl));
    biopac_linux_matlab(channel, channel.cue, 0);


    %% ____________________ 3. jitter 02 - Fixtion Jitter 0-4 sec __________________

    T.ISI01_onset(trl)         = fixation_cross(p);
    T.ISI01_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter02 = WaitSecs('UntilTime', anchor + design_file.onset_ISI1(trl));
    %end_jitter02                           = WaitSecs('UntilTime', end_event01 + design_file.ISI1(trl)); % CHANGE
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI01_duration(trl)      = end_jitter02 - T.ISI01_onset(trl);


    %% ____________________ 4. event 02 expectation rating 4 s _____________________

    Screen('TextSize', p.ptb.window, 36);
    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, cue_tex{trl},'expect', channel, channel.expect);
    end_event02 = biopac_linux_matlab(channel, channel.expect, 0);
    rating_trajectory{trl,1}              = trajectory;
    T.event02_expect_displayonset(trl)    = display_onset;
    T.event02_expect_RT(trl)              = RT;
    T.event02_expect_responseonset(trl)   = response_onset;
    T.event02_expect_biopac(trl)          = biopac_display_onset;


    %% ____________________ 5. jitter 03 Fixtion Jitter 0-2 sec ____________________

    T.ISI02_onset(trl)        = fixation_cross(p);
    T.ISI02_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter03 = WaitSecs('UntilTime', anchor + design_file.onset_ISI2(trl));
    %end_jitter03                          = WaitSecs('UntilTime', end_event02 + design_file.ISI1(trl)); % CHANGE
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI02_duration(trl)     = end_jitter03 - T.ISI02_onset(trl);


    %% ____________________ 6. event 03 stimulus - pain _______________________

    response = main(ip, port, 4, temp); %start trigger
    T.delay_between_medoc(trl) = GetSecs - end_jitter03 ;
    %     T.event05_administer_displayonset(trl) = GetSecs;
    % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    T.event03_stimulus_displayonset(trl) = GetSecs;
    T.event03_stimulus_biopac(trl)      = biopac_linux_matlab( channel, channel.administer, 1);
    end_event03_stimulus = WaitSecs('UntilTime', anchor + design_file.onset_ev03(trl));
    biopac_linux_matlab( channel, channel.administer, 0);
    T.event03_stimulusP_trigger(trl) = strcat(response{3}, '_',response{6})

    %% ___________________ 7. jitter 04 Fixtion Jitter 0-2 sec _________________________

    T.ISI03_onset(trl)        = fixation_cross(p);
    T.ISI03_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter04 = WaitSecs('UntilTime', anchor + design_file.onset_ISI3(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.ISI03_duration(trl)     = end_jitter04 - T.ISI03_onset(trl);


    %% ___________________ 8. event 04 post evaluation rating 4 s __________________________
    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, actual_tex,'actual', channel, channel.actual);
    biopac_linux_matlab(channel, channel.actual, 0);

    rating_trajectory{trl,2}              = trajectory;
    T.event04_actual_displayonset(trl)    = display_onset;
    T.event04_actual_RT(trl)              = RT;
    T.event04_actual_responseonset(trl)   = response_onset;
    T.event04_actual_biopac(trl)          = biopac_display_onset;


    %% ________________________ 7. temporarily save file _______________________
    tmp_file_name = fullfile(sub_save_dir,strcat(bids_string,'_TEMPbeh.csv' ));
    writetable(T,tmp_file_name);
end

%% -----------------------------------------------------------------------------
%                              End of Experiment
% ------------------------------------------------------------------------------

%% _________________________ A. End Instructions _______________________________

Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                     = biopac_linux_matlab(channel, channel.trigger, 0);

T.param_experiment_duration(:)        = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);
WaitKeyPress(p.keys.end);

%% _________________________ B. Save files _____________________________________

% onset + response file
saveFileName = fullfile(sub_save_dir,[bids_string,'_beh.csv' ]);
repoFileName = fullfile(repo_save_dir,[bids_string,'_beh.csv' ]);
writetable(T,saveFileName);
writetable(T,repoFileName);

% trajectory data
traject_saveFileName = fullfile(sub_save_dir, [bids_string,'_trajectory.mat' ]);
traject_repoFileName = fullfile(repo_save_dir, [bids_string,'_trajectory.mat' ]);
save(traject_saveFileName, 'rating_trajectory');
save(traject_repoFileName, 'rating_trajectory');

% ptb parameters
psychtoolbox_saveFileName = fullfile(sub_save_dir, [bids_string,'_psychtoolboxparams.mat' ]);
psychtoolbox_repoFileName = fullfile(repo_save_dir, [bids_string,'_psychtoolboxparams.mat' ]);
save(psychtoolbox_saveFileName, 'p');
save(psychtoolbox_repoFileName, 'p');

%% _________________________ C. Clear parameters _______________________________

if channel.biopac;  channel.d.close();  end
clear p; clearvars; Screen('Close'); close all; sca;

%-------------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
function [time] = fixation_cross(p)
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    time = Screen('Flip', p.ptb.window);
end

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
                % make sure key is released
                while KbCheck(-3); end
            end
        end
    end

end
