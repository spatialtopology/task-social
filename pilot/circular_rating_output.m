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
dspl.cscale.xcenter = 497;
dspl.cscale.ycenter = 406;
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
if strcmp(rating_type, 'expect')
    DrawFormattedText(p.ptb.window,'expect','center',dspl.screenHeight/2+150,255);
%     DrawFormattedText2('<size=60>expect?', 'win', p.ptb.window, 'sx', p.ptb.xCenter, 'sy', p.ptb.yCenter, 'baseColor',p.ptb.white ); % Text output of mouse position draw in the centre of the screen
elseif strcmp(rating_type, 'actual')
    DrawFormattedText(p.ptb.window,'actual', 'center',dspl.screenHeight/2+150,255);
%     DrawFormattedText2('<size=60>actual?', 'win', p.ptb.window, 'sx', p.ptb.xCenter, 'sy', p.ptb.yCenter, 'baseColor',p.ptb.white ); % Text output of mouse position draw in the centre of the screen

end
% DrawFormattedText(p.ptb.window,'.','center','center',255);
timing.initialized = Screen('Flip',p.ptb.window);

cursor.x = cursor.xcenter
cursor.y = cursor.ycenter %+230
% cursor.xcenter-250, cursor.ycenter+160
sample = 1;
SetMouse(dspl.xcenter,dspl.screenHeight/2+165 ); 
% SetMouse(dspl.cscale.xcenter,dspl.cscale.ycenter);
% SetMouse(cursor.xcenter-250, cursor.ycenter+160);
% SetMouse(cursor.xcenter,cursor.ycenter);
% SetMouse(cursor.x,cursor.y);
nextsample = GetSecs;

buttonpressed  = false;

xlim = cursor.xcenter;
ylim = cursor.ycenter;
rlim = 270;

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


%     % check bounds - square
%     if cursor.x > cursor.xmax
%         cursor.x = cursor.xmax;
%     elseif cursor.x < cursor.xmin
%         cursor.x = cursor.xmin;
%     end
%
%     if cursor.y > cursor.ymax
%         cursor.y = cursor.ymax;
%     elseif cursor.y < cursor.ymin
%         cursor.y = cursor.ymin;
%     end


%     [cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, cursor.xcenter-250, cursor.ycenter+160, rlim, xlim,ylim);
    [cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, dspl.xcenter,dspl.screenHeight/2+165, rlim, xlim,ylim);
    % produce screen
    Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
    if strcmp(rating_type, 'expect')
        DrawFormattedText(p.ptb.window,'expect','center',dspl.screenHeight/2+150,255);
    elseif strcmp(rating_type, 'actual')
        DrawFormattedText(p.ptb.window,'actual','center',dspl.screenHeight/2+150,255);
    end
    % add rating indicator ball
    Screen('FillOval',p.ptb.window,[255 0 0],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
%     Screen('FillOval',p.ptb.window,[255 0 0],[[dspl.cscale.xcenter dspl.cscale.ycenter]-cursor.size [dspl.cscale.xcenter dspl.cscale.ycenter]+cursor.size]);
   
    Screen('Flip',p.ptb.window);

    elseif any(buttonpressed)
       RT = GetSecs - timing.initialized;
       buttonPressOnset = GetSecs;
       buttonpressed = [0 0 0];

%        Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
%           p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
       Screen('CopyWindow',dspl.cscale.w,p.ptb.window);
       if strcmp(rating_type, 'expect')
           DrawFormattedText(p.ptb.window,'expect','center',dspl.screenHeight/2+150,255);
       elseif strcmp(rating_type, 'actual')
           DrawFormattedText(p.ptb.window,'actual','center',dspl.screenHeight/2+150,255);
       end
       Screen('FillOval',p.ptb.window,[1 1 1],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
       
%         Screen('FillOval',p.ptb.window,[1 1 1],[[ dspl.cscale.xcenter dspl.cscale.ycenter]-cursor.size [dspl.cscale.xcenter dspl.cscale.ycenter]+cursor.size]);
       Screen('Flip', p.ptb.window);
       remainder_time = duration-0.5-RT;
       WaitSecs(remainder_time);
    end

end


end


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
