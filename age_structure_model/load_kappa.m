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

function [kappa] = load_kappa(filename)
%Loads the age-contact matrix in the given file and converts it to a
%contact kernel function
%   filename   -> (string) path to the file containing the age-contact
%   matrix

kappaMatrix = readtable(filename,'PreserveVariableNames', true);
kappaMatrix(:,1)=[]; %throw away index column
names = kappaMatrix.Properties.VariableNames;
lowers = [];
for n=names
    lowers(end+1)=str2double(n{1}(1:2));
end
ages = 0:100;
values = zeros(length(ages),length(ages));

%bring contact matrix on single age scale to speed up access
for i = 1:length(lowers)-1
    for j = 1:length(lowers)-1
        divisor = sum((ages<lowers(j+1))&(ages>=lowers(j))); %divide along columns s.t. sum over each row remains constant
        values((ages<lowers(i+1))&(ages>=lowers(i)),(ages<lowers(j+1))&(ages>=lowers(j))) = kappaMatrix.(names{j})(i)/divisor;
    end
    divisor = sum((ages>=lowers(end)));
    values((ages<lowers(i+1))&(ages>=lowers(i)),(ages>=lowers(end))) = kappaMatrix.(names{end})(i)/divisor;
end
for j = 1:length(lowers)-1
    divisor = sum((ages<lowers(j+1))&(ages>=lowers(j)));
    values((ages>=lowers(end)),(ages<lowers(j+1))&(ages>=lowers(j))) = kappaMatrix.(names{j})(end)/divisor;
end
divisor = sum((ages>=lowers(end)));
values((ages>=lowers(end)),(ages>=lowers(end))) = kappaMatrix.(names{end})(end)/divisor;

%add a zero-row and column   -  over 101 y.o. dont have contacts
values(end+1,:)=zeros(length(ages),1);
values(:,end+1)=zeros(1,length(ages)+1);

%make an executable function
mx = length(ages)+1;
kappa = @(a,b) values(min(mx,floor(a)+1),min(mx,floor(b)+1));

end