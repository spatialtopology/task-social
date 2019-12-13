% 1. grab participant number ___________________________________________________
prompt = 'session number : ';
session = input(prompt);
prompt = 'subject number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);
prompt = 'which run order is this? 1st, 2nd, or 3rd? (type 1,2,3):  ';
run_num = input(prompt);

% 2. counterbalance version ____________________________________________________
% random sequence
r_seq =  [1,3,2,3,5,1,2,4,4,5];
index = rem(sub,10);
% c1 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
% c2 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
p1 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
p2 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
% v1 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
% v2 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];

bl_ind = rem(sub,6);
if session == 1
    switch bl_ind
        case 0
            input_counterbalance_file = p1;
        case 1
            input_counterbalance_file = p1;
        case 2
            input_counterbalance_file = p2;
        case 3
            input_counterbalance_file = p2;
        case 4
            input_counterbalance_file = p2;
        case 5
            input_counterbalance_file = p1;
    end
elseif session ~= 1
    switch bl_ind
        case 0
            input_counterbalance_file = p2;
        case 1
            input_counterbalance_file = p2;
        case 2
            input_counterbalance_file = p1;
        case 3
            input_counterbalance_file = p1;
        case 4
            input_counterbalance_file = p1;
        case 5
            input_counterbalance_file = p2;
    end
