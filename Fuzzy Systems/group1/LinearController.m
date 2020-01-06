%% Fuzzy Systems 2019 - Group 1 : S7
% Giannis Manousaridis 8855
% Linear PI controller

%% Clear
clear all;
close all;

%% Begin
fprintf('\n *** begin %s ***\n',mfilename);

%% Open loop system - root locus

% Initialize Gc(s) = (s+c)/s 
num_c = [1 2];
den_c = [1 0];
g_c = tf(num_c, den_c)

% Initialize Gp(s) = 10/((s+1)*(s+9))
num_p = [10];
syms s;
den_p = sym2poly((s+1)*(s+9)); 
g_p = tf(num_p, den_p)

% Open loop system
sys_open_loop = series(g_c, g_p);

% Create the root locus plot
figure;
rlocus(sys_open_loop)


%% Closed Loop System
K = 0.8;
sys_open_loop = K * sys_open_loop; % We have chosen K
sys_closed_loop = feedback(sys_open_loop, 1, -1); % create the closed loop system

figure;
step(sys_closed_loop); % calculate the step response of the system

info = stepinfo(sys_closed_loop);

% check if rise time is okay 
if info.RiseTime > 1.2
    fprintf('\nRise Time is : %d. Try another value.',info.RiseTime);
else
    fprintf('\nRise Time is : %d. Value is good.',info.RiseTime);
end

% check if overshoot is okay
if info.Overshoot > 10
    fprintf('\nOvershoot is : %d. Try another value.',info.Overshoot);
else
   fprintf('\nOvershoot is : %d. Value is good.',info.Overshoot); 
end

fprintf('\n\n *** %s has finished ***\n\n',mfilename);

