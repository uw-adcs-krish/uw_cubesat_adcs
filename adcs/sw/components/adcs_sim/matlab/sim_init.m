% ----------------------------------------------------------------------- %
% UW HuskySat-1, ADCS Team
%
% Initializes all simulation parameters for 'adcs_sim_main.slx'. This is
% the first (and only) file that needs to be called/run to do a full
% simulation. Make sure you cd is the same folder where sim_init is found
% before you run this.
%
%   Last Edited: T. Reynolds  9.23.17
% ----------------------------------------------------------------------- %

% Start fresh
clear variables; close all; clc
addpath(genpath(pwd))
addpath(genpath('../../adcs_fsw/matlab/'))
addpath(genpath('../../adcs_bdot/matlab/'))

% Load bus stub definitions
load('bus_definitions.mat')

% Load parameters for both flight software and simulation
fsw_params = init_fsw_params();
[sim_params,fsw_params] = init_sim_params(fsw_params);
fsw_params.bdot     = init_bdot_controller(fsw_params);

fsw_params.bus.quat_commanded = [1;0;0;0];

% Load sim
run_time    = '10';
mdl         = 'adcs_sim_main';
load_system(mdl);
set_param(mdl,'StopTime', run_time);

% Simulation
sim(mdl);

plot_results


