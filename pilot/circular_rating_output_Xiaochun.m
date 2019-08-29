    function [trajectory, RT_rating, RT_conf, Angle_rating, Angle_conf] = circular_rating(duration, instruction, type)
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
%
%
% New added features:
% 1. Limit the trajectory of the cursor within the semi-circle;
% 2. Draw a line between origin point and participant's rating;
% 3. After the rating, participant could increase the area of rating to
% indicate the confidence of rating;
% 4. Besides the trajectory, the output also include RT of rating, RT of
% confidence adjusting, Angle of the rating, Angle area of confidence adjusting.
%
% Please feel free to contact me if the instructions above are not clear to
% you.
%
% Xiaochun Han 08/07/2019
%
%
% New added features:
% Input: duration    - length of response period in seconds
%        instruction - adjust instructions and scale pictures for different ratings
%                      race   - 'Please rate how relevant is [AGE] for predicting high vs. low heat.'
%                      age    - 'Please rate how relevant is [RACE] for predicting high vs. low heat.'
%                      expect - 'Please rate the average pain you would expect for the type of stimulus that the face represents (ignoring no-heat trials).'
%                      pain   - 'Please rate how painful the heat feels to you.'
%        type        - whether or not include confidence rating
%                      1      - including confidence rating
%                      2      - NOT including confidence rating
% Xiaochun Han 08/26/2019
%
% Screen('Preference', 'SkipSyncTests', 1);
% duration = 10;
RT_rating = NaN;
RT_conf = NaN;
Angle_rating = NaN;
Angle_conf = NaN;
SAMPLERATE = .001; % used in continuous ratings
TRACKBALL_MULTIPLIER=1;
% AssertOpenGL;
p.ptb.screenID = max(Screen('Screens'));
% prepare the screen
[p.w, p.rect] = Screen('OpenWindow',p.ptb.screenID);
HideCursor;

% configure screen
dspl.screenWidth            = p.rect(3);
dspl.screenHeight           = p.rect(4);
dspl.xcenter                = dspl.screenWidth/2;
dspl.ycenter                = dspl.screenHeight/2;
p.conf.white                = WhiteIndex(p.ptb.screenID);
p.ptb.fontsize              = 26;
p.ptb.fontcolor             = p.conf.white;
p.ptb.fontstyle             = 0;
p.ptb.fontname              = 'Arial';

% create SCALE screen for continuous rating
dspl.cscale.width = 720;
dspl.cscale.height = 405;
dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenID);
% paint black
Screen('FillRect',dspl.cscale.w,0);
% instruction format
Screen('TextColor', dspl.cscale.w, p.ptb.fontcolor);
Screen('TextSize', dspl.cscale.w, p.ptb.fontsize-6);
Screen('TextFont', dspl.cscale.w, p.ptb.fontname);
p.ptb.qstr = {'Please rate how relevant is [AGE] for predicting high vs. low heat.';
              'Please rate how relevant is [RACE] for predicting high vs. low heat.';
              'Please rate the average pain you would expect for the type of stimulus that the face represents (ignoring no-heat trials).';
              'Please rate how painful the heat feels to you.'};
if strcmp(instruction,'age')
   DrawFormattedText(dspl.cscale.w,p.ptb.qstr{1},'center',dspl.ycenter-250);
   dspl.cscale.imagefile = which('Relevance_scale.png');
elseif strcmp(instruction, 'race')
   DrawFormattedText(dspl.cscale.w,p.ptb.qstr{2},'center',dspl.ycenter-250);
   dspl.cscale.imagefile = which('Relevance_scale.png');
elseif strcmp(instruction, 'expect')
   DrawFormattedText(dspl.cscale.w,p.ptb.qstr{3},'center',dspl.ycenter-250);
   dspl.cscale.imagefile = which('scale.png');
elseif strcmp(instruction, 'pain')
   DrawFormattedText(dspl.cscale.w,p.ptb.qstr{4},'center',dspl.ycenter-250);
   dspl.cscale.imagefile = which('scale.png');
 elseif strcmp(instruction, 'cognitive')
   % DrawFormattedText(dspl.cscale.w,p.ptb.qstr{4},'center',dspl.ycenter-250);
   dspl.cscale.imagefile = '/Users/h/Documents/projects_local/social_influence/stimuli/ratingscale/task-cognitive_scale.jpg';
end

