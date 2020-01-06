%% Fuzzy Systems 2019 - Group 2
% Giannis Manousaridis 8855
% Car Control Ser04

%% Clear
clear all;
close all;

%% Initializations

% Initial car's position and angle
x0 = 4.1 ;
y0 = 0.3 ; 
theta_init = [0 -45 -90]; 

u = 0.05; % constant speed

% Desired position
xd = 10 ;
yd = 3.2;

% Car control with the first controller
system = readfis('car4_first');
carControl4(x0,y0,theta_init,u,xd,yd,system);

% Car control with the improved controller
system = readfis('car4_best');
carControl4(x0,y0,theta_init,u,xd,yd,system);

