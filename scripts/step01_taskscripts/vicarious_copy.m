
function vicarious(sub,input_counterbalance_file, run_num, session, biopac, debug)

% code by Heejung Jung
% heejung.jung@colorado.edu
% Feb.09.2020
% updated May.17.2020 for octave compatible code
%% -----------------------------------------------------------------------------
%                           Parameters
% ------------------------------------------------------------------------------


%% 0. Biopac parameters _________________________________________________
script_dir = pwd;
% biopac channel
channel_trigger    = 0;
channel_fixation_1 = 1;
channel_cue        = 2;
channel_expect     = 3;
channel_fixation_2 = 4;
channel_administer = 5;
channel_actual     = 6;

if biopac == 1


    pe = pyenv;
    if pe.Status ~= "Loaded"
        script_dir = pwd;
        cd('/home/spacetop/repos/labjackpython');
        py.importlib.import_module('u3');
        d = py.u3.U3();
        fprintf("u3 loaded");
        endccc
    % Check to see if u3 was imported correctly
    % py.help('u3')
    % d = py.u3;
    % set every channel to 0
    d.configIO(pyargs('FIOAnalog', int64(0), 'EIOAnalog', int64(0)));
    for FIONUM = 0:7
        d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
    end
    cd(script_dir);
    end
%
% if (py_env.Status == 'Loaded')~= 1
% pe = pyenv('ExecutionMode', 'InProcess');
% end
% task_dir = pwd;
% cd('/home/spacetop/repos/labjackpython');
%
%
% % py.importlib.import_module('u3');
% % Check to see if u3 was imported correctly
% % py.help('u3')
% reloadPy();
% d = py.u3.U3();
% % set every channel to 0
% for FIO = 0:7
% d.setFIOState(pyargs('fioNum', int64(FIO), 'state', int64(0)));
% end
%
%
% cd(task_dir);
%
% % biopac channel
% channel_trigger    = 0;
% channel_fixation_1 = 1;
% channel_cue        = 2;
% channel_expect     = 3;
% channel_fixation_2 = 4;
% channel_administer = 5;
% channel_actual     = 6;


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
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
taskname                       = 'vicarious';
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
vnames = {'src_subject_id', 'session_id', 'param_run_num','param_counterbalance_ver',...
    'param_counterbalance_block_num','param_cue_type','param_administer_type',...
    'param_video_subject','param_video_filename',...
    'param_cond_type','param_trigger_onset','param_start_biopac'...
    'event01_fixation_onset','event01_fixation_biopac','event01_fixation_duration',...
    'event02_cue_onset','event02_cue_biopac','event02_cue_type','event02_cue_filename',...
    'event03_expect_displayonset','event03_expect_biopac','event03_expect_responseonset','event03_expect_RT', ...
    'event04_fixation_onset','event04_fixation_biopac','event04_fixation_duration',...
    'event05_administer_type','event05_administer_filename','event05_administer_onset','event05_administer_biopac',...
    'event06_actual_displayonset','event06_actual_biopac','event06_actual_responseonset','event06_actual_RT', ...
    'param_end_instruct_onset','param_end_biopac','param_experiment_duration'};
T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
% T = dataframe(zeros(size(countBalMat,1),size(vnames,2)),"colnames",
% vnames); %octave
T.Properties.VariableNames     = vnames;

T.event02_cue_filename         = cell(size(countBalMat,1),1);
T.event05_administer_type      = cell(size(countBalMat,1),1);
a                              = split(counterbalancefile,filesep);
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.src_subject_id(:)            = sub;
T.session_id(:)                = session;
if session == 4;       run_num = run_num-3; end
T.param_run_num(:)             = run_num;
T.param_counterbalance_ver(:)  = str2double(version_chunk{1});
T.param_counterbalance_block_num(:) = str2double(block_chunk{1});
T.param_video_subject          = countBalMat.video_subject;
T.param_video_filename         = countBalMat.video_filename;
T.param_cue_type               = countBalMat.cue_type;
T.param_administer_type        = countBalMat.administer;
T.param_cond_type              = countBalMat.cond_type;
T.event02_cue_type             = countBalMat.cue_type;
T.event02_cue_filename         = countBalMat.cue_image;
T.event05_administer_type      = countBalMat.administer;
T.event05_administer_filename  = countBalMat.video_filename;

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
video_length                   = 4.00;

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
instruct_start_name            = ['task-', taskname, '_start.png'];
instruct_end_name              = ['task-', taskname, '_end.png'];
instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);

