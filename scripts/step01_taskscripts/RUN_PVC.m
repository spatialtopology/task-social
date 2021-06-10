clear all;
Screen('Close');
clearvars;
sca;
% 1. grab participant number ___________________________________________________
prompt = 'SESSION (1, 3, 4): ';
ses_num = input(prompt);
prompt = 'PARTICIPANT (in raw number form, e.g. 1, 2,...,98): ';
sub_num = input(prompt);
prompt = 'BIOPAC (YES=1, NO=0) : ';
biopac = input(prompt);
fMRI = 1;
debug = 0;


% 2. counterbalance version ____________________________________________________
% random sequence30
task_dir                       = pwd;
main_dir                       = fileparts(fileparts(task_dir));
repo_dir                       = fileparts(fileparts(fileparts(task_dir)));
counterbalancefile           = fullfile(main_dir, 'design', 'latin_square_sequence.csv');
cb                     = readtable(counterbalancefile);
index = rem(sub_num,20);
if index == 0
    index = sub_num./20;
end
cb_ver_PV              = cb{index,'cb_ver'};
cb_ver_C               = cb{index,'cb_ver_C'};
latin                  = cb{index,{strcat('ses0', num2str(ses_num))}};

c1 = strcat('task-cognitive_counterbalance_ver-', sprintf('%02d',cb_ver_C),'_ses-',sprintf('%02d', ses_num), '_block-01');
c2 = strcat('task-cognitive_counterbalance_ver-' , sprintf('%02d',cb_ver_C),'_ses-',sprintf('%02d', ses_num),'_block-02');
p1 = strcat('task-pain_counterbalance_ver-' , sprintf('%02d',cb_ver_PV),'_ses-',sprintf('%02d', ses_num), '_block-01');
p2 = strcat('task-pain_counterbalance_ver-' , sprintf('%02d',cb_ver_PV),'_ses-',sprintf('%02d', ses_num), '_block-02');
v1 = strcat('task-vicarious_counterbalance_ver-' , sprintf('%02d',cb_ver_PV),'_ses-',sprintf('%02d', ses_num), '_block-01');
v2 = strcat('task-vicarious_counterbalance_ver-' , sprintf('%02d',cb_ver_PV),'_ses-',sprintf('%02d', ses_num), '_block-02');

% 2. counterbalance version ____________________________________________________

% 3. block order _______________________________________________________________
% latinsquare

switch latin
  case 1 % p1; v1; c2; c1; v2; p2 - A B F C E D
    task1 = 'pain'; task2 = 'vicarious'; task3 = 'cognitive'; task4 = 'cognitive'; task5 = 'vicarious'; task6 = 'pain';
    t1_cb = p1;  t2_cb = v1;  t3_cb = c2;  t4_cb = c1;  t5_cb = v2;  t6_cb = p2;
  case 2 % v1; c1; p1; p2; c2; v2 - B C A A' C' B'
    task1 = 'vicarious'; task2 = 'cognitive'; task3 = 'pain'; task4 = 'pain'; task5 = 'cognitive'; task6 = 'vicarious';
    t1_cb = v1;  t2_cb = c1;  t3_cb = p1;  t4_cb = p2;  t5_cb = c2;  t6_cb = v2;
  case 3 % c1; p2; v1; v2; p1; c2 - C A' B B' A C'
    task1 = 'cognitive'; task2 = 'pain'; task3 = 'vicarious'; task4 = 'vicarious'; task5 = 'pain'; task6 = 'cognitive';
    t1_cb = c1;  t2_cb = p2;  t3_cb = v1;  t4_cb = v2;  t5_cb = p1;  t6_cb = c2;
  case 4 % p2; v2; c1; c2; v1; p1 - D E C F B A
    task1 = 'vicarious'; task2 = 'pain'; task3 = 'cognitive'; task4 = 'pain'; task5 = 'vicarious'; task6 = 'cognitive';
    t1_cb = v2;  t2_cb = p2;  t3_cb = c1;  t4_cb = p1;  t5_cb = v1;  t6_cb = c2;
  case 5 % v2; c2; p2; p1; c1; v1 - E F D A C B
    task1 = 'cognitive'; task2 = 'vicarious'; task3 = 'pain'; task4 = 'vicarious'; task5 = 'cognitive'; task6 = 'pain';
    t1_cb = c2;  t2_cb = v2;  t3_cb = p2;  t4_cb = v1;  t5_cb = c1;  t6_cb = p1;
  case 6 % c2; p1; v2; v1; p2; c1 - F A E B D C
    task1 = 'pain'; task2 = 'cognitive'; task3 = 'vicarious'; task4 = 'cognitive'; task5 = 'pain'; task6 = 'vicarious';
    t1_cb = p2;  t2_cb = c2;  t3_cb = v2;  t4_cb = c1;  t5_cb = p1;  t6_cb = v1;
