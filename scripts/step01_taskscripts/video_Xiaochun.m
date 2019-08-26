function [Tm] = video_Xiaochun(moviename,p)
% [p.ptb.window, rect]  = Screen(p.ptb.screenID, 'OpenWindow',p.ptb.bg);
Tt = 0;
rate = 1;
[movie, ~, ~, imgw, imgh] = Screen('OpenMovie', p.ptb.window, moviename);
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