end


        %% -----------------------------------------------------------------------------
        %                           Parameters
        % ______________________________________________________________________________
        %% A. Psychtoolbox parameters _________________________________________________
        global p
        Screen('Preference', 'SkipSyncTests', 1);
        PsychDefaultSetup(2);
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
        taskname                       = 'pain';

        dir_video                      = fullfile(main_dir,'stimuli','task-vicarious_videofps-024_dur-4s','selected');
        cue_low_dir                    = fullfile(main_dir,'stimuli','cue','scl');
        cue_high_dir                   = fullfile([main_dir,'stimuli','cue','sch']);
        counterbalancefile             = fullfile(main_dir, 'design', 's04_final_counterbalance_with_jitter',[input_counterbalance_file, '.csv']);
        countBalMat                    = readtable(counterbalancefile);

        %% C. Circular rating scale _____________________________________________________
        image_filepath                 = fullfile(main_dir, 'stimuli', 'ratingscale');
        image_scale_filename           = ['task-', taskname, '_scale.png'];
        image_scale                    = fullfile(image_filepath, image_scale_filename);

        %% D. making output table ________________________________________________________
        vnames = {'param_fmriSession','param_runNum','param_counterbalanceVer','param_counterbalanceBlockNum',...
                                      'param_cue_type','param_administer_type','param_cond_type','param_triggerOnset',...
                                      'p1_fixation_onset','p1_fixation_duration',...
                                      'p2_cue_onset','p2_cue_type','p2_cue_filename',...
                                      'p3_expect_onset','p3_expect_responseonset','p3_expect_RT', ...
                                      'p4_fixation_onset','p4_fixation_duration',...
                                      'p5_administer_type','p5_administer_onset',...
                                      'p6_actual_onset','p6_actual_responseonset','p6_actual_RT',...
                                      'param_end_instruct_onset', 'param_experimentDuration'};
        T                              = array2table(zeros(size(countBalMat,1),size(vnames,2)));
        T.Properties.VariableNames     = vnames;
        T.p2_cue_type                  = cell(size(countBalMat,1),1);
        T.p2_cue_filename              = cell(size(countBalMat,1),1);

        a                              = split(counterbalancefile,filesep); % full path filename components
        version_chunk                  = split(extractAfter(a(end),"ver-"),"_");
        block_chunk                    = split(extractAfter(a(end),"block-"),["-", "."]);
        T.param_fmriSession(:)            = session;
        T.param_runNum(:)              = run_num;
        T.param_counterbalanceVer(:)   = str2double(version_chunk{1});
        T.param_counterbalanceBlockNum(:) = str2double(block_chunk{1});
        T.param_cue_type               = countBalMat.cue_type;
        T.param_administer_type        = countBalMat.administer;
        T.param_cond_type              = countBalMat.cond_type;
        T.p2_cue_type                  = countBalMat.cue_type;
        T.p5_administer_type           = countBalMat.administer;

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
        TR                               = 0.46;
        task_duration                    = 6.50;
      %
        %% G. instructions _____________________________________________________
        instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions');
        instruct_start_name            = ['task-', taskname, '_start.png'];
        instruct_end_name              = ['task-', taskname, '_end.png'];
        instruct_start                 = fullfile(instruct_filepath, instruct_start_name);
        instruct_end                   = fullfile(instruct_filepath, instruct_end_name);

        %% ------------------------------------------------------------------------------
        %                              Start Experiment
        %________________________________________________________________________________

          %% ______________________________ Instructions _________________________________
        HideCursor;
        Screen('TextSize',p.ptb.window,72);
        start.texture = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
        Screen('DrawTexture',p.ptb.window,start.texture,[],[]);
        Screen('Flip',p.ptb.window);

        %% _______________________ Wait for Trigger to Begin ___________________________
        DisableKeysForKbCheck([]);
        WaitKeyPress(p.keys.start);
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('Flip', p.ptb.window);
        WaitKeyPress(p.keys.trigger);
        T.param_triggerOnset(:)        = GetSecs;

        WaitSecs(TR*6);

        %% ___________________________ 0. Experimental loop ____________________________
        for trl = 1:size(countBalMat,1)

        %% _________________________ 1. Fixtion Jitter 0-4 sec _________________________
        jitter1 = countBalMat.ISI1(trl);
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
           p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        fStart1 = GetSecs;
        Screen('Flip', p.ptb.window);
        WaitSecs(jitter1);
        fEnd1 = GetSecs;

        T.p1_fixation_onset(trl)      = fStart1;
        T.p1_fixation_duration(trl)   = fEnd1 - fStart1;
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
        T.p2_cue_onset(trl)            = Screen('Flip',p.ptb.window);
        WaitSecs(1.00)
        T.p2_cue_type{trl}             = countBalMat.cue_type{trl};
        T.p2_cue_filename{trl}         = countBalMat.cue_image{trl};


        %-------------------------------------------------------------------------------
        %                             3. expectation rating
        %-------------------------------------------------------------------------------
        Screen('MakeTexture', p.ptb.window, imread(cueImage));
        T.p3_expect_onset(trl)         = GetSecs;
        [trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,cueImage,'expect');
        T.p3_expect_responseonset(trl) = buttonPressOnset;
        rating_Trajectory{trl,1}       = trajectory;
        T.p3_expect_RT(trl)            = RT;

        %-------------------------------------------------------------------------------
        %                             4. Fixtion Jitter 0-2 sec
        %-------------------------------------------------------------------------------
        % 1) get jitter
        % jitter2 = countBalMat.ISI2(trl);
        % Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
        %    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        % fStart2 = GetSecs;
        % T.p4_fixation_onset(trl) = Screen('Flip', p.ptb.window);
        % WaitSecs(jitter2);
        % fEnd2 = GetSecs;
        % T.p4_fixation_duration(trl) = fEnd2 - fStart2;

        %-------------------------------------------------------------------------------
        %                            5. pain
        %-------------------------------------------------------------------------------

        TEMP = countBalMat.administer(trl);
        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
           p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
        Screen('Flip', p.ptb.window);
        T.p5_administer_onset(trl) = TriggerThermodeSocial(TEMP, 'USE_BIOPAC',1);
        WaitSecs(task_duration);
        %WaitSecs(task_duration-T.p5_administer_onset(trl));
        fEnd2 = GetSecs;
        T.p5_administer_type(trl) = countBalMat.administer(trl);

        %-------------------------------------------------------------------------------
        %                                6. post evaluation rating
        %-------------------------------------------------------------------------------
        T.p6_actual_onset(trl) = GetSecs;
        [trajectory, RT, buttonPressOnset] = circular_rating_output(4,p,image_scale,'actual');
        T.p6_actual_responseonset(trl) = buttonPressOnset;
        rating_Trajectory{trl,2} = trajectory;
        T.p6_actual_RT(trl) = RT;

        end

        %% ______________________________ Ending _________________________________
        end_texture = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
        Screen('DrawTexture',p.ptb.window,end_texture,[],[]);
        T.param_end_instruct_onset(:) = Screen('Flip',p.ptb.window);
        WaitKeyPress(p.keys.end);

        T.param_experimentDuration(:) = T.param_end_instruct_onset(1) - T.param_triggerOnset(1);


        %-------------------------------------------------------------------------------
        %                                   save parameter
        %-------------------------------------------------------------------------------
        sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub)), 'beh' );
        if ~exist(sub_save_dir, 'dir')
            mkdir(sub_save_dir)
        end

        saveFileName = fullfile(sub_save_dir,[strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_beh.csv' ]);
        writetable(T,saveFileName);

        traject_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_beh_trajectory.mat' ]);
        save(traject_saveFileName, 'rating_Trajectory');

        psychtoolbox_saveFileName = fullfile(sub_save_dir, [strcat('sub-', sprintf('%04d', sub)), '_task-',taskname,'_psychtoolbox_params.mat' ]);
        save(psychtoolbox_saveFileName, 'p');

        sca;


        %-------------------------------------------------------------------------------
        %                                   Function
        %-------------------------------------------------------------------------------
        function [t] = TriggerThermodeSocial(temp, varargin)
            USE_BIOPAC = false;

            for i = 1:length(varargin)
                switch varargin{i}
                    case 'USE_BIOPAC'
                        USE_BIOPAC = varargin{i+1};
                end
            end

            ljasm = NET.addAssembly('LJUDDotNet');
            ljudObj = LabJack.LabJackUD.LJUD;

            [~, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
            ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

            % calculate byte code
            % Integer values are simply converted to binary, non integer values are
            % incremented by 128 and converted to binary. So 45 is bin(45) while
            % 45.5 is bin(45+128).
            temp = temp + 101;
            % temp = temp + 100;
            if(mod(temp,1))
                % note: this will treat all decimal values the same. Specific
                % temperature mapping is determined in PATHWAY software
                temp = floor(temp) + 128;
            end
            bytecode=sprintf('%08.0f',str2double(dec2bin(temp)))-'0';

            for i=0:7
                % Initiate FIO0 to FIO7 output
                ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT',i, bytecode(i+1), 0, 0);

                if USE_BIOPAC
                    % Initiate CIO3 and EIO7 output (biopac)
                    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8, bytecode(i+1), 0, 0);
                end
            end

            % Wait for 1 second. The delay is performed in the U3 hardware, and delay time is in microseconds.
            % Valid delay values are 0 to 4194176 microseconds, and resolution is 128 microseconds.
            ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_WAIT', 0, 1000000, 0, 0);



            for i=0:7
                  % Terminate FIO0 to FIO7 output (reset to 0)
                  ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i, 0, 0, 0);

                  if USE_BIOPAC
                      % Terminate CIO3 and EIO7 output (reset to 0)
                      % Note: this sends a binary code to biopac channels (likely
                      % D8-D15).
                      ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', i+8,0, 0, 0);
                  end
            end

            t = GetSecs;
            % Perform the operations/requests
            ljudObj.GoOne(ljhandle);
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
