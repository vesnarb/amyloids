%% load data

data = load('features-deg50-cur-selected-binary-interpol-100.mat');

features = data.data.features; 
features_abs = abs(features); %better use this for cosine

F = [real(features), imag(features)];

k = 3; %number of clusters
% [idx, C] = kMeansImplemented(F, k, 1, 1);
[idx, C, sumd] = kmeans(F, k);
% disp(sum(sumd)); 


%% reconstruct

deg = 50;
N = 512; 

f = figure;
p = uipanel('Parent',f,'BorderType','none');
p.Title = 'Kmeans Implemented - Euclidian';
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold';

for img = 1:k
    disp(img);
    subplot(2,3,img, 'Parent', p); 
    
    [~, I] = min(sum((F - repmat(C(img, :), size(F, 1), 1)) .^ 2, 2));
    recon = reconstructFast(deg, N, F(I(1), :));

%     recon = reconstructFast(deg, N, C(img, :)); %reconstruct the
%     centroids
    imshow(recon);
end

hold off;
