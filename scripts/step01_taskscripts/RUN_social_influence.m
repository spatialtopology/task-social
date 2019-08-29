
% 1. grab participant number ___________________________________________________
prompt = 'subject number (in raw number form, e.g. 1, 2,...,98): ';
sub = input(prompt)



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
bl_ind = rem(sub,6);
switch bl_ind
  case 0 % p1 v1 c2 c1 v2 p2
    pain(p1);vicarious(v1);cognitive(c2);cognitive(c1);vicarious(v2);pain(p2);

  case 1 % v1 c1 p1 p2 c2 v2
    vicarious(v1);cognitive(c1);pain(p1);pain(p2);cognitive(c2);vicarious(v2);

  case 2 % c1 p2 v1 v2 p1 c2
    cognitive(sub,c1);pain(p2);vicarious(v1);vicarious(v2);pain(p1);cognitive(c2);

  case 3 % p2 v2 c1 c2 v1 p1
    pain(p2);vicarious(v2);cognitive(c1);cognitive(c2);vicarious(v1);pain(p1);

  case 4 % v2 c2 p2 p1 c1 v1
    vicarious(v2);cognitive(c2);pain(p2);pain(p1);cognitive(c1);vicarious(v1);

  case 5 % c2 p1 v2 v1 p2 c1
    cognitive(c2);pain(p1);vicarious(v2);vicarious(v1);pain(p2);cognitive(c1);
end