end


line = strcat('Today, sub-', sprintf('%04d', sub_num) ,' will go through tasks:');
task1_line = strcat(' .    1)  ', task1 );
task2_line = strcat(' .    2)  ', task2 );
task3_line = strcat(' .    3)  ', task3 );
task4_line = strcat(' .    4)  ', task4 );
task5_line = strcat(' .    5)  ', task5 );
task6_line = strcat(' .    6)  ', task6 );
boxTop(1:length(line))='=';
fprintf('\n%s\n\n %s\n %s\n %s\n %s\n %s\n %s\n %s\n \n%s\n',boxTop,line,task1_line,task2_line,task3_line,task4_line,task5_line,task6_line,boxTop)

% B. Directories ______________________________________________________________
main_dir  = pwd;

run_t1 = strcat(task1,'(',num2str(sub_num),",'",char(t1_cb), "',",num2str(1),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');
run_t2 = strcat(task2,'(',num2str(sub_num),",'",char(t2_cb), "',",num2str(2),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');
run_t3 = strcat(task3,'(',num2str(sub_num),",'",char(t3_cb), "',",num2str(3),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');
run_t4 = strcat(task4,'(',num2str(sub_num),",'",char(t4_cb), "',",num2str(4),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');
run_t5 = strcat(task5,'(',num2str(sub_num),",'",char(t5_cb), "',",num2str(5),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');
run_t6 = strcat(task6,'(',num2str(sub_num),",'",char(t6_cb), "',",num2str(6),',',num2str(ses_num), ',',num2str(biopac),',',num2str(debug),')');

% prompt session number
%%
%
%  PREFORMATTED
%  TEXT
%
prompt = 'RUN number (1, 2, 3, 4, 5, 6): ';
run_num = input(prompt);

% DOUBLE CHECK MSG ______________________________________________________________
task_dir                        = pwd;
main_dir                        = fileparts(fileparts(task_dir));
repo_dir                        = fileparts(fileparts(fileparts(task_dir)));

repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub_num)),...
    'task-social', strcat('ses-',sprintf('%02d', ses_num)));
bids_string                     = [strcat('sub-', sprintf('%04d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', ses_num)),...
    strcat('_task-*'),...
    strcat('_run-', sprintf('%02d', run_num))];
repoFileName = fullfile(repo_save_dir,[bids_string,'*_beh.csv' ]);

% 3. if so, "this run exists. Are you sure?" ___________________________________
if isempty(dir(repoFileName)) == 0
    RA_response = input(['\n\n---------------ATTENTION-----------\nThis file already exists in: ', repo_save_dir, '\nDo you want to overwrite?: (YES = 999; NO = 0): ']);
    if RA_response ~= 999 || isempty(RA_response) == 1
        error('Aborting!');
    end
end


% ______________________________________________________________



if run_num == 1
    eval(run_t1);eval(run_t2);eval(run_t3);eval(run_t4);eval(run_t5);eval(run_t6);
elseif run_num == 2
    eval(run_t2);eval(run_t3);eval(run_t4);eval(run_t5);eval(run_t6);
elseif run_num == 3
    eval(run_t3);eval(run_t4);eval(run_t5);eval(run_t6);
elseif run_num == 4
    eval(run_t4);eval(run_t5);eval(run_t6);
elseif run_num == 5
    eval(run_t5);eval(run_t6);
elseif run_num == 6
    eval(run_t6);
end
