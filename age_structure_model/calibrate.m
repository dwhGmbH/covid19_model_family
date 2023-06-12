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

function [] = calibrate(CONFIGFILE)
%Calibrates the transmissibility parameters of the simulation 
%by fitting the total active infectious cases given by the simulation to 
%the IValidation data in the given config file
%The found parameters are automatically written back into the config file 
%for direct use with age_sir_macro.m
%   CONFIGFILE   -> (string) path to the config file in JSON format

fid = fopen(CONFIGFILE);
raw = fread(fid,inf);
str = char(raw');
fclose(fid);
CONFIG = jsondecode(str);
SCENARIO = CONFIG.scenario;
CALIBINTERVAL = CONFIG.calibinterval;
T0 = datetime(CONFIG.t0);
TEND = datetime(CONFIG.tend);
DAYS = days(TEND-T0);
%{
if mod(DAYS,7)==0
    vec = 7:7:DAYS;
else
    vec = 7:7:DAYS+7;
end
%}
if mod(DAYS,CALIBINTERVAL)==0
    vec = CALIBINTERVAL:CALIBINTERVAL:DAYS;
else
    vec = CALIBINTERVAL:CALIBINTERVAL:DAYS+CALIBINTERVAL;
end

BETAS = zeros(size(vec));
hold on;
bisectiters = 10;
linecolors = jet(length(vec)*bisectiters);
for i = 1:length(vec)
    mx = 8;
    mn = 0;
    mxval = inf;
    mnval = -inf;
    for j=1:bisectiters
        filename = ['calibration/config_',num2str(i),'_',num2str(j),'.json'];
        BETAS(i)=0.5*(mx+mn);
        CONFIG.beta = BETAS;
        save_config(CONFIG,filename);
        diffs = age_sir_macro(filename,0);
        plot(diffs,'color',linecolors((i-1)*bisectiters+j,:));
        dff = sum(diffs(vec(i)-6:min(vec(i),length(diffs))));
        if dff<0
            mn = 0.5*(mx+mn);
            mnval = dff;
        else
            mx = 0.5*(mx+mn);
            mxval = dff;
        end
        disp(BETAS);
    end
end
CONFIG.beta = BETAS;
save_config(CONFIG,CONFIGFILE);
age_sir_macro(CONFIGFILE,1);
    function [] = save_config(CONFIG,CONFIGFILE)
        encoded = jsonencode(CONFIG,'PrettyPrint',true);
        fid=fopen(CONFIGFILE,'w');
        fprintf(fid, encoded);
        fclose(fid);
    end
end