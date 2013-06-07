%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization[]
% you should set it to the correct value in your code
set = [];
for i = 1:length(F)
    set = [set, F(i).var];
end
n = max(set);
M = repmat(struct('var', [], 'card', [], 'val', []), n, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P, isMax);

if isMax == 0
    for i = 1:n
        temp = struct('var', [], 'card', [], 'val', []);
        for j = 1:length(P.cliqueList)
            if ismember(i, P.cliqueList(j).var)
                temp = P.cliqueList(j);
                break;
            end
        end
        temp = FactorMarginalization(temp, setdiff(temp.var, i));

        sum = 0;
        for j = 1:length(temp.val)
            sum = sum + temp.val(j);
        end
        for j = 1:length(temp.val)
            temp.val(j) = temp.val(j) / sum;
        end

        M(i) = temp;
    end
else
    for i = 1:n
        temp = struct('var', [], 'card', [], 'val', []);
        for j = 1:length(P.cliqueList)
            if ismember(i, P.cliqueList(j).var)
                temp = P.cliqueList(j);
                break;
            end
        end
        temp = FactorMaxMarginalization(temp, setdiff(temp.var, i));
        M(i) = temp;
    end
end