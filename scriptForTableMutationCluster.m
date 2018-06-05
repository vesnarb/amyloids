% This script performs Kmeans on absolute Zernike moments and reconstruct
% the aggregates closest to each centroid. It also gives the table
% Mutation x Cluster and Patient x Cluster

dyes = {'bf1', 'cur', 'fsb', 'all'};
% dyes = {'cur'};
ks = [3, 4, 5]; %number of clusters
is_abs = true; %set to true to perform Kmeans on absolute value AND complex value

Tbl = readtable('patients-all-dataset-input-new.csv', 'ReadVariableNames', true, 'delimiter', ',');
types = {'Sporadic', 'PSEN1 AD', 'PSEN2 AD', 'London AD', 'E3Q fAD', 'Swedish AD'};

patients_forEach_type = {};
for i=1:length(types)
  patients_forEach_type{i} = unique(Tbl(strcmp(Tbl.Classification, types{i}), :).PatientNum);
end

type_of_each_patient = zeros(100, 1, 'uint8');
for i = 1:length(types)
  for j = patients_forEach_type{i}'
      type_of_each_patient(j) = i;
  end
end

keep = [0, 1, 1, 1, 1, 1];

for dye = dyes
    
    fprintf('Processing figures for dye %s\n', dye{1});
    data = load(sprintf('features-deg50-%s-bin-adaptive-interpol-100.mat', dye{1}));

    if is_abs
        features = abs(data.data.features); 
    else
        features = data.data.features;
    end
    features_complex = data.data.features;
    names = data.data.filenames; 
    agg_ids = data.data.agg_ids;
    
    J = [];
    for i=1:length(types)
      if keep(i)
        for pat = patients_forEach_type{i}'
          J = [J, regexpcell(names, sprintf('^%d\\-', pat))];
        end
      end
    end
    
    features = features(J, :);
    features_complex = features_complex(J, :);
    names = names(J);
    agg_ids = agg_ids(J);
    
    F = [real(features), imag(features)];
    
    for k = ks
        
        disp('Doing kmeans with k = ');
        disp(k);
        
        [idx,C] = kMeansImplemented(F, k, 3, 1);
%         [idx,C] = kmeans(F, k); %to check with Matlab bultin function
        
        deg = 50;
        N = 512; 

        f = figure;
        p = uipanel('Parent',f,'BorderType','none');
        if is_abs
            p.Title = sprintf('Kmeans (Gaussian) for dye %s (k=%d) [abs]', dye{1}, k);
        else
            p.Title = sprintf('Kmeans (Gaussian) for dye %s (k=%d)', dye{1}, k);
        end
        p.TitlePosition = 'centertop';
        p.FontSize = 12;
        p.FontWeight = 'bold';

        for img = 1:k
%             disp(img);
            subplot(2,3,img, 'Parent', p); 

            [~, I] = min(sum((F - repmat(C(img, :), size(F, 1), 1)) .^ 2, 2));%change here according to func
            disp(names{I(1)});
            recon = reconstructFast(deg, N, features_complex(I(1), :)); 

        %     recon = reconstructFast(deg, N, C(img, :)); %reconstruct the
        %     centroids
            imshow(recon);
        end

        hold off;
        if is_abs
            saveas(f, sprintf('clusters-%s-k%d-abs.png', dye{1}, k));
        else
            saveas(f, sprintf('clusters-%s-k%d.png', dye{1}, k));
        end
        
        M = zeros(k, 6);
        Mpat = zeros(k, 100);

        for i = 1:length(idx)
            [~, tok] = regexp(names{i}, '^(\d+)\-.*', 'match', 'tokens', 'once');
            pat_num = str2num(tok{1});
            M(idx(i), type_of_each_patient(pat_num)) = M(idx(i), type_of_each_patient(pat_num)) + 1;
            Mpat(idx(i), pat_num) = Mpat(idx(i), pat_num) + 1;
        end

        M = M ./ sum(M, 1);
        Mpat = Mpat ./ sum(Mpat, 1);

        order = [];
        for mut_type = 1:6
            if keep(mut_type)
                I = patients_forEach_type{mut_type};
                disp(size(I));
                order = [order; I];
            end
        end
        
        figure();
        imagesc(Mpat(:, order));
        if is_abs
            title(sprintf('Gaussian Kmeans for %s aggregates (k=%d) [abs]', dye{1}, k));
        else
            title(sprintf('Gaussian Kmeans for %s aggregates (k=%d)', dye{1}, k));
        end
        xlabel('Patients');
        ylabel('Clusters');
        h = colorbar;
        set(h, 'ylim', [0 1]);
        
        if is_abs
            saveas(gcf, sprintf('patients-cluster-dist-%s-k%d-abs.png', dye{1}, k));
        else
            saveas(gcf, sprintf('patients-cluster-dist-%s-k%d.png', dye{1}, k));
        end
        
        figure;
        disp(M(:, keep==1));
        imagesc(M(:, keep==1));
        h = colorbar;
        set(h, 'ylim', [0 1]);
        if is_abs
            title(sprintf('Gaussian Kmeans for %s aggregates (k=%d) [abs]', dye{1}, k));
        else
            title(sprintf('Gaussian Kmeans for %s aggregates (k=%d)', dye{1}, k));
        end
        xlabel('Mutation type');
        ylabel('Clusters');
        
        if is_abs
            saveas(gcf, sprintf('mutationtype-cluster-dist-%s-k%d-abs.png', dye{1}, k));
        else
            saveas(gcf, sprintf('mutationtype-cluster-dist-%s-k%d.png', dye{1}, k));
        end
    end
    
end
