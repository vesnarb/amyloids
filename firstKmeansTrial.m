%% 1st option: Perform Kmeans on abs Zernike, do PCA and plot by clusters

%% load data

data = load('features-deg50-bf1-bin-adaptive-interpol-100.mat');

features = data.data.features; 
features_abs = abs(features); 

F = [real(features), imag(features)];

k = 3; %number of clusters

% [idx, C] = kMeansImplemented(features_abs, k, 2, 1); % cosine

[idx, C] = kMeansImplemented(F, k, 3, 1); % euclidean, gaussian

% [idx, C, sumd] = kmeans(F, k); %to compare with Matlabs built in 
% disp(sum(sumd)); 

%% plot the PCA by clusters 

[mappedX, mapping] = compute_mapping(features_abs, 'PCA', 676); %dont change
figure;
hold on;
scatter(mappedX(:,1), mappedX(:,2), 20, idx);
title('PCA colored by clusters (Gaussian K-means)')

%% reconstruct

deg = 50;
N = 512; 

f = figure;
p = uipanel('Parent',f,'BorderType','none');
p.Title = 'Kmeans Implemented - Gaussian';
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold';

for img = 1:k
    disp(img);
    subplot(2,3,img, 'Parent', p); 
    
    [~, I] = min(sum((F - repmat(C(img, :), size(F, 1), 1)) .^ 2, 2));%change here according to func
    recon = reconstructFast(deg, N, features(I(1), :)); %dont change this.

%     recon = reconstructFast(deg, N, C(img, :)); %reconstruct the
%     centroids
    imshow(recon);
end

hold off;


%% 2nd option - Perform PCA on abs Zernike and do Kmeans directly on PCA

%% load data

data = load('features-deg50-bf1-bin-adaptive-interpol-100.mat');

features = data.data.features; 
features_abs = abs(features); 

F = [real(features), imag(features)];

[mappedX, mapping] = compute_mapping(features_abs, 'PCA', 2);


k=3;

[idx, C] = kMeansImplemented(mappedX, k, 3, 1); %gaussian kmeans on pca

%% plot by clusters

figure;
hold on;
scatter(mappedX(:,1), mappedX(:,2), 20, idx);
scatter(C(:,1), C(:,2), 100, 'filled');
title('PCA colored by clusters (Gaussian K-means)')

%% reconstruct points closest to centroids

deg = 50;
N = 512; 

f = figure;
p = uipanel('Parent',f,'BorderType','none');
p.Title = 'Kmeans Implemented - Gaussian';
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold';

for img = 1:k
    disp(img);
    subplot(2,3,img, 'Parent', p); 
    
    [~, I] = min(sum((mappedX - repmat(C(img, :), size(mappedX, 1), 1)) .^ 2, 2));%change here according to func
    recon = reconstructFast(deg, N, features(I(1), :)); %dont change this.

%     recon = reconstructFast(deg, N, C(img, :)); %reconstruct the
%     centroids
    imshow(recon);
end

hold off;


