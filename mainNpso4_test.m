%tbest����:�ٷֱ�
%��ʾqlearningѰ·����
function mainNpso4_test()
clc;
clear all;
cla;

%% ��ʾ����
colorshape_real = 'bd';
color_real = 'b';
colorshape_p1 = 'm*';
color_lbest = [0.25, 0.5, 0.8];
colorshape_resampling = 'y*';
color_list_c  = rand(500, 3);
markersize = 4;
markersize2 = 3;
pause_time = 0.3;
format long g
color_test  = [0.9,0.9,0.9];
% ���ص�ͼ
load Map50_2.mat G;
MM=size(G,1);%�������������������Σ�
d=2;%ά��
grid on 
set(gca,'Layer','top');
figure(1) 
axis([0,MM,0,MM]) 
W = 0; color_W = 'k'; % ռ��դ����-��ɫ����ռ��
F = 0; color_F = 'w'; % ����դ����-��ɫ�������
N = 0;
wall_spot = [];
free_spot = [];
P_Opos = [];
test_free_spot = [];
% ��ͼ
for i=1:MM
    for j=1:MM
        if G(i,j) == 1 %��ɫ����ռ��
            wall_spot = [wall_spot; i j];%ռ�������¼
            SetColor([i j], color_W, G); 
            hold on
        else %��ɫ�������
            P_Opos = [P_Opos; i j]; %���ӳ�ʼ��
            free_spot = [free_spot; i j]; %���������¼
            SetColor([i j], color_F, G); 
            hold on
        end 
    end 
end 
pause(0.1);
W = size(wall_spot, 1);
F = size(free_spot, 1);
N = size(P_Opos, 1);


%% Step1 ��ʼ��
ElRw =100;
mean_dFRw=0.1;
dFVw=100;
des_R=2;

w = 0.89; % ����Ȩ��
c_1 = 0.3;% ����ѧϰ����
c_2 = 0.7;% Ⱥ��ѧϰ���� 
v = rand(N, d);% ��ʼ��Ⱥ���ٶ�
vlimit = [-1.5, 1.5; -1.5, 1.5];% �����ٶ�����
xlimit = [0.51, MM-0.51; 0.51, MM-0.51];
fitness_T = 0.05;
L_best_threshold = 0.03;% ��Ϊ�������ŵ������ֵ

ger_ql = 100;
alpha = 0.3; %ѧϰ��
gamma = 0.4; %�ۿ�����
epsilon_greed = 0.01;
fitness_var_threshold = 0.05;

rp_time = 20;%
free_spot_N = size(free_spot,1);

load Qtable_pso4.mat Qtable;

% P_pos_real = [2 2];
% Qtable=[];
% state = GetScanResult(G, P_pos_real);
% Qtable = [Qtable; state zeros(1, 8)];

ElRg = [];
mean_dFRg = [];
dFVg =[];
real_fitness = 1;
ger1 = 100;% ��ʼλ��Ԥ��pso��������

for rpE = 1:rp_time
for stateE = 1 :10:free_spot_N
P_pos_real = free_spot(stateE,:);
state = GetScanResult(G, P_pos_real);
[st_exist, st_index] = ismember(state, Qtable(:, 1:8), 'rows');

if ~st_exist
    Qtable = [state zeros(1, 8); Qtable];
    st_index = 1;
end
P_pos = P_Opos;
P_fitness = -inf(N, 1);% ���嵱ǰ��Ӧ��
P_best_pos = P_pos;% ��������λ��
P_best_fitness = -inf(N, 1);% ����������Ӧ��

L_best_num = 0;% �������Ÿ���
L_best_pos = zeros(N, d);% ��������λ��
P_min_distance = ones(N,1)*MM;
Top_best_pos = [];
L_best_threshold = 0.02;% ��Ϊ�������ŵ������ֵ
%% pso

for iter1 = 1 : ger1
    % ��ȡ��Ӧ��
    for i = 1:N
        P_scan_result = GetScanResult(G, P_pos(i,:));
        P_fitness(i) =  CalFitness(state, P_scan_result);
    end
    % ���������Ӧ��
    for i = 1:N
        if P_best_fitness(i) < P_fitness(i)
            P_best_fitness(i) = P_fitness(i); % ���¸�����ʷ�����Ӧ��
            P_best_pos(i,:) = P_pos(i,:);% ���¸�����ʷ���λ��
        end 
    end
    
