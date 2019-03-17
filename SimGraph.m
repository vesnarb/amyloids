function W = SimGraph(M, k, Type, sigma)
%   Returns adjacency matrix for a k-Nearest Neighbors 
%   similarity graph
%
%   'M' - A d-by-n matrix containing n d-dimensional data points
%   'k' - Number of neighbors
%   'Type' - Type if kNN Graph
%      1 - Normal: we connect nodes Vi and Vj with an undericted edge if Vi
%      is among the k-nearest neighbors of Vj OR if Vj is among the
%      k-nearest neighbours of Vi.
%      2 - Mutual: we connect nodes Vi and Vj if BOTH Vi and Vi are among
%      the k-nearest neighbors of each other.
%   'sigma' - Parameter for Gaussian similarity function. Set
%      this to 0 for an unweighted graph. Default is 1.


n = size(M, 2); %number of aggregates

% define indeces
indi = zeros(1, k * n);
indj = zeros(1, k * n);
inds = zeros(1, k * n);

for j = 1:n
    % Compute the distance from each aggregate to the others
%     dist = distEuclidean(repmat(M(:, j), 1, n), M);
%     distEuclidean = sqrt(sum((M - N) .^ 2, 1));
    dist = sqrt(sum((repmat(M(:, j), 1, n) -  M).^ 2, 1));
    
    % Sort the distances in ascending order, and get the indeces I of
    % previous order
    [s, I] = sort(dist, 'ascend');
    
    % Save indices and value of the k 
    indi(1, (j-1)*k+1:j*k) = j;
    indj(1, (j-1)*k+1:j*k) = I(1:k);
    inds(1, (j-1)*k+1:j*k) = s(1:k);
end

% Create sparse matrix
W = sparse(indi, indj, inds, n, n);

clear indi indj inds dist s O;

% Construct a normal or mutual graph
if Type == 1
    % Normal (connect nodes if 1 node is neighbor from another)
    W = max(W, W');
else
    % Mutual (only cnnect nodes if both nodes are neighbor from each other)
    W = min(W, W');
end

if nargin < 4 || isempty(sigma) %if number of arg is less than 4, default sigma is 1.
    sigma = 1;
end

% Unweighted graph (for sigma =0)
if sigma == 0
    W = (W ~= 0); %does not change adjacency matrix
    
% Gaussian similarity function
elseif isnumeric(sigma)
    W = spfun(@(W) (exp(-W.^2 ./ (2*sigma^2))), W);

end

end