HideCursor;
% H. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
%slideName = cell(length(design.qim),1); % is the person...
%slideTex = slideName;
%for i = 1:length(design.qim)
%    slideName{i} = design.qim{i,2}; % jpg
%    tmp1 = imread([defaults.path.stim filesep slideName{i}]);
%    tmp2 = tmp1;
%    slideTex{i} = Screen('MakeTexture',w.win,tmp2);



for trl = 1:length(countBalMat.cue_type)
  if string(countBalMat.cue_type{trl}) == 'low'
      cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
      cue_image = fullfile(cue_low_dir,countBalMat.cue_image{trl});
  elseif string(countBalMat.cue_type{trl}) == 'high'
      cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
      cue_image = fullfile(cue_high_dir,countBalMat.cue_image{trl});
  end

  expect_tex{trl}                          = Screen('MakeTexture', p.ptb.window, imread(cue_image));
  video_filename                        = [countBalMat.video_filename{trl}];
  video_file                            = fullfile(dir_video, video_filename);
  % movie_time                            = video_play(video_file , p );
  [movie{trl}, ~, ~, imgw{trl}, imgh{trl}] = Screen('OpenMovie', p.ptb.window, video_file);

DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(countBalMat.cue_type))),'center','center',p.ptb.white);
Screen('Flip',p.ptb.window);

end



actual_tex = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
end_tex                               = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
%instructTex = Screen('MakeTexture', w.win, imread([defaults.path.stim filesep 'instruction.jpg']));
%fixTex      = Screen('MakeTexture', w.win, imread([defaults.path.stim filesep 'fixation.jpg']));
%line1       = strcat('Is the person', repmat('\n', 1, defaults.font.linesep));
Screen('TextSize', p.ptb.window, 36);

%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________

%Screen('TextSize',p.ptb.window,72);
%DEL% start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);

%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
WaitKeyPress(p.keys.start);
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
WaitKeyPress(p.keys.trigger);
% T.param_trigger_onset(:)                = KbTriggerWait(p.keys.trigger, trigger_inputDevice);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_linux_matlab(biopac, channel_trigger, 1);

%% ___________________________ Dummy scans ____________________________
% WaitSecs(TR*6);

%% 0. Experimental loop ________________________________________________________
for trl = 1:2%size(countBalMat,1)

    %% _________________________ 1. Fixtion Jitter 0-4 sec _____________________
     jitter1 = countBalMat.ISI1(trl);
%     %     jitter1 = countBalMat.array(trl, "ISI1"); % OCTAVE
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
   T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
   T.event01_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel_fixation_1, 1);
   WaitSecs(jitter1);
   jitter1_end                           = biopac_linux_matlab(biopac, channel_fixation_1, 0);
   T.event01_fixation_duration(trl)      = jitter1_end - T.event01_fixation_onset(trl);

    %% ________________________________ 2. cue 1s ______________________________
%    if string(countBalMat.cue_type{trl}) == 'low'
%        %     if strcmp(countBalMat.array(trl, "cue_type") , "low") % OCTAVE
%        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
%        cue_image = fullfile(cue_low_dir,countBalMat.cue_image{trl});%
%    elseif string(countBalMat.cue_type{trl}) == 'high'
%        %     else strcmp(countBalMat.array(trl, "cue_type"), "high") % OCTAVE
%        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
%        cue_image = fullfile(cue_high_dir,countBalMat.cue_image{trl});
%        % endif % OCTAVE
%    end