image = imread(dspl.cscale.imagefile);
dspl.cscale.texture = Screen('MakeTexture',p.w,image);
% placement
dspl.cscale.rect = [...
    [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
    [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);

cursor.size = 8;
cursor.xcenter = ceil(dspl.cscale.rect(1) + (dspl.cscale.rect(3) - dspl.cscale.rect(1))/2 + 14);
cursor.ycenter = ceil(dspl.cscale.rect(4)-62);

timing.initialized = Screen('Flip',p.w);

cursor.x = cursor.xcenter;
cursor.y = cursor.ycenter;

sample = 1;
SetMouse(cursor.xcenter,cursor.ycenter);
nextsample = GetSecs;

buttonpressed  = false;
%Limit the cursor moving within the semi-circle scale
xlim = cursor.xcenter;
ylim = cursor.ycenter;
rlim = 237;

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

    if ~any(buttonpressed)
        % measure mouse movement
        [x, y, buttonpressed] = GetMouse;

        cursor.x = x * TRACKBALL_MULTIPLIER;
        cursor.y = y * TRACKBALL_MULTIPLIER;

        %Limit the cursor moving within the semi-circle scale
        [cursor.x, cursor.y, xlim, ylim] = limit(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, rlim, xlim, ylim);

        % produce screen
        Screen('CopyWindow',dspl.cscale.w,p.w);
        % add rating indicator ball
        Screen('FillOval',p.w,[255 1 1],[[cursor.x cursor.y]-cursor.size [cursor.x cursor.y]+cursor.size]);
        SetMouse(cursor.x,cursor.y);
        Screen('Flip',p.w);
    elseif any(buttonpressed)
        RT_rating = GetSecs - timing.initialized;
        Screen('CopyWindow',dspl.cscale.w,p.w);

        %Draw a line to indicate rating angle after clicking button
        Angle_rating = drawline(cursor.x, cursor.y, cursor.xcenter, cursor.ycenter, p.w, rlim);
        Screen('Flip',p.w);
        while any(buttonpressed) % if already down, wait for release
           [~,~,buttonpressed] = GetMouse;
        end
        if type == 1
        %Rate the confidence about the previous rating
           [Angle_conf, RT_conf] = conf_rating(cursor.xcenter, cursor.ycenter, rlim, Angle_rating, 3, p.w,dspl.cscale.w, timing.initialized, duration);
        elseif type == 2
            WaitSecs(duration-RT_rating);
        end
    end
end

Screen('CloseAll')
figure; comet((trajectory(:,1)-cursor.xcenter),(cursor.ycenter-trajectory(:,2)));
end

%Limit the cursor moving within the semi-circle scale
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

%Draw a line to indicate rating angle after clicking button
function angle = drawline(x, y, xcenter, ycenter, win, r)
angle = NaN;
if x >= xcenter
   angle = atan((ycenter-y)/(x-xcenter));
   yaim = ycenter - r*sin(angle);
   xaim = xcenter + r*cos(angle);
   yaim2 = ycenter - (r-50)*sin(angle);
   xaim2 = xcenter + (r-50)*cos(angle);
   angle = pi - angle;
else
   angle = atan((ycenter-y)/(xcenter-x));
   yaim = ycenter - r*sin(angle);
   xaim = xcenter - r*cos(angle);
   yaim2 = ycenter - (r-50)*sin(angle);
   xaim2 = xcenter - (r-50)*cos(angle);
end
angle = 180*angle/pi;
Screen('DrawLines', win, [xaim, xcenter; yaim, ycenter], 4, [255 1 1]);
Screen('DrawLines', win, [xaim2, xcenter; yaim2, ycenter], 5, [0 0 0]);
end

%Rate the confidence about the previous rating
function [sizeAngle, RT] = conf_rating(xcenter, ycenter, r, angle, mouse, window, hidewindow, initial_timing, duration)
sizeAngle = NaN;
RT = NaN;
positionOfMainCircle = [xcenter-r ycenter-r xcenter+r ycenter+r];
positionOfMainCircle2 = [xcenter-r+50 ycenter-r+50 xcenter+r-50 ycenter+r-50];
sample = 1;
x(sample,1) = xcenter;
y(sample,1) = ycenter;
SetMouse(xcenter,ycenter);
buttonpressed  = false;
startAngleFix = angle-90;
startAngle = angle-90;
sizeAngle  = 1;
timing_start = GetSecs;
while GetSecs < initial_timing + duration
   if ~any(buttonpressed)
       sample = sample+1;
       [x(sample,1), y(sample,1), buttonpressed] = GetMouse;
       if (y(sample, 1) < y(sample-1, 1))%||(x(sample, 1) > x(sample-1, 1))
          if (startAngle <= -90) && (sizeAngle < 180)
             startAngle = -90;
             sizeAngle = sizeAngle+mouse ;
          elseif (startAngle <= -90) && (sizeAngle >= 180)
             startAngle = -90;
             sizeAngle = 180;
          elseif (startAngle+sizeAngle >= 90) && (startAngle > -90)
             startAngle = startAngle-mouse;
             sizeAngle = sizeAngle+mouse ;
          elseif (startAngle+sizeAngle >= 90) && (startAngle <= -90)
                startAngle = -90;
                sizeAngle = 180;
          else
             startAngle = startAngle-mouse;
             sizeAngle  = sizeAngle+2*mouse ;
          end
       elseif (y(sample, 1) > y(sample-1, 1))%||(x(sample, 1) < x(sample-1, 1))
          if (startAngleFix - startAngle) > (startAngle + sizeAngle - startAngleFix - 1)+mouse
             startAngle = startAngle+mouse;
             sizeAngle  = 90-startAngle;
          elseif (startAngleFix - startAngle) < (startAngle + sizeAngle - startAngleFix - 1)-mouse
             startAngle = -90;
             sizeAngle  = sizeAngle-mouse;
          else
             if startAngle < startAngleFix
                startAngle = startAngle+mouse;
                sizeAngle  = sizeAngle-2*mouse;
             elseif startAngle >= startAngleFix
                startAngle = startAngleFix;
                sizeAngle = 1;
             end
          end
       end
       Screen('CopyWindow',hidewindow,window);
       Screen('FillArc',window, [255,1,1],positionOfMainCircle,startAngle,sizeAngle);
       Screen('FillArc',window, [0,0,0],positionOfMainCircle2,startAngle,sizeAngle);
       Screen('Flip', window);
   else
       RT = GetSecs - timing_start;
       break;
   end
end
while GetSecs < initial_timing + duration
   Screen('CopyWindow',hidewindow,window);
   Screen('FillArc',window, [255,1,1],positionOfMainCircle,startAngle,sizeAngle);
   Screen('FillArc',window, [0,0,0],positionOfMainCircle2,startAngle,sizeAngle);
   Screen('Flip', window);
end
sizeAngle = abs(sizeAngle);
end
