% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Copyrighht (C) 2023 Martin Bicher - All Rights Reserved
% You may use, distribute and modify this code under the 
% terms of the MIT license.
% 
% You should have received a copy of the MIT license with
% this file. If not, please write to: 
% martin.bicher@tuwien.ac.at or visit 
% https://github.com/dwhGmbH/covid19_model_family/LICENSE.txt
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [S0,I0,Sv0,Iv0,R0,Pop] = calculate_x0(ageClasses,S0Raw,I0Raw,Sv0Raw,Iv0Raw,R0Raw)
%Computes the initial conditions of the PDE model by transforming age-class
%lists to density functions by cubic spline interpolation.
%   ageClasses   -> ([int]) vector containing the lower bounds of the
%   age classes used to specify the input data
%   S0Raw,I0Raw,Sv0Raw,Iv0Raw,R0Raw   -> ([double]) vectors with eqiuvalent
%   lengths as ageClasses containing the initial number of susceptible,
%   infectious,... individuals in the corresponding state in the
%   corresponding age-class

ages = 0.5+(0:100);
mx = ages(end)-0.5;

%cubic spline interpolant
mids = 0.5*(ageClasses(1:end)+[ageClasses(2:end);ages(end)]);
diffs = diff([ageClasses(1:end);ages(end)]);

S0Normed = S0Raw./diffs;
S0Data = interp1(mids,S0Normed,ages,'pchip');
S0Data(S0Data<0)=0;
if (sum(S0Data)>0)
    S0Data = S0Data/sum(S0Data)*sum(S0Raw);
end

I0Normed = I0Raw./diffs;
I0Data = interp1(mids,I0Normed,ages,'pchip');
I0Data(I0Data<0)=0;
if (sum(I0Data)>0)
    I0Data = I0Data/sum(I0Data)*sum(I0Raw);
end

Sv0Normed = Sv0Raw./diffs;
Sv0Data = interp1(mids,Sv0Normed,ages,'pchip');
Sv0Data(Sv0Data<0)=0;
if (sum(Sv0Data)>0)
    Sv0Data = Sv0Data/sum(Sv0Data)*sum(Sv0Raw);
end

Iv0Normed = Iv0Raw./diffs;
Iv0Data = interp1(mids,Iv0Normed,ages,'pchip');
Iv0Data(Iv0Data<0)=0;
if (sum(Iv0Data)>0)
    Iv0Data = Iv0Data/sum(Iv0Data)*sum(Iv0Raw);
end

R0Normed = R0Raw./diffs;
R0Data = interp1(mids,R0Normed,ages,'pchip');
R0Data(R0Data<0)=0;
if (sum(R0Data)>0)
    R0Data = R0Data/sum(R0Data)*sum(R0Raw);
end

I0 = @(x) fun(I0Data,x);
Sv0 = @(x) fun(Sv0Data,x);
Iv0 = @(x) fun(Iv0Data,x);
R0 = @(x) fun(R0Data,x);
S0 = @(x) fun(S0Data,x);

Pop = zeros(100,1);
for x = ages
    Pop(x+0.5) = fun(I0Data,x)+fun(Sv0Data,x)+fun(Iv0Data,x)+fun(R0Data,x)+fun(S0Data,x);
end

    function [y] = fun(data,x)
        %y = zeros(size(x));
        %y(x>0 & x<mx)=data(floor(x(x>0 & x<mx))+1);
        if x<=0 || x>=mx
            y = 0;
        else
            y = data(floor(x)+1);
        end
    end

end
