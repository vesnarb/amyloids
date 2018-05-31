function [idx, centroids] = kMeansImplemented(X, k, simFunc, sigma)

% centroid(j, :) is the j-th centroid (1 <= j <= k)
% idx(i) is indicating which cluster the i-th datapoint belongs to
%       so idx(i) is a number between 1 and k
% simFunc: 1 = Euclidean
%          2 = Cosine
%          3 = Gaussian


n = size(X,1);
centroids = X(randperm(n,k), :);
max_iters = 10;

idx = zeros(1, n);
objective = zeros(max_iters, 1);
for T = 1:max_iters
    disp(T); 
    if simFunc == 1     % Euclidean
        similarities = -pdist2(X, centroids, 'squaredeuclidean');
    elseif simFunc == 2 % Cosine
        similarities = -pdist2(X, centroids, 'cosine');
    elseif simFunc == 3 % Gaussian
        similarities = exp(- pdist2(X, centroids, 'squaredeuclidean') / sigma^2);
    end
    
    [M, most_similar_cluster] = max(similarities, [], 2); %M: max value, most_similar_cluster: index of max
    idx = most_similar_cluster;
    
    objective(T) = sum(M);
    if T ~= max_iters
        for i = 1:k
            centroids(i, :) = mean(X(idx == i, :), 1);
        end
    end
end
figure;
plot(objective);
end

