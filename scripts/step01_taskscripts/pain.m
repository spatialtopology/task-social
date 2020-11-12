function pain(sub,input_counterbalance_file, run_num, session, biopac, debug)

% code by Heejung Jung
% heejung.jung@colorado.edu
% Feb.09.2020

%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------


%% 0. Biopac parameters _________________________________________________
task_dir = pwd;
cd('/home/spacetop/repos/labjackpython');
pe = pyenv;
py.importlib.import_module('u3');
% Check to see if u3 was imported correctly
% py.help('u3')
d = py.u3.U3();
% set every channel to 0
d.configIO(pyargs('FIOAnalog', int64(0), 'EIOAnalog', int64(0)));
for FIONUM = 0:7
d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
end


cd(task_dir);

% biopac channel
channel_trigger    = 0;
channel_fixation_1 = 1;
channel_cue        = 2;
channel_expect     = 3;
channel_fixation_2 = 4;
channel_administer = 5;
channel_actual     = 6;


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

%% B. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
taskname                       = 'pain';
bids_string                    = [strcat('spacetop_task-social'),...
    strcat('_ses-',sprintf('%02d', session)),...
    strcat('_sub-', sprintf('%04d', sub)), ...
    '_run-',taskname];
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    'beh' , strcat('ses-',sprintf('%02d', session)));
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub)),...
    'task-social');

if ~exist(sub_save_dir, 'dir');    mkdir(sub_save_dir);     end
if ~exist(repo_save_dir, 'dir');    mkdir(repo_save_dir);   end

% dir_video                      = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                   = fullfile([main_dir,'stimuli','cue','sch']);
counterbalancefile             = fullfile(main_dir, 'design', 's04_final_counterbalance_with_jitter',[input_counterbalance_file, '.csv']);
countBalMat                    = readtable(counterbalancefile);

%% C. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir, 'stimuli', 'ratingscale');
image_scale_filename           = ['task-', taskname, '_scale.png'];
image_scale                    = fullfile(image_filepath, image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id','param_run_num','param_counterbalance_ver',...
    'param_counterbalance_block_num','param_cue_type','param_administer_type',...
    'param_cond_type','param_trigger_onset','param_start_biopac',...
    'event01_fixation_onset','event01_fixation_biopac','event01_fixation_duration',...
    'event02_cue_onset','event02_cue_biopac','event02_cue_type','event02_cue_filename',...
    'event03_expect_onset','event03_rating_biopac','event03_expect_responseonset','event03_expect_RT', ...
    'event04_fixation_onset','event04_fixation_biopac','event04_fixation_duration',...
    'event05_administer_type','event05_administer_onset','event05_stimulus_biopac',...
    'event06_actual_onset','event06_actual_biopac','event06_actual_responseonset','event06_actual_RT',...
    'param_end_instruct_onset','param_end_biopac', 'param_experiment_duration'};
T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
T.Properties.VariableNames     = vnames;
T.event02_cue_type             = cell(size(countBalMat,1),1);
T.event02_cue_filename         = cell(size(countBalMat,1),1);

a                              = split(counterbalancefile,filesep); % full path filename components
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.session_id(:)            = session;
if session == 4
    run_num = run_num-3;
end
T.param_run_num(:)              = run_num;
T.param_counterbalance_ver(:)   = str2double(version_chunk{1});
T.param_counterbalance_block_num(:) = str2double(block_chunk{1});
T.param_cue_type               = countBalMat.cue_type;
T.param_administer_type        = countBalMat.administer;
T.param_cond_type              = countBalMat.cond_type;
T.event02_cue_type             = countBalMat.cue_type;
T.event05_administer_type      = countBalMat.administer;

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
TR                               = 0.46;
task_duration                    = 6.50;
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
HideCursor;
Screen('TextSize',p.ptb.window,72);
start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);
WaitKeyPress(p.keys.start);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);

