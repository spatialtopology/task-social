clear all;
% 1. grab participant number ___________________________________________________
prompt = 'session number : ';
session = input(prompt);
prompt = 'subject number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt);



% 2. counterbalance version ____________________________________________________
% random sequence
r_seq =  [1,3,2,3,5,1,2,4,4,5];
index = rem(sub,10);
c1 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
c2 = ['task-cognitive_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
p1 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
p2 = ['task-pain_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];
v1 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-01'];
v2 = ['task-vicarious_counterbalance_ver-0' num2str(r_seq(index+1)) '_block-02'];

% 3. block order _______________________________________________________________
% latinsquare
% if sub-num divided by 5
% assign to latin square order

% code(sub, counterbalancefile, session#, blockorder)
bl_ind = rem(sub,6);
if session == 1
    switch bl_ind
        case 0 % p1 v1 c2 c1 v2 p2
            pain(sub,p1,1,1);vicarious(sub,v1,2,1);cognitive(sub,c2,3,1); %cognitive(sub,c1,4);vicarious(sub,v2,5);pain(sub,p2,6);
            
        case 1 % v1 c1 p1 p2 c2 v2
            vicarious(sub,v1,1,1);cognitive(sub,c1,2,1);pain(sub,p1,3,1); %pain(sub,p2,4);cognitive(sub,c2,5);vicarious(sub,v2,6);
            
        case 2 % c1 p2 v1 v2 p1 c2
            cognitive(sub,c1,1,1);pain(sub,p2,2,1);vicarious(sub,v1,3,1); %vicarious(sub,v2,4);pain(sub,p1,5);cognitive(sub,c2,6);
            
        case 3 % p2 v2 c1 c2 v1 p1
            pain(sub,p2,1,1);vicarious(sub,v2,2,1);cognitive(sub,c1,3,1); %cognitive(sub,c2,4);vicarious(sub,v1,5);pain(sub,p1,6);
            
        case 4 % v2 c2 p2 p1 c1 v1
            vicarious(sub,v2,1,1);cognitive(sub,c2,2,1);pain(sub,p2,3,1); %pain(sub,p1,4);cognitive(sub,c1,5);vicarious(sub,v1,6);
            
        case 5 % c2 p1 v2 v1 p2 c1
            cognitive(sub,c2,1,1);pain(sub,p1,2,1);vicarious(sub,v2,3,1); %vicarious(sub,v1,4);pain(sub,p2,5);cognitive(sub,c1,6);
    end
elseif session ~= 1
    switch bl_ind
        case 0 % p1 v1 c2 c1 v2 p2
            cognitive(sub,c1,4,session);vicarious(sub,v2,5,session);pain(sub,p2,6,session);
            
        case 1 % v1 c1 p1 p2 c2 v2
            pain(sub,p2,4,session);cognitive(sub,c2,5,session);vicarious(sub,v2,6,session);
            
        case 2 % c1 p2 v1 v2 p1 c2
            vicarious(sub,v2,4,session);pain(sub,p1,5,session);cognitive(sub,c2,6,session);
            
        case 3 % p2 v2 c1 c2 v1 p1
            cognitive(sub,c2,4,session);vicarious(sub,v1,5,session);pain(sub,p1,6,session);
            
        case 4 % v2 c2 p2 p1 c1 v1
            pain(sub,p1,4,session);cognitive(sub,c1,5,session);vicarious(sub,v1,6,session);
            
        case 5 % c2 p1 v2 v1 p2 c1
            vicarious(sub,v1,4,session);pain(sub,p2,5,session);cognitive(sub,c1,6,session);
    end
end


