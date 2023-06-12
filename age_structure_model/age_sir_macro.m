% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Copyrighht (C) 2023 dwh GmbH - All Rights Reserved
% You may use, distribute and modify this code under the 
% terms of the MIT license.
% 
% You should have received a copy of the MIT license with
% this file. If not, please write to: 
% martin.bicher@dwh.at or visit 
% https://github.com/dwhGmbH/covid19_model_family/blob/main/LICENSE.txt
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [errsI] = age_sir_macro(CONFIGFILE,varargin)
%Calibrates the transmissibility parameters of the simulation 
%by fitting the total active infectious cases given by the simulation to 
%the IValidation data in the given config file
%   CONFIGFILE   -> (string) path to the config file in JSON format
%   varargin     -> optional (boolean) tells whether the simulation should
%   generate plots. Usually used by the calibration script to suppress it.

if length(varargin)>=1
    PLOT = varargin{1};
else
    PLOT = 1;
    set(0,'defaulttextinterpreter','latex')
    set(0,'DefaultTextFontname', 'CMU Serif')
    set(0,'DefaultAxesFontName', 'CMU Serif')
end

%% load config
%deserialize json
fid = fopen(CONFIGFILE);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
CONFIG = jsondecode(str);
SCENARIO = CONFIG.scenario;
SCENARIONAME = CONFIG.scenarioName;
T0 = datetime(CONFIG.t0);
TEND = datetime(CONFIG.tend);
CONTACTMATRIXFILE = CONFIG.contactMatrixFile;
AGECLASSES = CONFIG.ageClasses;
S0Raw = CONFIG.S0;
I0Raw = CONFIG.I0;
R0Raw = CONFIG.R0;
Sv0Raw = CONFIG.Sv0;
Iv0Raw = CONFIG.Iv0;
XI = CONFIG.xi;
BETAS = CONFIG.beta;
GAMMA = CONFIG.gamma;
IReal = CONFIG.IValidation;

CALIBINTERVAL = CONFIG.calibinterval;

%% calculate dependent variables
KAPPA = load_kappa(CONTACTMATRIXFILE);
DAYS = days(TEND-T0);

%% calculate startvalues
[S0,I0,Sv0,Iv0,R0,POP] = calculate_x0(AGECLASSES,S0Raw,I0Raw,Sv0Raw,Iv0Raw,R0Raw);
TOTPOP = sum(POP);

tic;

gamma=@(a) GAMMA;
beta=@(t,a) BETAS(floor(t/CALIBINTERVAL)+1);
kappa=@(a,b) KAPPA(a,b);
xi = XI;

%figure
%handles.axes1=gca;

N=101; %x-discretization steps
u0=@(x)[S0(x);Sv0(x);I0(x);Iv0(x);R0(x)]; %initial conditions
solver=1; %solver type
pl=0; %plot off
lbc=@(x)[0;0;0;0;0]; %left dirichlet boundary condition
rbc=@(x)[0;0;0;0;0]; %right dirichlet boundary condition
lb=0; %left boundary value
rb=100; %right boundary value

%integro term
kap = @(t,y,x,u) kappa(y,x).*(u(3)+u(4))/TOTPOP;
%RHS function
f2 = @(t,x,u,ux,uxx,kap)[
    -1/365*ux(1)-beta(t,x)*u(1)*kap;
    -1/365*ux(2)-beta(t,x)*u(2)*kap*(1-xi);
    -1/365*ux(3)-gamma(x)*u(3)+beta(t,x)*u(1)*kap;
    -1/365*ux(4)-gamma(x)*u(4)+beta(t,x)*u(2)*kap*(1-xi);
    -1/365*ux(5)+gamma(x)*(u(3)+u(4))
    ];

h=0; %stepsize for t (0=stepsizecontrol)

[Tsol,X,Usol,~,~] = DifferenceMethodInt1D(N,f2,kap,u0,[lb;rb],[1;1],{lbc;rbc},DAYS,h,solver); %solver

%make executable function out of output
ageFunSimINone = @(t,x)interp2(Tsol,X,Usol(:,:,3),t,x);
ageFunSimIVacc = @(t,x)interp2(Tsol,X,Usol(:,:,4),t,x);

ageFunSimIAll = @(t,x)ageFunSimINone(t,x)+ageFunSimIVacc(t,x);

errsI = calculate_errs_I(SCENARIO,T0,DAYS,POP,ageFunSimIAll,IReal);
if PLOT
    %%plot results
    %% Arrow Plot %%%%%%%%%
    make_combined_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimINone,ageFunSimIVacc,IReal);
    %% Arrow Plot %%%%%%%%%
    make_arrow_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal);
    %% Line Plot for Fit %%%%%%%%%
    make_line_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal);
    %% Surf Plot %%%%%%%%%
    make_surf_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal);
    %% Heatmap Plot %%%%%%%%%
    make_heatmap_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal);
    %% Age Averages %%%%%%%%%
    make_average_plot(SCENARIO,SCENARIONAME,T0,DAYS,POP,ageFunSimIAll,IReal);
end
end