WaitKeyPress(p.keys.trigger);
% T.param_trigger_onset(:)                = KbTriggerWait(p.keys.trigger, trigger_inputDevice);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_linux_matlab(biopac, channel_trigger, 1);

%% ___________________________ Dummy scans ____________________________
WaitSecs(TR*6);
%% ___________________________ 0. Experimental loop ____________________________
for trl = 1:size(countBalMat,1)
    disp(trl)
    ip = ip_address;
    port = 20121;

    %% _________________________ 1. Fixtion Jitter 0-4 sec _________________________
    jitter1 = countBalMat.ISI1(trl);
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    T.event01_fixation_onset(trl)     = Screen('Flip', p.ptb.window);
    T.event01_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel_fixation_1, 1);
    WaitSecs(jitter1);
    jitter1_end                           = biopac_linux_matlab(biopac, channel_fixation_1, 0);
    T.event01_fixation_duration(trl)      = jitter1_end - T.event01_fixation_onset(trl);

    %% ________________________________ 2. cue 1s __________________________________
    % 1) log cue presentation time
    if string(countBalMat.cue_type{trl}) == 'low'
        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
        cueImage = fullfile(cue_low_dir,countBalMat.cue_image{trl});
    elseif string(countBalMat.cue_type{trl}) == 'high'
        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
        cueImage = fullfile(cue_high_dir,countBalMat.cue_image{trl});
    end
    imageTexture = Screen('MakeTexture', p.ptb.window, imread(cueImage));
    Screen('DrawTexture', p.ptb.window, imageTexture, [], [], 0);
    T.event02_cue_onset(trl)            = Screen('Flip',p.ptb.window);
    T.event02_cue_biopac(trl)             = biopac_linux_matlab(biopac, channel_cue, 1);
    temp = countBalMat.administer(trl) + 49;
    main(ip, port, 1, temp);
    WaitSecs(1.00);
    biopac_linux_matlab(biopac, channel_cue, 0);
    T.event02_cue_type{trl}             = countBalMat.cue_type{trl};
    T.event02_cue_filename{trl}         = countBalMat.cue_image{trl};


    %% __________________________ 3. expectation rating ____________________________
    Screen('MakeTexture', p.ptb.window, imread(cueImage));
    Screen('TextSize', p.ptb.window, 36);
    T.event03_expect_biopac(trl)          = biopac_linux_matlab(biopac, channel_expect, 1);
    [trajectory, rating_onset, RT, buttonPressOnset] = circular_rating_output(4,p,cueImage,'expect');
    biopac_linux_matlab(biopac, channel_expect, 0);
    rating_Trajectory{trl,1} = trajectory;
    T.event03_expect_onset(trl)         = rating_onset;
    T.event03_expect_responseonset(trl) = buttonPressOnset;
    T.event03_expect_RT(trl)            = RT;


    %% _________________________ 4. Fixtion Jitter 0-2 sec _________________________

    jitter2 = countBalMat.ISI2(trl);
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    T.event04_fixation_onset(trl) = Screen('Flip', p.ptb.window);
    T.event04_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel_fixation_2, 1);
    WaitSecs(jitter2);
    end_jitter2                           = biopac_linux_matlab(biopac, channel_fixation_2, 0);
    T.event04_fixation_duration(trl)      = end_jitter2 - T.event04_fixation_onset(trl) ;

    %% ____________________________ 5. pain ___________________________________
    main(ip, port, 4, temp); %start trigger
    %     T.event05_administer_onset(trl) = GetSecs;
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    T.event05_administer_onset(trl) = Screen('Flip', p.ptb.window);
    T.event05_administer_biopac(trl)      = biopac_linux_matlab(biopac, channel_administer, 1);
    WaitSecs(task_duration);
    biopac_linux_matlab(biopac, channel_administer, 0);
    T.event05_administer_type(trl) = countBalMat.administer(trl);

    %% ________________________ 6. post evaluation rating ______________________
    Screen('TextSize', p.ptb.window, 36);
    T.event06_actual_biopac(trl)          = biopac_linux_matlab(biopac, channel_actual, 1);
    [trajectory, rating_onset, RT, buttonPressOnset]  = circular_rating_output(4,p,image_scale,'actual');
    biopac_linux_matlab(biopac, channel_actual, 0);
    rating_Trajectory{trl,2}                 = trajectory;
    T.event06_actual_onset(trl)              = rating_onset;
    T.event06_actual_responseonset(trl)      = buttonPressOnset;
    T.event06_actual_RT(trl)                 = RT;


    %% ________________________ 7. temporarily save file _______________________
    tmpFileName = fullfile(sub_save_dir,[strcat('spacetop_task-social'),...
        strcat('_ses-',sprintf('%02d', session)),...
        strcat('_sub-', sprintf('%04d', sub)), ...
        '_run-',taskname,'_TEMP_beh.csv' ]);
    writetable(T,tmpFileName);

