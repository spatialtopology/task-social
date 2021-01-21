
function interleaved(sub,input_counterbalance_file, run_num, session, biopac, debug)
sub=98;
input_counterbalance_file = 'design_csv';
run_num = 2;
session = 1;
biopac = 1;
debug = 1;
%% -----------------------------------------------------------------------------
%                                 parameters
% ------------------------------------------------------------------------------
e
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
    '_run-',sprintf('%02d', run_num)];
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
counterbalancefile             = fullfile(main_dir, 'design_interleaved', 'design_csv',strcat(input_counterbalance_file, '.csv'));
design_file                    = readtable(counterbalancefile);


% NOTE TO DO D. circular rating ______________________________________________________________
% NOTE TO DO design matrix (counterbalanced parameters)
% NOTE TO DO D. create table

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

%% parameters that can be filled in the table
T.src_subject_id(:) = sub;
T.session_id(:) = session;
T.param_run_num(:) = run_num;
T.param_counterbalance_ver(:) = 99;
T.param_counterbalance_block_num(:) = 99;
T.param_cue_type(:) = design_file.cue_type;
T.param_administer_type(:) = design_file.administer;
T.param_stimulus_intensity(:) = design_file.stimulus_intensity;
T.param_cond_type(:) = design_file.cond_type;
T.param_cond_name(:) = design_file.condition_name;
T.event02_cue_type(:) = design_file.cue_type;
T.event02_cue_filename(:) = design_file.cue_image;
T.event05_administer_type(:) = design_file.administer;
T.event05_administerC_response(:) = NaN;
T.event05_administerC_responsekeyname(:) = string('NA');
T.event05_administerC_reseponseonset(:) = NaN;
T.event05_administerC_RT(:) = NaN;

% condition_name	administer	stimulus_intensity	cue_type	cue_image	random_order	cond_type	condition_num_filled_in_during_exper	block_num	cB_version
% ISI1	ISI2	image_filename	stimuli_num	match	video_subject	image_glob	video_filename

%% task design Parameters
task_dur = 9;
plateau = 5;

%% mental rotation parameters _____________________________________________________

mr = struct;

wait_time = (task_dur - plateau)/2;
mr.key.left = 1;
mr.key.right = 3;
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
% TSA parameters
ip = '10.64.1.10'; port = 20121;
% ip = '192.168.0.114'; port = 20121;

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


%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
% taskname = 'pain';
instruct_start_name            = 'PVC_start.png';
instruct_end_name              = 'PVC_end.png';

instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
instruct_end                   = fullfile(instruct_filepath, instruct_end_name);

% H: load pretex
% NOTE [ ] 1) P: fixation_P, fixation during heat delivery
% NOTE [ ] 2) V: fixation_V, video
% NOTE [x] 3) C: vixation_C, mental rotation image
% NOTE [ ] not just
% H. Make Images Into Textures ________________________________________________
%% C. Circular rating scale _____________________________________________________

%fix_filename = fullfile();
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
Screen('Flip',p.ptb.window);
for trl = 1:length(design_file.cue_type)
    % cue texture
    taskname = 'pain';
    if string(design_file.cue_type{trl}) == 'low'
        cue_low_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname], 'scl');
        cue_image = fullfile(cue_low_dir,design_file.cue_image{trl});
    elseif string(design_file.cue_type{trl}) == 'high'
        cue_high_dir = fullfile(main_dir,'stimuli','cue',['task-',taskname],'sch');
        cue_image = fullfile(cue_high_dir,design_file.cue_image{trl});
    end

    % expect image texture
    cue_tex{trl}                          = Screen('MakeTexture', p.ptb.window, imread(cue_image));

    % mental rotation texture


    % instruction, actual texturetask_name

    %fixTex      = Screen('MakeTexture', p.ptb.window, imread(fix_filename));
    start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    end_tex   = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*trl/length(design_file.cue_type))),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end

% cognitive struct






