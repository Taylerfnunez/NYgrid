%% ModifyMPC
% Read the original NPCC 140-bus MATPOWER case file, modify the bus and
% branch matrices, and write the updated MATPOWER case file.

% Notes:
%%%% Consider reading the interface limits from a external file
%%%% Why do you only set rate A-C for the NE lines?

% Author: Vivienne Liu
% Last modified: July 28, 2021

close all;
clear all;
clc;

%% Load the original MATPOWER case
% Load original NPCC-140 bus MATPOWER case
mpc = loadcase('Data/npcc.mat');

% Add MATPOWER constant parameter names
define_constants;

%% Modify MATPOWER case
%% Bus modification
% fix negative load
mpc.bus(:,PD) = abs(mpc.bus(:,PD));

% Update bus types
%PQ - PV
mpc.bus(mpc.bus(:,BUS_I) == 39,BUS_TYPE) = PV;
mpc.bus(mpc.bus(:,BUS_I) == 77,BUS_TYPE) = PV;
mpc.bus(mpc.bus(:,BUS_I) == 45,BUS_TYPE) = PV;
mpc.bus(mpc.bus(:,BUS_I) == 62,BUS_TYPE) = PV;

%PV -PQ
mpc.bus(mpc.bus(:,BUS_I) == 72,BUS_TYPE) = PQ;
mpc.bus(mpc.bus(:,BUS_I) == 53,BUS_TYPE) = PQ;
mpc.bus(mpc.bus(:,BUS_I) == 54,BUS_TYPE) = PQ;
mpc.bus(mpc.bus(:,BUS_I) == 68,BUS_TYPE) = PQ;

%slack
mpc.bus(mpc.bus(:,BUS_I) == 78,BUS_TYPE) = PQ;
mpc.bus(mpc.bus(:,BUS_I) == 74,BUS_TYPE) = REF;

%% Branch modification
% delete transmission lines between PJM and IESO
mpc.branch((mpc.branch(:,F_BUS) == 84)&(mpc.branch(:,T_BUS)==116),:)=[];
mpc.branch((mpc.branch(:,F_BUS) == 87)&(mpc.branch(:,T_BUS)==115),:)=[];
mpc.branch((mpc.branch(:,F_BUS) == 90)&(mpc.branch(:,T_BUS)==114),:)=[];

% Update branch limit external
% PJM 124-75, 125-81, 134-66, 138-67
mpc.branch((mpc.branch(:,F_BUS) == 66)&(mpc.branch(:,T_BUS)==134),RATE_A) = 315;
mpc.branch((mpc.branch(:,F_BUS) == 67)&(mpc.branch(:,T_BUS)==138),RATE_A) = 660;
mpc.branch((mpc.branch(:,F_BUS) == 81)&(mpc.branch(:,T_BUS)==125),RATE_A) = 660;
mpc.branch((mpc.branch(:,F_BUS) == 75)&(mpc.branch(:,T_BUS)==124),RATE_A) = 2000;
mpc.branch((mpc.branch(:,F_BUS) == 60)&(mpc.branch(:,T_BUS)==140),RATE_A) = 550;

% NE 29-37 35-73
mpc.branch((mpc.branch(:,F_BUS) == 29)&(mpc.branch(:,T_BUS)==37),RATE_A:RATE_C) = 200;
mpc.branch((mpc.branch(:,F_BUS) == 35)&(mpc.branch(:,T_BUS)==73),RATE_A:RATE_C) = 1400;

% IESO 100-48 102-54 103-54
mpc.branch((mpc.branch(:,F_BUS) == 48)&(mpc.branch(:,T_BUS)==100),RATE_A) = 450;
mpc.branch((mpc.branch(:,F_BUS) == 54)&(mpc.branch(:,T_BUS)==102),RATE_A) = 650;
mpc.branch((mpc.branch(:,F_BUS) == 54)&(mpc.branch(:,T_BUS)==103),RATE_A) = 650;

% Add branch
% Add E-G 
newlineEG = [38 77 0.02 0.02 0 0 0 0 0 0 1 -360 360];
mpc.branch = [mpc.branch;newlineEG];

%% Save updated MATPOWER case
savecase('Result/mpcupdated.mat',mpc)