end

%% _________________________ 8. End Instructions _______________________________
end_texture = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
Screen('DrawTexture',p.ptb.window,end_texture,[],[]);
T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                     = biopac_linux_matlab(biopac, channel_trigger, 0);
WaitKeyPress(p.keys.end);
T.param_experiment_duration(:)        = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);


%% _________________________ 9. save parameter _________________________________

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

clear p; clearvars; Screen('Close'); close all; sca;

%-------------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
%     function [t] = triggerThermode_ethernet(temp)
% %         ip = '192.168.0.114';
%         ip = '10.64.1.10';
%         port = 20121;
%         temp = temp + 50;
%         %         main(ip, port, 1, temp);
%         main(ip, port, 4, temp);
%         t = GetSecs;
%         %         main(ip, port, 5, temp);
%     end
%
%     function [t] = TriggerThermodeSocial(temp, varargin)
%         USE_BIOPAC = false;
%
%         for i = 1:length(varargin)
%             switch varargin{i}
%                 case 'USE_BIOPAC'
%                     USE_BIOPAC = varargin{i+1};
%             end
%         end
%
%         ljasm = NET.addAssembly('LJUDDotNet');
%         ljudObj = LabJack.LabJackUD.LJUD;
%
%         [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
%         ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);
%
%         % calculate byte code
%         % Integer values are simply converted to binary, non integer values are
%         % incremented by 128 and converted to binary. So 45 is bin(45) while
%         % 45.5 is bin(45+128).
%         temp = temp + 50;
%         % temp = temp + 100;
%         if(mod(temp,1))
%             % note: this will treat all decimal values the same. Specific
%             % temperature mapping is determined in PATHWAY software
%             temp = floor(temp) + 128;
%         end
%         bytecode=sprintf('%08.0f',str2double(dec2bin(temp)))-'0';
%
%         for i=0:7
%             % Initiate FIO0 to FIO7 output
%             ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, bytecode(i+1), 0, 0);
%
%             if USE_BIOPAC
%                 % Initiate CIO3 and EIO7 output (biopac)
%                 ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);
%             end
%         end
%
%         % Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
%         % Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.
%         ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);
%
%
%
%         for i=0:7
%             % Terminate FIO0 to FIO7 output (reset to 0)
%             ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i, 0, 0, 0);
%
%             if USE_BIOPAC
%                 % Terminate CIO3 and EIO7 output (reset to 0)
%                 % Note: this sends a binary code to biopac channels (likely
%                 % D8-D15).
%                 ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8,0, 0, 0);
%             end
%         end
%
%         t = GetSecs;
%         % Perform the operations/requests
%         ljudObj.GoOne(ljhandle);
%     end
function [time] = biopac_linux_matlab(biopac, channel_num, state_num)
    if biopac
        d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
        time = GetSecs;
    else
        return
    end
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
                % make sure key's released
                while KbCheck(-3); end
            end
        end
    end

end