%% -----------------------------------------------------------------------------
%                               experiment start
% ------------------------------------------------------------------------------
%
% jitter > cue > expect rating > jitter > administered stimuli > jitter > actual rating
% One trial is composed of 3 jitters, a social cue, expect rating, actual stimuli, actual rating
% on average, a trial would be 21.5 seconds long
% The whole experiment is expected to be 774 seconds long, i.e. 12 min and 54 seconds long
%
% fixation (PVC icon) - jitter 2s
% cue 1s
% expect rating - 4s
% jitter 1s

%% ______________________________ Instructions _________________________________
HideCursor;
Screen('TextSize',p.ptb.window,72);
%DEL% start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
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
T.param_start_biopac(:)                   = biopac_linux_matlab(channel, channel.trigger, 1);
%% ___________________________ Dummy scans ____________________________
WaitSecs(TR*6);

for trl = 1:size(T,1)
    task_name = '';
    task_name = string(design_file.condition_name{trl});

    %% _________________________ 1. Fixtion Jitter 0-4 sec _________________________

    jitter1 = design_file.ISI1(trl);
    % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    %     p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);

    fixation_filename = fullfile(main_dir, 'stimuli', 'slides_adobe', strcat('fixation_ver-01_', task_name, '.png'));
    %'/home/spacetop/repos/social_influence/stimuli/slides_adobe/fixation_ver-01_cognitive.png'

    fixOnset      = Screen('MakeTexture', p.ptb.window, imread(fixation_filename));
    Screen('DrawTexture',p.ptb.window,fixOnset,[],[])

    T.event01_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.event01_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation1, 1);
    WaitSecs('UntilTime', T.event01_fixation_onset(trl) + design_file.ISI1(trl));
    jitter01_end                           = biopac_linux_matlab(channel, channel.fixation1, 0);
    T.event01_fixation_duration(trl)      = jitter01_end - T.event01_fixation_onset(trl);


    %% ___________________________ 2. event 01 cue 1s __________________________
    if string(design_file.condition_name{trl}) == 'pain';
        temp = str2num(string(design_file.administer{trl})) + 49;
        main(ip, port, 1, temp);
    end
    biopac_linux_matlab(channel, channel.cue, 0);
    Screen('DrawTexture', p.ptb.window, cue_tex{trl}, [], [], 0);
    T.event01_cue_onset(trl)              = Screen('Flip',p.ptb.window);
    T.event01_cue_biopac(trl)             = biopac_linux_matlab(channel, channel.cue, 1);

    WaitSecs('UntilTime', T.event01_fixation_onset(trl) + design_file.ISI1(trl) + 1.00);
    end_event01 = biopac_linux_matlab(channel,  channel.cue, 0);


    %% _________________________ 3. Fixtion Jitter 0-2 sec _____________________

    % jitter2 = design_file.ISI2(trl);
    %Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
    fixation_cross(p);
    T.jitter02_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.jitter02_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation2, 1);
    % WaitSecs(jitter2);
    WaitSecs('UntilTime', T.jitter02_fixation_onset(trl)  + design_file.ISI2(trl));
    end_jitter02                           = biopac_linux_matlab(channel, channel.fixation2, 0);
    T.jitter02_fixation_duration(trl)      = end_jitter02 - T.jitter02_fixation_onset(trl) ;

    %% ______________________ 4. event 02 expectation rating ____________________________
    % [ ] different rating loaded depending on condition
    Screen('TextSize', p.ptb.window, 36);
    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, cue_tex{trl},'expect', channel, channel.expect);
    biopac_linux_matlab(channel, channel.expect, 0);
    rating_trajectory{trl,1}              = trajectory;
    T.event02_expect_displayonset(trl)    = display_onset;
    T.event02_expect_RT(trl)              = RT;
    T.event02_expect_responseonset(trl)   = response_onset;
    T.event02_expect_biopac(trl)          = biopac_display_onset;


    %% _________________________ 5. Fixtion Jitter 0-2 sec _____________________

    fixation_cross(p);
    T.jitter03_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.jitter03_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation2, 1);

    WaitSecs('UntilTime', T.jitter03_fixation_onset(trl)  + design_file.ISI2(trl));
    end_jitter03                           = biopac_linux_matlab(channel, channel.fixation2, 0);
    T.jitter03_fixation_duration(trl)      = end_jitter03 - T.jitter03_fixation_onset(trl) ;


    %% _________________________ 6. event 03 administer - 9 s __________________________
    administer = string(design_file.condition_name{trl});
    switch administer
        case 'pain'
            temp          = str2num(string(design_file.administer{trl})) + 49;
            tsa2_response = main(ip, port, 4, temp);
            fixation_cross(p);
            T.event03_administer_displayonset(trl) = GetSecs;
            T.event03_administer_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);
            T.event03_administerP_trigger(trl)    = string(tsa2_response{6});
            WaitSecs('UntilTime', end_jitter03 + task_dur)
            end_event03 = biopac_linux_matlab(channel, channel.administer, 0);

        case 'cognitive'
            fixation_cross(p);
            WaitSecs('UntilTime', end_jitter03 + wait_time); % equivalent to ramp-up time
            mr.initialized = [];
            % 5-1. present rotate image and text ____________________________________________________
            cog_image_filepath = fullfile(main_dir,'stimuli','cognitive');
            cog_filename = char(design_file.image_filename(trl));
            cog_fullfile = fullfile(cog_image_filepath,cog_filename);
            mr.cognitive_tex = Screen('MakeTexture', p.ptb.window, imread(cog_fullfile));


            Screen('DrawTexture', p.ptb.window, mr.cognitive_tex, [], [], 0);
            Screen('TextSize', p.ptb.window, 48);
            DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
            DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, p.ptb.white); % Text output of mouse position draw in the centre of the screen
            mr.initialized = Screen('Flip',p.ptb.window);
            % wait for response
            [resp, resp_keyname, resp_onset, RT] = cognitive_resp(p, channel, plateau, mr, mr.cognitive_tex);
            T.event03_administer_displayonset(trl) = mr.initialized;
            T.event03_administer_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);

            fixation_cross(p);
            WaitSecs('UntilTime', end_jitter03 + task_dur);
            end_event03 = biopac_linux_matlab(channel, channel.administer, 0);

            % record response
            T.event03_administerC_response(trl)       = resp;
            T.event03_administerC_responsekeyname(trl)= resp_keyname;
            T.event03_administerC_reseponseonset(trl) = resp_onset;
            T.event03_administerC_RT(trl)             = RT;

        case 'vicarious'
            video_filename                        = [design_file.video_filename{trl}];
            video_file      = fullfile(dir_video, video_filename);
            [movie, ~, ~, imgw, imgh] = Screen('OpenMovie', p.ptb.window, video_file, [], 1);
            fixation_cross(p);
            WaitSecs('UntilTime', end_jitter03 + wait_time);
            T.event03_administer_biopac(trl)      = biopac_linux_matlab(channel, channel.administer, 1);
            video_file                            = fullfile(dir_video, video_filename);
            movie_time                            = video_play(video_file , p , movie, imgw*2, imgh*2);
            end_event03 = biopac_linux_matlab(channel, channel.administer, 0);
            T.event03_administer_displayonset(trl)       = movie_time;  % 5sec

            fixation_cross(p);
            WaitSecs('UntilTime', end_jitter03 + task_dur);
    end
    %% _________________________ 7. jitter 04 Fixtion Jitter 0-2 sec _____________________

    fixation_cross(p);
    T.jitter04_fixation_onset(trl)         = Screen('Flip', p.ptb.window);
    T.jitter04_fixation_biopac(trl)        = biopac_linux_matlab(channel, channel.fixation2, 1);
    % WaitSecs(jitter2);
    WaitSecs('UntilTime', end_jitter03 + 9.00 + design_file.ISI2(trl));
    end_jitter04                           = biopac_linux_matlab(channel, channel.fixation2, 0);
    T.jitter04_fixation_duration(trl)      = end_jitter04 - T.jitter04_fixation_onset(trl) ;


    %% ________________________ 8. event 04 actual judgment __________________________

    image_filepath                  = fullfile(main_dir, 'stimuli', 'ratingscale');
    image_scale_filename            = ['task-', taskname, '_scale.png'];
    image_scale                     = fullfile(image_filepath, image_scale_filename);
    actual_tex = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(4, p, actual_tex,'actual', channel, channel.actual);
    biopac_linux_matlab(channel, channel.actual, 0);

    rating_trajectory{trl,2}              = trajectory;
    T.event04_actual_displayonset(trl)    = display_onset;
    T.event04_actual_RT(trl)              = RT;
    T.event04_actual_responseonset(trl)   = response_onset;
    T.event04_actual_biopac(trl)          = biopac_display_onset;


    %% ________________________ 7. temporarily save file _______________________
    tmpFileName = fullfile(sub_save_dir,[strcat('spacetop_task-social'),...
        strcat('_ses-',sprintf('%02d', session)),...
        strcat('_sub-', sprintf('%04d', sub)), ...
        '_run-', sprintf('%02d', run_num),'_TEMP_beh.csv' ]);
    writetable(T,tmpFileName);