%     [Pb_s,Tb_i]=sort(P_best_fitness(:));
%     L_best_num=round(N*0.1);
%     Top_best_pos=P_best_pos(Tb_i(end-L_best_num+1:end),:);
    
% 
%     
    if mod(iter1, 10) == 0 || iter1 == 1
        % ��ȡ�������Ž�
        
        for i = 1:N
            if abs(P_best_fitness(i) - real_fitness) < L_best_threshold
                L_best_num = L_best_num + 1;
                Top_best_pos(L_best_num, :) = P_best_pos(i, :);
            end
        end
        L_best_threshold = L_best_threshold / 5;
    end
    
    % ƥ���������Ž�
    for i = 1:N
        for j = 1:L_best_num
                pdistance = ODistance(P_pos(i,:),Top_best_pos(j,:));
                if pdistance < P_min_distance(i)
                    L_best_pos(i,:) = Top_best_pos(j,:);
                    P_min_distance(i) = pdistance;
                end
        end
    end
    
    % �����ٶ�
    v = v * w + c_1 * rand *(P_best_pos - P_pos) + c_2 * rand *(L_best_pos - P_pos);
    v = edgeLimit(v, vlimit, d);% �߽�λ�ô���
    

    % ����λ��
    P_pos_N = P_pos + v;
    P_pos_N = edgeLimit(P_pos_N, xlimit, d);% �߽�λ�ô���
    P_pos = P_pos_N;
% %     ���ϴ���1
%     P_pos_N_R = round(P_pos_N);    
%     for i = 1:N 
%         if G(P_pos_N_R(i,1),P_pos_N_R(i,2)) == 0
%             P_pos(i,:) = P_pos_N(i,:);
%         else
%             P_pos(i,:) = P_pos(i,:);
%         end
%     end
    
    %��ʾ
    if mod(iter1, 10) == 0 || iter1 == 1 || iter1==ger1
    pos = GetPos(P_pos, MM);
    p1 = plot(pos(1,:), pos(2,:),colorshape_p1,'markersize',markersize);
    pos_Top = GetPos(Top_best_pos, MM);
    p3 = plot(pos_Top(1,:), pos_Top(2,:),'d','Color',color_lbest,'MarkerFaceColor',color_lbest,'markersize',markersize2);
    pos_R = GetPos(P_pos_real, MM);
    pr = plot(pos_R(1,:), pos_R(2,:),colorshape_real,'MarkerFaceColor',color_real);
    
    pause(pause_time);
    delete(p1);
    delete(p3);
    delete(pr);
    end
    %��������
end


%% Step3 �ز���
min_distance_threshold = 2;
for i = 1:N
    if P_min_distance(i) > min_distance_threshold
        P_pos(i,:) = L_best_pos(i,:);
        P_best_pos(i,:) = P_pos(i,:);
        P_scan_result = GetScanResult(G, P_pos(i,:));
        P_fitness(i) =  CalFitness(state, P_scan_result);
        P_best_fitness(i) = P_fitness(i);
    end
end


% ��ʾ
pos = GetPos(P_pos, MM);
p1 = plot(pos(1,:), pos(2,:),colorshape_resampling,'markersize',markersize);
pos_Top = GetPos(Top_best_pos, MM);
p3 = plot(pos_Top(1,:), pos_Top(2,:),'d','Color',color_lbest,'MarkerFaceColor',color_lbest,'markersize',markersize2);
pos_R = GetPos(P_pos_real, MM);
pr = plot(pos_R(1,:), pos_R(2,:),colorshape_real,'MarkerFaceColor',color_real);
pause(pause_time);
delete(p1);
delete(p3);
delete(pr);
%% DBSCAN
epsilon = 0.5;
min_points = 50;

visited=false(N,1);
isnoise=false(N,1);
noises_id = 0;
subswarm_N = 0;
P_subswarm_id = zeros(N,1);
cluster_distance = pdist2(P_pos, P_pos);

