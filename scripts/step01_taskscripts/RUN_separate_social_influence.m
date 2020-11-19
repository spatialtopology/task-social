clear all;
Screen('Close');
clearvars;
sca;
% 1. grab participant number ___________________________________________________
prompt = 'SESSION (1 or 4): ';
session = input(prompt);
prompt = 'PARTICIPANT (in raw number form, e.g. 1, 2,...,98): ';
sub_num = input(prompt);
prompt = 'BIOPAC YES=1 NO=0 : ';
biopac = input(prompt);

debug = 0; %DEBUG_MODE = 1, Actual_experiment = 0
% pe = pyenv;
% if pe.Status == "Loaded"
%     break
% else
%     pe = pyenv;
% end

% 2. counterbalance version ____________________________________________________
% random sequence
r_seq =  [1,3,2,3,5,1,2,4,4,5];
index = rem(sub_num,10);
c1 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
c2 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
p1 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
p2 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
v1 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
v2 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];

% 2. counterbalance version ____________________________________________________

% 3. block order _______________________________________________________________
% latinsquare
% if sub-num divided by 5
% assign to latin square order

% code(sub, counterbalancefile, session#, blockorder)
bl_ind = rem(sub_num,6);
if session == 1
    switch bl_ind
        case 0 % p1 v1 c2 c1 v2 p2
            task1 = 'pain'; task2 = 'vicarious'; task3 = 'cognitive';
            task1_cb = p1; task2_cb = v1; task3_cb = c2;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             pain(sub,p1,1,1);vicarious(sub,v1,2,1);cognitive(sub,c2,3,1); %cognitive(sub,c1,4);vicarious(sub,v2,5);pain(sub,p2,6);
            
        case 1 % v1 c1 p1 p2 c2 v2
            task1 = 'vicarious'; task2 = 'cognitive';task3 = 'pain';
            task1_cb = v1; task2_cb = c1; task3_cb = p2;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             vicarious(sub,v1,1,1);cognitive(sub,c1,2,1);pain(sub,p1,3,1); %pain(sub,p2,4);cognitive(sub,c2,5);vicarious(sub,v2,6);
            
        case 2 % c1 p2 v1 v2 p1 c2
            task1 = 'cognitive'; task2 = 'pain'; task3 = 'vicarious';
            task1_cb = c1; task2_cb = p2; task3_cb = v1;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             cognitive(sub,c1,1,1);pain(sub,p2,2,1);vicarious(sub,v1,3,1); %vicarious(sub,v2,4);pain(sub,p1,5);cognitive(sub,c2,6);
            
        case 3 % p2 v2 c1 c2 v1 p1
            task1 = 'pain'; task2 = 'vicarious'; task3 = 'cognitive';
            task1_cb = p2; task2_cb = v2; task3_cb = c1;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             pain(sub,p2,1,1);vicarious(sub,v2,2,1);cognitive(sub,c1,3,1); %cognitive(sub,c2,4);vicarious(sub,v1,5);pain(sub,p1,6);
            
        case 4 % v2 c2 p2 p1 c1 v1
            task1 = 'vicarious'; task2 = 'cognitive'; task3 = 'pain';
            task1_cb = v2; task2_cb = c2; task3_cb = p2;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             vicarious(sub,v2,1,1);cognitive(sub,c2,2,1);pain(sub,p2,3,1); %pain(sub,p1,4);cognitive(sub,c1,5);vicarious(sub,v1,6);
            
        case 5 % c2 p1 v2 v1 p2 c1
            task1 = 'cognitive'; task2 = 'pain'; task3 = 'vicarious';
            task1_cb = c2; task2_cb = p1; task3_cb = v2;
            task1_order = 1; task2_order = 2; task3_order = 3;
            %             cognitive(sub,c2,1,1);pain(sub,p1,2,1);vicarious(sub,v2,3,1); %vicarious(sub,v1,4);pain(sub,p2,5);cognitive(sub,c1,6);
    end
elseif session ~= 1
    switch bl_ind
        case 0 % p1 v1 c2 c1 v2 p2
            task1 = 'cognitive'; task2 = 'vicarious'; task3 = 'pain';
            task1_cb = c1; task2_cb = v2; task3_cb = p2;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             cognitive(sub,c1,4,session);vicarious(sub,v2,5,session);pain(sub,p2,6,session);
            
        case 1 % v1 c1 p1 p2 c2 v2
            task1 = 'pain'; task2 = 'cognitive'; task3 = 'vicarious_copy';
            task1_cb = p2; task2_cb = c2; task3_cb = v2;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             pain(sub,p2,4,session);cognitive(sub,c2,5,session);vicarious(sub,v2,6,session);
            
        case 2 % c1 p2 v1 v2 p1 c2
            task1 = 'vicarious'; task2 = 'pain'; task3 = 'cognitive';
            task1_cb = v2; task2_cb = p1; task3_cb = c2;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             vicarious(sub,v2,4,session);pain(sub,p1,5,session);cognitive(sub,c2,6,session);
            
        case 3 % p2 v2 c1 c2 v1 p1
            task1 = 'cognitive'; task2 = 'vicarious'; task3 = 'pain';
            task1_cb = c2; task2_cb = v1; task3_cb = p1;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             cognitive(sub,c2,4,session);vicarious(sub,v1,5,session);pain(sub,p1,6,session);
            
        case 4 % v2 c2 p2 p1 c1 v1
            task1 = 'pain_test'; task2 = 'cognitive'; task3 = 'vicarious_copy';
            task1_cb = p1; task2_cb = c1; task3_cb = v1;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             pain(sub,p1,4,session);cognitive(sub,c1,5,session);vicarious(sub,v1,6,session);
            
        case 5 % c2 p1 v2 v1 p2 c1
            task1 = 'vicarious'; task2 = 'pain'; task3 = 'cognitive';
            task1_cb = v1; task2_cb = p2; task3_cb = c1;
            task1_order = 4; task2_order = 5; task3_order = 6;
            %             vicarious(sub,v1,4,session);pain(sub,p2,5,session);cognitive(sub,c1,6,session);
    end
end

line = strcat('Today, sub-', sprintf('%04d', sub_num) ,' will go through tasks:');
task1_line = strcat(' .    1)  ', task1 );
task2_line = strcat(' .    2)  ', task2 );
task3_line = strcat(' .    3)  ', task3 );
boxTop(1:length(line))='=';
fprintf('\n%s\n\n %s\n %s\n %s\n %s\n \n%s\n',boxTop,line,task1_line,task2_line,task3_line,boxTop)

% if ~exist('py_env')
% py_env = pyenv('ExecutionMode', 'InProcess');
% end
% B. Directories ______________________________________________________________
main_dir  = pwd;

run_task1 = strcat(task1,'(',num2str(sub_num),",'",char(task1_cb), "',",num2str(task1_order),',',num2str(session), ',',num2str(biopac),',',num2str(debug),')');
run_task2 = strcat(task2,'(',num2str(sub_num),",'",char(task2_cb), "',",num2str(task2_order),',',num2str(session), ',',num2str(biopac),',',num2str(debug),')');
run_task3 = strcat(task3,'(',num2str(sub_num),",'",char(task3_cb), "',",num2str(task3_order),',',num2str(session), ',',num2str(biopac),',',num2str(debug),')');

% prompt session number
prompt = 'run number (1 , 2 , 3): ';
run_num = input(prompt);

if run_num == 1
    eval(run_task1);
elseif run_num == 2
    eval(run_task2);
elseif run_num == 3
    eval(run_task3);
end