end
%% _________________________ 8. End Instructions _______________________________

Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
T.param_end_instruct_onset(:)            = Screen('Flip',p.ptb.window);
T.param_end_biopac(:)                    = biopac_linux_matlab(channel, channel.trigger, 0);
WaitKeyPress(p.keys.end);
T.param_experiment_duration(:)           = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);


%% _________________________ 9. save parameter _________________________________

% onset + response file
saveFileName = fullfile(sub_save_dir,[bids_string,'_beh.csv' ]);
repoFileName = fullfile(repo_save_dir,[bids_string,'_beh.csv' ]);
writetable(T,saveFileName);
writetable(T,repoFileName);

% trajectory data
traject_saveFileName = fullfile(sub_save_dir, [bids_string,'_beh_trajectory.mat' ]);
traject_repoFileName = fullfile(repo_save_dir, [bids_string,'_beh_trajectory.mat' ]);
save(traject_saveFileName, 'rating_trajectory');
save(traject_repoFileName, 'rating_trajectory');

% ptb parameters
psychtoolbox_saveFileName = fullfile(sub_save_dir, [bids_string,'_psychtoolbox_params.mat' ]);
psychtoolbox_repoFileName = fullfile(repo_save_dir, [bids_string,'_psychtoolbox_params.mat' ]);
save(psychtoolbox_saveFileName, 'p');
save(psychtoolbox_repoFileName, 'p');

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
                % make sure keys released
                while KbCheck(-3); end
            end
        end
    end

