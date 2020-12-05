function [trajectory, display_onset, RT, response_onset, biopac_display_onset] = circular_rating_output(duration, p, scale_tex, rating_type, biopac, channel, channel_type)

%% Phil Kragel 6/20/2019
% global screenNumber window windowRect xCenter yCenter screenXpixels screenYpixels
% shows a circular rating scale and records mouse position

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

%% edited Heejung Jung 7/26/2019  allows to show different rating scales (expect, actual)
% edited Heejung Jung 11/25/2020 biopac parameters
%
% [ Input ]
% * duration             - length of response period in seconds)
% * p                    - psychtoolbox window parameters
% * scale_tex            - rating scale texture (for the social influence task, there are two rating scales
%                                     "expect" one is the rating scale layered with social cues,
%                                     "actual" one is an empty rating scale)
% [ Output ]
% * trajectory           - n samples x 2 matrix (x coord, y coord)
% * display_onset        - the time that the scale_tex was flipped
% * response_onset       - the time that the pariticpant pressed the mouse button
% * response_onset       - button press reaction time = response_onset - display_onset
% * biopac_display_onset - the time that the scale_tex was flipped and was registered in Biopac
%
% Additions ________________________________________________________________________________
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


trajectory = NaN;
display_onset= NaN;
RT = NaN;
response_onset = NaN;
biopac_display_onset = NaN;


HideCursor;

%%% configure screen
dspl.screenWidth = p.ptb.rect(3);
dspl.screenHeight = p.ptb.rect(4);
dspl.xcenter = dspl.screenWidth/2;
dspl.ycenter = dspl.screenHeight/2;

dspl.cscale.width = 964; % image scale width
dspl.cscale.height = 480; % image scale height
dspl.cscale.xcenter = 483; % scale center (does not equal to screen center)
dspl.cscale.ycenter = 407;
dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenNumber);

Screen('FillRect',dspl.cscale.w,0);
% scale_tex = Screen('MakeTexture',p.ptb.window, imread(image_scale));
% placement
dspl.cscale.rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
Screen('DrawTexture',dspl.cscale.w,scale_tex,[],dspl.cscale.rect);
%Screen('TextSize',dspl.cscale.w,40);

% determine cursor parameters for all scales
cursor.xmin = dspl.cscale.rect(1);
cursor.xmax = dspl.cscale.rect(3);
cursor.ymin = dspl.cscale.rect(2);
cursor.ymax = dspl.cscale.rect(4);

cursor.size = 8;
cursor.xcenter = ceil(dspl.cscale.rect(1) + (dspl.cscale.rect(3) - dspl.cscale.rect(1))*0.5);
cursor.ycenter = ceil(dspl.cscale.rect(2) + (dspl.cscale.rect(4)-dspl.cscale.rect(2))*0.847);

RATINGTITLES = {'INTENSITY'};
biopac_linux_matlab(biopac, channel, channel_type, 0);

% initialize
Screen('TextSize',p.ptb.window,72);
DrawFormattedText(p.ptb.window,rating_type,'center',dspl.screenHeight/2+150,255);
display_onset = Screen('Flip',p.ptb.window);
biopac_display_onset = biopac_linux_matlab(biopac, channel, channel_type, 1);


cursor.x = cursor.xcenter;
cursor.y = cursor.ycenter;
sample = 1;
SetMouse(cursor.xcenter,cursor.ycenter);
nextsample = GetSecs;

buttonpressed  = false;
rlim = 250;
xlim = cursor.xcenter;
ylim = cursor.ycenter;
while (GetSecs-display_onset) <  duration

    loopstart = GetSecs;

    % sample at SAMPLERATE
    if loopstart >= nextsample
        ctime(sample) = loopstart; %#ok
        trajectory(sample,1) = cursor.x;
        trajectory(sample,2) = cursor.y;
        nextsample = nextsample+SAMPLERATE;
        sample = sample+1;
    end


    if ~buttonpressed
    [x, y, buttonpressed] = GetMouse; % measure mouse movement
    SetMouse(cursor.xcenter,cursor.ycenter); % reset mouse position

    % calculate displacement
    cursor.x = (cursor.x + x-cursor.xcenter) * TRACKBALL_MULTIPLIER;
    cursor.y = (cursor.y + y-cursor.ycenter) * TRACKBALL_MULTIPLIER;
    [cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, rlim, xlim, ylim);

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
       response_onset = GetSecs;
       RT = response_onset - display_onset;
       biopac_linux_matlab(biopac, channel, channel_type, 0);
       buttonpressed = [0 0 0];
       Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
       DrawFormattedText(p.ptb.window,rating_type,'center',dspl.screenHeight/2+150,255);
       % cursor changes
       Screen('FillOval',p.ptb.window,[255 0 255],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
       Screen('Flip',p.ptb.window);
       WaitSecs(0.500);
       remainder_time = duration-0.5-RT;

       Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
       p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
       Screen('Flip',p.ptb.window);
       %WaitSecs(remainder_time);
       WaitSecs('UntilTime', display_onset + duration);
    end

end


end


%-------------------------------------------------------------------------------
%                            function Limit cursor
%-------------------------------------------------------------------------------
% Function by Xiaochun Han
function [x, y, xlim, ylim] = limit(x, y, xcenter, ycenter, r, xlim,ylim)
if (y<=ycenter) && (((x-xcenter)^2 + (y-ycenter)^2) <= r^2)
   xlim = x;
   ylim = y;
elseif (y<=ycenter) && (((x-xcenter)^2 + (y-ycenter)^2) > r^2)
   x = xlim;
   y = ylim;
elseif y>ycenter && (((x-xcenter)^2 + (y-ycenter)^2) <= r^2)
   xlim = x;
   y = ycenter;
elseif y>ycenter && (((x-xcenter)^2 + (y-ycenter)^2) > r^2)
   x = xlim;
   y = ycenter;
end
end
