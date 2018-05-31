%% reconstruct the aggregate 

main_image = im2double(imread('/Users/vesna/Documents/ETH/Thesis/Code/aggregates/6-PATBBN_9608-DYEcur-series117-file26-agg-2.png'));
max_aggregate_size = 726;
N = max_aggregate_size;

x = 1:N; y = x;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-N-1).^2+(2.*Y-N-1).^2)/N;    % distance of each pixel to center of image
R = (R<=1);

left = (max_aggregate_size - size(main_image, 1))/2;
right = left + size(main_image, 1) - 1;        
im = zeros(max_aggregate_size, max_aggregate_size, 'double');
im(left:right, left:right) = main_image;

Z = recursiveZernike(im, 100);

%% 9-pieces plot

f = figure;
p = uipanel('Parent',f,'BorderType','none');
p.Title = 'Image Reconstruction';
p.TitlePosition = 'centertop';
p.FontSize = 12;
p.FontWeight = 'bold';

for img = 1:8
    disp(img);
    subplot(3,3,img, 'Parent', p); 
    deg = 10 + 10 * img;
    recon = reconstructFast(deg, N, Z);
    imshow(recon);
    
    % finding the reconstruction error
    err = sum(sum((recon - im).^2)) / (N * N) * 4 / pi * 100;
%     title(sprintf('Degree %d (%% %.4f)', deg, err));
    title(sprintf('Degree %d ', deg));
end


subplot(3,3,9, 'Parent', p); 
imshow(im);
title('Original Image');


%% reconstruction error
err_rmse = [];
err_normalized = [];

x = 1:N; y = x;
[X,Y] = meshgrid(x,y);
R = sqrt((2.*X-N-1).^2+(2.*Y-N-1).^2)/N;    % distance of each pixel to center of image
mask = (R <= 1);

normalized_original = im / sqrt(sum(sum((mask .* im).^2)));

for deg=10:10:100
    disp(deg);
    reconstructed_image = reconstructFast(deg, N, Z);
    % finding the reconstruction error (i.e. ||f - f_tilde||)
    err_rmse = [err_rmse, sqrt(sum(sum((abs(mask .* (reconstructed_image - im)).^2))) * 4 / N^2)];
    normalized_recon = reconstructed_image / sqrt(sum(sum(abs(mask .* reconstructed_image).^2)));
    
    err_normalized = [err_normalized, sqrt(sum(sum((abs(mask .* (normalized_recon - normalized_original)) .^ 2))))];
%     imshow(ceil(reconstructed_image), [0, 255]);
%     max_pix_1 = max(max(im));
%     max_pix_2 = max(max(abs(reconstructed_image)));
%     imshow(abs(abs(reconstructed_image) - im), [0, 255]);
%     disp([max_pix_1, max_pix_2]c);
end

err_norm_frob =  err_rmse / sqrt(sum(sum((mask .* im).^2))) * N / 2;

%% comparison of intensities
figure; 
reconstructed_image = reconstructFast(100, N, Z);
imshow(reconstructed_image);

im_flat = im(:);
reconst_flat = reconstructed_image(:);

reconst_flat = reconst_flat(im_flat > 0);
im_flat = im_flat(im_flat > 0);

figure;
hold on;
hist([im_flat, reconst_flat], 50);
hold off;
legend('main image', 'reconstructed');
title('Comparison of instensities between reconstructed image and main image');

%% Plotting the errors
figure;
plot(10:10:100, err_rmse, '-o');
xlabel('Polynomial Degree');
ylabel('RMSE Error');

figure;
plot(10:10:100, err_norm_frob, '-o');
xlabel('Polynomial Degree');
ylabel('Frob. Norm of Error / Frob. Norm of Image');

figure;
plot(10:10:100, err_normalized * 100., '-o');
xlabel('Polynomial Degree');
ylabel('RMSE of normalized images (%)');