%    imageTexture                          = Screen('MakeTexture', p.ptb.window, imread(cue_image));
    Screen('DrawTexture', p.ptb.window, expect_tex{trl}, [], [], 0);
    T.event02_cue_onset(trl)              = Screen('Flip',p.ptb.window);
    T.event02_cue_biopac(trl)             = biopac_linux_matlab(biopac, channel_cue, 1);
    WaitSecs(1.00);
    biopac_linux_matlab(biopac, channel_cue, 0);
    T.event02_cue_type{trl}               = countBalMat.cue_type{trl};
    T.event02_cue_filename{trl}           = countBalMat.cue_image{trl};

    %% __________________________ 3. expectation rating ________________________
    % Screen('MakeTexture', p.ptb.window, imread(cue_image));
    %

    T.event03_expect_biopac(trl)          = biopac_linux_matlab(biopac, channel_expect, 1);
    [trajectory, rating_onset, RT, buttonPressOnset] = circular_rating_output(4,p,expect_tex{trl},'expect');
    biopac_linux_matlab(biopac, channel_expect, 0);
    rating_Trajectory{trl,1}              = trajectory;
    T.event03_expect_displayonset(trl)           = rating_onset;
    T.event03_expect_responseonset(trl)   = buttonPressOnset;
    T.event03_expect_RT(trl)              = RT;


    %% _________________________ 4. Fixtion Jitter 0-2 sec _____________________
    jitter2                               = countBalMat.ISI2(trl);
    %     jitter2 = countBalMat.array(trl,"ISI2"); % octave
    Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    T.event04_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.event04_fixation_biopac(trl)        = biopac_linux_matlab(biopac, channel_fixation_2, 1);
    WaitSecs(jitter2);
    end_jitter2                           = biopac_linux_matlab(biopac, channel_fixation_2, 0);
    T.event04_fixation_duration(trl)      = end_jitter2 - T.event04_fixation_onset(trl) ;

    %% ____________________________ 5. vicarious _______________________________
    video_filename                        = [countBalMat.video_filename{trl}];
    %     video_filename = [countBalMat.array(trl, "video_filename")]; % OCTAVE

    WaitSecs((task_duration-video_length)/2);
    T.event05_administer_biopac(trl)      = biopac_linux_matlab(biopac, channel_administer, 1);
    video_file                            = fullfile(dir_video, video_filename);
    movie_time                            = video_play(video_file , p,movie{trl}, imgw{trl}, imgh{trl});
    T.event05_administer_onset(trl)       = movie_time;  % 4sec
    biopac_linux_matlab(biopac, channel_administer, 0);
    WaitSecs((task_duration-video_length)/2);
    T.event05_administer_type{trl}        = countBalMat.video_filename{trl};

    %% ________________________ 6. post evaluation rating ______________________
    %Screen('TextSize', p.ptb.window, 36);
    T.event06_actual_biopac(trl)          = biopac_linux_matlab(biopac, channel_actual, 1);
    [trajectory, rating_onset, RT, buttonPressOnset] = circular_rating_output(4,p,actual_tex,'actual');
    biopac_linux_matlab(biopac, channel_actual, 0);
    rating_Trajectory{trl,2}              = trajectory;
    T.event06_actual_displayonset(trl)           = rating_onset;
    T.event06_actual_responseonset(trl)   = buttonPressOnset;
    T.event06_actual_RT(trl)              = RT;

    %% ________________________ 7. temporarily save file _______________________
    tmp_file_name = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_TEMPbeh.csv' ]);
    writetable(T,tmp_file_name);
%    Screen('Close');
end


%% _________________________ 8. End Instructions _______________________________

Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:)             = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                     = biopac_linux_matlab(biopac, channel_trigger, 0);
WaitKeyPress(p.keys.end);
T.param_experiment_duration(:) = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);


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
%% -----------------------------------------------------------------------------
%                                   Function
%-------------------------------------------------------------------------------
% Function by Xiaochun Han
function [Tm] = video_play(moviename,p, movie, imgw, imgh)
%     function [Tm] = video_play(moviename,p, movie, imgw, imgh)
        % [p.ptb.window, rect]  = Screen(p.ptb.screenID, 'OpenWindow',p.ptb.bg);
        % Tt = 0;
        rate = 1;
        %[movie, ~, ~, imgw, imgh] = Screen('OpenMovie', p.ptb.window, moviename);
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


    function [time] = biopac_linux_matlab(biopac, channel_num, state_num)
        if biopac
            d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
            time = GetSecs;
        else
            time = GetSecs;
            return
        end
    end
    function reloadPy()
        warning('off', 'MATLAB:ClassInstanceExists')
        clear classes
        mod = py.importlib.import_module('u3');
        py.importlib.reload(mod);

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
                else keyCode(kID)
                    break;
                end
                % make sure key's released
                while KbCheck(-3); end
            end
        end
    end

end
