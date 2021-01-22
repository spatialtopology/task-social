
function vicarious(sub,input_counterbalance_file, run_num, session, biopac, debug)

% code by Heejung Jung
% heejung.jung@colorado.edu
% Feb.09.2020
% updated May.17.2020 for octave compatible code
%% -----------------------------------------------------------------------------
%                           Parameters
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

%% B. Directories ______________________________________________________________
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
taskname                       = 'vicarious';
% bids_string
% example: sub-0001_ses-01_task-social_run-cognitive-01
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

dir_video                      = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
cue_high_dir                   = fullfile([main_dir,'stimuli','cue','sch']);
counterbalancefile              = fullfile(main_dir, 'design', 's04_final_counterbalance_with_jitter', [input_counterbalance_file, '.csv']);
design_file                     = readtable(counterbalancefile);
%% C. Circular rating scale _____________________________________________________
image_filepath                 = fullfile(main_dir,'stimuli','ratingscale');
image_scale_filename           = ['task-',taskname,'_scale.png'];
image_scale                    = fullfile(image_filepath,image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id','param_run_num','param_counterbalance_ver',...
    'param_counterbalance_block_num','param_cue_type','param_administer_type','param_stimulus_intensity',...
    'param_cond_name','param_cond_type','param_trigger_onset','param_start_biopac',...
    'jitter01_fixation_onset','jitter01_fixation_biopac','jitter01_fixation_duration',...
    'event01_cue_onset','event01_cue_biopac','event01_cue_type','event01_cue_filename',...
    'jitter02_fixation_onset','jitter02_fixation_biopac','jitter02_fixation_duration',...
    'event02_expect_displayonset','event02_expect_biopac','event02_expect_responseonset','event02_expect_RT',...
    'jitter03_fixation_onset','jitter03_fixation_biopac','jitter03_fixation_duration',...
    'event03_administer_type','event03_administer_displayonset','event03_administer_biopac','event03_administerP_trigger',...
    'event03_adminsiterC_reponse','event03_administerC_responsekeyname','event03_administerC_responseonset','event03_administerC_RT',...
    'jitter04_fixation_onset','jitter04_fixation_biopac','jitter04_fixation_duration',...
    'event04_actual_displayonset','event04_actual_biopac','event04_actual_responseonset','event04_actual_RT',...
    'param_end_instruct_onset','param_end_biopac','param_experiment_duration'};

vtypes = {  'double','double','double','double','double','string','string',... % param
'string','string','double','double','double',... % param
'double','double','double',... % jitter 01
'double','double','string','string',... % event 01
'double','double','double',... % jitter 02
'double','double','double','double',... % event 02
'double','double','double',... % jitter 03
'string','double','double','string','double','string','double','double',... % event 03
'double','double','double',... % jitter 04
'double','double','double','double',... % event 04
'double','double','double'}; % param

T = table('Size', [size(design_file,1), size(vnames,2)], 'VariableNames', vnames, 'VariableTypes', vtypes);

%T.event02_cue_filename         = cell(size(design_file,1),1);
%T.event05_administer_type      = cell(size(design_file,1),1);
a                              = split(counterbalancefile,filesep);
version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
T.src_subject_id(:)            = sub;
T.session_id(:)                = session;
if session == 4;       run_num = run_num-3; end
T.param_run_num(:)             = run_num;
T.param_counterbalance_ver(:)  = str2double(version_chunk{1});
T.param_counterbalance_block_num(:) = str2double(block_chunk{1});
T.param_video_subject          = design_file.video_subject;
T.param_video_filename         = design_file.video_filename;
T.param_cue_type               = design_file.cue_type;
T.param_administer_type        = design_file.administer;
T.param_cond_type              = design_file.cond_type;
T.event02_cue_type             = design_file.cue_type;
T.event02_cue_filename         = design_file.cue_image;
T.event05_administer_type      = design_file.administer;
T.event05_administer_filename  = design_file.video_filename;

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

%% F. fmri Parameters __________________________________________________________
TR                             = 0.46;
task_duration                  = 9.00;
video_length                   = 4.00;
task_dur = 9;
plateau = 5;
wait_time = (task_dur - plateau)/2;
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

for trl = 1:length(design_file.cue_type)
    % cue texture ______________________________________________
    if string(design_file.cue_type{trl}) == 'low'
        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
        cue_image = fullfile(cue_low_dir,design_file.cue_image{trl});
    elseif string(design_file.cue_type{trl}) == 'high'
        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
        cue_image = fullfile(cue_high_dir,design_file.cue_image{trl});
    end

    % expect image texture ______________________________________________
    cue_tex{trl} = Screen('MakeTexture', p.ptb.window, imread(cue_image));

    % vicarious video texture ______________________________________________
    video_filename  = [design_file.video_filename{trl}];
    video_file      = fullfile(dir_video, video_filename);
    [movie{trl}, ~, ~, imgw{trl}, imgh{trl}] = Screen('OpenMovie', p.ptb.window, video_file, [], 1);

    % instruction, actual texture ______________________________________________
    actual_tex      = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    start_tex       = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    end_tex         = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(design_file.cue_type))),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end


%% -----------------------------------------------------------------------------
%                              Start Experiment
% ------------------------------------------------------------------------------