for i = 1:N
    if ~visited(i)
        visited(i) = true;
        neighbors=RegionQuery(i,cluster_distance,epsilon);
        if numel(neighbors)<min_points
            % X(i,:) is NOISE
            isnoise(i)=true;
            noises_id =noises_id + 1;
            noises(noises_id) = i;
        else
            subswarm_N = subswarm_N + 1;
            s_P_N = 1;
            subswarms(subswarm_N, s_P_N) = i;
            s_P_N = s_P_N + 1;
            P_subswarm_id(i) = subswarm_N;
            k = 1;
            while true
                j = neighbors(k);
                if ~visited(j)
                    visited(j)=true;
                    neighbors2=RegionQuery(j,cluster_distance,epsilon);
                    num_neighbors2 = numel(neighbors2);
                    if num_neighbors2>=min_points
                        neighbors=[neighbors neighbors2];   %#ok
                    end
                end
                if P_subswarm_id(j) == 0
                    P_subswarm_id(j) = subswarm_N;
                    subswarms(subswarm_N, s_P_N) = j;
                    s_P_N = s_P_N + 1;
                end
                k = k + 1;
                if k > numel(neighbors)
                    break;
                end
            end
        end
    end    
end

for i = 1 : noises_id
    rand_1 = randi([1,subswarm_N],1);
    subswarm_current = subswarms(rand_1,:);    
    subswarm_current(subswarm_current==0)=[];
    s_N = size(subswarm_current,2);
    I_copy =  randi([1,s_N],1);
    I = noises(i);
    P_pos(I,:) = P_pos(I_copy,:);
    P_best_pos(I,:) = P_best_pos(I_copy,:);
    P_fitness(I) =  P_fitness(I_copy);
    P_best_fitness(I) = P_fitness(I_copy);
end

subswarm_N
potential_pos = zeros(subswarm_N,2);
for i = 1 : subswarm_N
    subswarm_current = subswarms(i,:);
    subswarm_current(subswarm_current==0)=[];
    s_P_pos = P_pos(subswarm_current,:);
    potential_pos (i,:)= mean(s_P_pos); %Ǳ��λ̬
    % ��ʾ
    pos = GetPos(s_P_pos, MM);
    p2(i) = plot(pos(1,:), pos(2,:),'*','Color',color_list_c(i,:),'markersize',markersize);    
    pos_pp = GetPos(potential_pos, MM);
    p_pp(i) = plot(pos_pp(1,i),pos_pp(2,i),'d','Color',color_list_c(i,:),'MarkerFaceColor',color_list_c(i,:));
end
pos_R = GetPos(P_pos_real, MM);
pr = plot(pos_R(1,:), pos_R(2,:),colorshape_real,'MarkerFaceColor',color_real);
delete(p2);
pause(pause_time*5);
delete(p_pp);
delete(pr);

el_potential_pos = [];
potential_pos_N = size(potential_pos,1);
potential_pos_R = round(potential_pos);
for i = 1:potential_pos_N
    if G(potential_pos_R(i,1),potential_pos_R(i,2)) == 1
        el_potential_pos = [el_potential_pos i];
    end
end
potential_pos(el_potential_pos , :) =[];
potential_pos_N = size(potential_pos,1);
potential_pos_fitness = zeros(1,potential_pos_N);
for i = 1:potential_pos_N
    P_scan_result = GetScanResult(G, potential_pos(i, :));
    potential_pos_fitness(i)= CalFitness(state, P_scan_result);
end

%% qlearning
%qlearning����

%��ʼ��
p_line = [];
%ql
for ter_ql = 1 : ger_ql 
    possible_action = [];
    possible_q = [];

    for i = 1:8
        if state(i) > 0
            possible_action = [possible_action i];
            possible_q = [possible_q Qtable(st_index, 8 + i)];
        end
    end
%             possible_action
    % ѡaction

    if rand < epsilon_greed
        action = randsrc(1,1, find(state == max(state)));
    else
        action = randsrc(1,1, find(state == max(state(possible_action(possible_q == max(possible_q))))));
    end
