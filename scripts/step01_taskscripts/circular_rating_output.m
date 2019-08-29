function [trajectory, RT, buttonPressOnset] = circular_rating_output(duration, p, image_scale, rating_type)
% global screenNumber window windowRect xCenter yCenter screenXpixels screenYpixels
% shows a circular rating scale and records mouse position
%
% Input: duration - length of response period in seconds)
% Output: trajectory - n samples x 2 matrix (x coord, y coord)
%
% Note - this function call a new instance of PTB
% you likely wont want to use it this way in a paradigm
% just copy paste the relevant sections or use this as a subfunction
% initializing screen
%
% You will need PTB installed for this to work.
%
% [trajectory, dspl,cursor] = circular_rating(3);
% figure; comet(trajectory(:,1),trajectory(:,2))
%
% Phil Kragel 6/20/2019
% edited Heejung Jung 7/26/2019
%
% Additions ________________
% 1. duration:    length of rating scale, NOTE that the duration is filled with a fixation
%                 once the participant incidates a response.
%                 e.g. * experimenter fixes rating duration to 4 sec.
%                      * participant RT to respond to rating scale was 1.6 sec.
%                      * response will stay on screen for 0.5 sec
%                      * fixation cross will fill the the remainder of the duration
%                              i.e., 4-1.6-0.5 = 1.9 sec of fixation
% 2. p: psychtoolbox window parameters
% 3. image_scale: social influence task requires different rating scales
%                 (pain rating vs cognitive effort rating)
%                 The code takes different rating scale images
% 4. rating_type: social influence task has two ratings "expectation" & "actual experience"
%                 rating_type takes the keyword and displays it onto the rating scale



SAMPLERATE = .01; % used in continuous ratings
TRACKBALL_MULTIPLIER=1;
RT = NaN;
buttonPressOnset = NaN;

HideCursor;

%%% configure screen
dspl.screenWidth = p.ptb.rect(3);
dspl.screenHeight = p.ptb.rect(4);
dspl.xcenter = dspl.screenWidth/2; % 960
dspl.ycenter = dspl.screenHeight/2; % 540

% dspl.screenWidth = screenXpixels;
% dspl.screenHeight = screenYpixels;
% dspl.xcenter = xCenter;
% dspl.ycenter = yCenter;
% create SCALE screen for continuous rating
dspl.cscale.width = 964;
dspl.cscale.height = 480;
dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenNumber);
% paint black
Screen('FillRect',dspl.cscale.w,0);
% add scale image
% dspl.cscale.imagefile = which(image_scale);
% dspl.cscale.imagefile = '/Users/h/Dropbox/Projects/socialPain/scale.png';
dspl.cscale.texture = Screen('MakeTexture',p.ptb.window, imread(image_scale));
% placement
dspl.cscale.rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
% dspl.cscale.rect = [dspl.xcenter dspl.ycenter dspl.xcenter dspl.ycenter];
% shiftdown = ceil(dspl.screenHeight*0);
% dspl.cscale.rect = dspl.cscale.rect + [0 shiftdown 0 shiftdown];
Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);
% add title
Screen('TextSize',dspl.cscale.w,40);


% determine cursor parameters for all scales
cursor.xmin = dspl.cscale.rect(1);
cursor.xmax = dspl.cscale.rect(3);
cursor.ymin = dspl.cscale.rect(2);
cursor.ymax = dspl.cscale.rect(4);


cursor.size = 8;
cursor.xcenter = ceil(cursor.xmax - cursor.xmin);
cursor.ycenter = ceil(cursor.ymax - cursor.ymin);



RATINGTITLES = {'INTENSITY'};


% initialize
Screen('TextSize',p.ptb.window,72);
DrawFormattedText(p.ptb.window,rating_type,'center',dspl.screenHeight/2+150,255);
% DrawFormattedText(p.ptb.window,'.','center','center',255);
timing.initialized = Screen('Flip',p.ptb.window);

cursor.x = cursor.xcenter;
cursor.y = cursor.ycenter+230;

sample = 1;
SetMouse(cursor.xcenter,cursor.ycenter);
nextsample = GetSecs;

buttonpressed  = false;

while GetSecs < timing.initialized + duration

    loopstart = GetSecs;

    % sample at SAMPLERATE
    if loopstart >= nextsample
        ctime(sample) = loopstart; %#ok
        trajectory(sample,1) = cursor.x; %#ok
        trajectory(sample,2) = cursor.y;
        nextsample = nextsample+SAMPLERATE;
        sample = sample+1;
    end


    if ~buttonpressed
    % measure mouse movement
    [x, y, buttonpressed] = GetMouse;

    % reset mouse position
    SetMouse(cursor.xcenter,cursor.ycenter);

    % calculate displacement
    cursor.x = (cursor.x + x-cursor.xcenter) * TRACKBALL_MULTIPLIER;
    cursor.y = (cursor.y + y-cursor.ycenter) * TRACKBALL_MULTIPLIER;

    % check bounds
    if cursor.x > cursor.xmax
        cursor.x = cursor.xmax;
    elseif cursor.x < cursor.xmin
        cursor.x = cursor.xmin;
    end

    if cursor.y > cursor.ymax
        cursor.y = cursor.ymax;
    elseif cursor.y < cursor.ymin
        cursor.y = cursor.ymin;
    end


    % produce screen
    Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
    DrawFormattedText(p.ptb.window,rating_type,'center',dspl.screenHeight/2+150,255);
    % add rating indicator ball
    Screen('FillOval',p.ptb.window,[255 0 0],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
    Screen('Flip',p.ptb.window);

    elseif any(buttonpressed)
       RT = GetSecs - timing.initialized;
       buttonPressOnset = GetSecs;
       buttonpressed = [0 0 0];

%        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
%           p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
       Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
       DrawFormattedText(p.ptb.window,rating_type,'center',dspl.screenHeight/2+150,255);
       Screen('FillOval',p.ptb.window,[1 1 1],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
       Screen('Flip', p.ptb.window);
       remainder_time = duration-0.5-RT;
       WaitSecs(remainder_time);
    end

end


end