%% ______________________________ Instructions _________________________________

Screen('TextSize',p.ptb.window,72);
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
T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);

%% ___________________________ Dummy scans ____________________________
WaitSecs(TR*6);

%% ___________________________ 0. Experimental loop ____________________________
for trl = 1:size(design_file,1)

  %% ____________________ 1. jitter 01 - 0-4 sec _________________________________
  jitter1 = design_file.ISI1(trl);
  T.jitter01_fixation_onset(trl)         = fixation_cross(p);
  %T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
  T.jitter01_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
  WaitSecs('UntilTime', T.jitter01_fixation_onset(trl) + design_file.ISI1(trl));
  end_jitter01                           = biopac_linux_matlab(channel, channel.fixation, 0);
  T.jitter01_fixation_duration(trl)      = end_jitter01 - T.jitter01_fixation_onset(trl);



  %% ____________________ 2. event 01 - cue 1 s __________________________________

    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, cue_tex{trl}, [], [], 0);
    T.event01_cue_onset(trl)              = Screen('Flip',p.ptb.window);
    T.event01_cue_biopac(trl)             = biopac_linux_matlab(channel, channel.cue, 1);
    end_event01 = WaitSecs('UntilTime', end_jitter01 + 1.00);
    biopac_linux_matlab(channel, channel.cue, 0);

    %% ____________________ 3. jitter 02 - Fixtion Jitter 0-4 sec __________________

    T.jitter02_fixation_onset(trl)         = fixation_cross(p);
    T.jitter02_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter02                           = WaitSecs('UntilTime', end_event01 + design_file.ISI1(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.jitter02_fixation_duration(trl)      = end_jitter02 - T.jitter02_fixation_onset(trl);


    %% ____________________ 4. event 02 expectation rating 4 s _____________________

    Screen('TextSize', p.ptb.window, 36);
    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, cue_tex{trl},'expect',  channel, channel.expect);
    end_event02 = biopac_linux_matlab( channel, channel.expect, 0);
    rating_trajectory{trl,1}              = trajectory;
    T.event02_expect_displayonset(trl)    = display_onset;
    T.event02_expect_RT(trl)              = RT;
    T.event02_expect_responseonset(trl)   = response_onset;
    T.event02_expect_biopac(trl)          = biopac_display_onset;

    %% ____________________ 5. jitter 03 Fixtion Jitter 0-2 sec ____________________

    T.jitter03_fixation_onset(trl)        = fixation_cross(p);
    T.jitter03_fixation_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter03                          = WaitSecs('UntilTime', end_event02 + design_file.ISI1(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.jitter03_fixation_duration(trl)     = end_jitter03 - T.jitter03_fixation_onset(trl);


    %% ____________________ 6. event 03 stimulus - vicarious _______________________

    WaitSecs('UntilTime', end_jitter03 + wait_time);
    video_filename                        = [design_file.video_filename{trl}];
    T.event03_administer_biopac(trl)      = biopac_linux_matlab( channel, channel.administer, 1);
    video_file                            = fullfile(dir_video, video_filename);
    movie_time                            = video_play(video_file , p , movie{trl}, imgw{trl}*2, imgh{trl}*2);
    biopac_linux_matlab( channel, channel.administer, 0);
    T.event03_administer_displayonset(trl)       = movie_time;  % 4sec
    end_event03_stimulus = WaitSecs('UntilTime', end_jitter03 + task_dur);

    %% ___________________ 7. jitter 04 Fixtion Jitter 0-2 sec _________________________

    T.jitter04_fixation_onset(trl)        = fixation_cross(p);
    T.jitter04_fixation_biopac(trl)       = biopac_linux_matlab(channel, channel.fixation, 1);
    end_jitter04                          = WaitSecs('UntilTime', end_event03_stimulus + design_file.ISI1(trl));
    biopac_linux_matlab(channel, channel.fixation, 0);
    T.jitter04_fixation_duration(trl)     = end_jitter04 - T.jitter04_fixation_onset(trl);


    %% ___________________ 8. event 04 post evaluation rating 4 s __________________________

    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, actual_tex,'actual', channel, channel.actual);
    biopac_linux_matlab( channel, channel.actual, 0);

    rating_trajectory{trl,2}              = trajectory;
    T.event06_actual_displayonset(trl)    = display_onset;
    T.event06_actual_RT(trl)              = RT;
    T.event06_actual_responseonset(trl)   = response_onset;
    T.event06_actual_biopac(trl)          = biopac_display_onset;

    %% ________________________ 7. temporarily save file _______________________
    tmp_file_name = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), ...
    strcat('_ses-', sprintf('%02d',session)), '_task-',taskname,'_TEMPbeh.csv' ]);
    writetable(T,tmp_file_name);
    % Screen('Close', cue_tex{trl});
end


%% _________________________ 8. End Instructions _______________________________
% end_texture                               = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:)             = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                     = biopac_linux_matlab( channel, channel.trigger, 0);
T.param_experiment_duration(:)            = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);
WaitKeyPress(p.keys.end);

%% _________________________ 9. save parameter _________________________________
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

if channel.biopac;  channel.d.close();  end
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
                else keyCode(kID)
                    break;
                end
                % make sure key's released
                while KbCheck(-3); end
            end
        end
    end

end
