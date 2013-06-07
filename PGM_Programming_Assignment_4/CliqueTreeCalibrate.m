%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isMax == 0
    while 1
        [from, to] = GetNextCliques(P, MESSAGES);
        if from == 0 && to == 0
            break;
        end

        MESSAGES(from, to) = P.cliqueList(from);
        for k = 1:N
            if P.edges(k, from) == 1 && k ~= to
                MESSAGES(from, to) = FactorProduct(MESSAGES(from, to), MESSAGES(k, from));
            end
        end

        sepset = intersect(P.cliqueList(from).var, P.cliqueList(to).var);
        differ = setdiff(P.cliqueList(from).var, sepset);
        MESSAGES(from, to) = FactorMarginalization(MESSAGES(from, to), differ);

        sum = 0;
        for i = 1:length(MESSAGES(from, to).val)
            sum = sum + MESSAGES(from, to).val(i);
        end
        for i = 1:length(MESSAGES(from, to).val)
            MESSAGES(from, to).val(i) = MESSAGES(from, to).val(i) / sum;
        end
    end
else
    for i = 1:N
        P.cliqueList(i).val = log(P.cliqueList(i).val);
    end
    
    while 1
        [from, to] = GetNextCliques(P, MESSAGES);
        if from == 0 && to == 0
            break;
        end

        MESSAGES(from, to) = P.cliqueList(from);
        for k = 1:N
            if P.edges(k, from) == 1 && k ~= to
                MESSAGES(from, to) = FactorSum(MESSAGES(from, to), MESSAGES(k, from));
            end
        end

        sepset = intersect(P.cliqueList(from).var, P.cliqueList(to).var);
        differ = setdiff(P.cliqueList(from).var, sepset);
        MESSAGES(from, to) = FactorMaxMarginalization(MESSAGES(from, to), differ);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isMax == 0
    for i = 1:N
        for j = 1: N
            if P.edges(j, i) == 1
                P.cliqueList(i) = FactorProduct(P.cliqueList(i), MESSAGES(j, i));
            end
        end
    end
else
    for i = 1:N
        for j = 1: N
            if P.edges(j, i) == 1
                P.cliqueList(i) = FactorSum(P.cliqueList(i), MESSAGES(j, i));
            end
        end
    end
end

return