% function [time] = biopac_linux_matlab(channel, channel_num, state_num)
%   if channel.biopac
%       channel.d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
%       time = GetSecs;
%   else
%       time = GetSecs;
%       return
%   end
% end
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

    function fixation_cross(p);
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
            p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('Flip', p.ptb.window);
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
        % * resp_keyname: 'left', 'right'
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
                fixation_cross(p);
%                 Screen('DrawTexture',p.ptb.window, fixTex);
                biopac_linux_matlab(channel, channel.fixation2, 1);
                WaitSecs('UntilTime', mr.initialized + plateau)
                count = count + 1;

            elseif buttonpressed(3)%     elseif keyCode(p.keys.right)
                resp = 2;          resp_keyname = 'right';
                biopac_linux_matlab(channel, channel.administer, 0);
                DrawFormattedText(p.ptb.window, mr.textDiff, p.ptb.xCenter-120-90, mr.textYc, p.ptb.white);
                DrawFormattedText(p.ptb.window, mr.textSame, p.ptb.xCenter+120, mr.textYc, [255 0 0]);
                Screen('DrawTexture', p.ptb.window, rt, [], [], 0);
                Screen('Flip',p.ptb.window);
                WaitSecs(p.resp.remainder);

                % fill in with fixation cross
                %remainder_time = task_duration-0.5-RT;
                % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
                %     p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
                % Screen('Flip', p.ptb.window);
%                 Screen('DrawTexture',p.ptb.window, fixTex);
                fixation_cross(p);
                biopac_linux_matlab(channel,  channel.fixation2, 1);
                WaitSecs('UntilTime', mr.initialized + plateau);
                % count = count +1;
            end
            biopac_linux_matlab(channel, channel.administer, 0);
            biopac_linux_matlab(channel, channel.fixation2, 0);
        end
    end
end
