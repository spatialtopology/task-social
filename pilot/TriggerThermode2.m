function [t] = TriggerThermode2(temp)
ip = '192.168.1.3';
newtemp = temp+10;
port = 20121;
main(ip, port, 1, newtemp);
% main(ip, port, 4, newtemp);
t = GetSecs;
% main(ip, port, 5, newtemp);
end