%         PrintMove (action);


    %ת��state-�ƶ�
    last_P_pos_real = P_pos_real;
    P_pos_real = Move(P_pos_real, action);
    potential_pos = Move(potential_pos, action);
    potential_pos = edgeLimit(potential_pos, xlimit, d); % �߽�λ�ô���


    delete(pr);
    delete(p_pp);
    pos_RL = GetPos(last_P_pos_real,MM);
    pos_R = GetPos(P_pos_real, MM);
    pr = plot(pos_R(1, :), pos_R(2, :), colorshape_real);
    p_line = [p_line plot([pos_R(1, :) pos_RL(1, :)], [pos_R(2, :) pos_RL(2, :)], 'r-')];
    pos_pp = GetPos(potential_pos, MM);
    for i = 1:potential_pos_N
        p_pp(i) = plot(pos_pp(1, i), pos_pp(2, i), 'o', 'Color', color_list_c(i, :), 'MarkerFaceColor', color_list_c(i, :),'markersize',4);
    end
    pause(pause_time);
%             
    %��Q��������/���ҵ�ǰstate
    last_st_index = st_index; %��¼��һstate��Q���λ��(����)
    state = GetScanResult(G, P_pos_real);
    [st_exist, st_index] = ismember(state, Qtable(:, 1:8), 'rows');
    if ~st_exist
        Qtable = [state zeros(1, 8); Qtable];
        st_index = 1;
    end

    % calculate reward
    potential_pos_fitness_new = zeros(1, potential_pos_N);
    for i = 1:potential_pos_N
        P_scan_result = GetScanResult(G, potential_pos(i, :));
        potential_pos_fitness_new(i) = CalFitness(state, P_scan_result);
    end
    fitness_var = (potential_pos_fitness - potential_pos_fitness_new);%fitness�仯��

    eliminate_potential_pos = [];
    eliminate_potential_pos = potential_pos(fitness_var >= fitness_var_threshold,:); %����̭Ǳ��λ̬
    eliminate_potential_pos_N = size(eliminate_potential_pos,1); %����̭Ǳ��λ̬����
    dFR = fitness_var(fitness_var >= fitness_var_threshold);
    ElR = eliminate_potential_pos_N / potential_pos_N;% reward��ʽ
    if numel(dFR) == 0
        sum_dFR = 0;
        dFV =  0;
    else
%                 mean_dFR = mean(dFR) / fitness_var_threshold;
        sum_dFR = sum(dFR/ fitness_var_threshold);
        dFV =  var(dFR);
    end
    reward = ElRw*ElR+ mean_dFRw*sum_dFR - dFVw*dFV;
    if eliminate_potential_pos_N == 0
        reward = -des_R;
    end
    if ElR~=0
        ElRg = [ElRg ElR];
    end
    if sum_dFR ~=0
        mean_dFRg = [mean_dFRg sum_dFR];
    end
    if dFV ~=0
        dFVg = [dFVg dFV];
    end

    % update Qvalue
    last_Qvalue = Qtable(last_st_index, 8 + action);

    update_Qvalue = (1 - alpha) * last_Qvalue + alpha * (reward + gamma * max(Qtable(st_index, [9, 16])));

    Qtable(last_st_index, 8 + action) = update_Qvalue;

    % fresh potential_pos
    potential_pos = potential_pos(fitness_var < fitness_var_threshold,:);
    potential_pos_N = size(potential_pos,1);
    potential_pos_fitness = zeros(1, potential_pos_N);
    for i = 1:potential_pos_N
        P_scan_result = GetScanResult(G, potential_pos(i, :));
        potential_pos_fitness(i) = CalFitness(state, P_scan_result);
    end

     if potential_pos_N <= 1
        disp('location success')
%         ter_ql
        delete(p_pp);
        for i = 1:potential_pos_N
            p_pp(i) = plot(pos_pp(1, i), pos_pp(2, i), 'o', 'Color', color_list_c(i, :), 'MarkerFaceColor', color_list_c(i, :),'markersize',4);
        end
        break;
     end
    
end
delete(pr);
delete(p_pp);
delete(p_line);
end
rpE
end

% save Qtable_pso1.mat Qtable

disp('end');
