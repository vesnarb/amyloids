data = load('features-deg50-cur-interpolated-normalized-100.mat');
Tbl = readtable('patients-all-dataset-input-new.csv', 'ReadVariableNames', true, 'delimiter', ',');

features = abs(data.data.features); 
names = data.data.filenames; 
agg_ids = data.data.agg_ids; 

types = {'Sporadic', 'PSEN1 AD', 'PSEN2 AD', 'London AD', 'E3Q fAD', 'Swedish AD'};

patients_forEach_type = {};
for i=1:length(types)
  patients_forEach_type{i} = unique(Tbl(strcmp(Tbl.Classification, types{i}), :).PatientNum);
end

%% filter out features based on mutation
% In array 'keep', if an element is 1, it means you want to have that
% mutation and if it is 0, it means you don't want. E.g. the following
% means that you want all mutations except 'Sporadic' and 'Unknown'
keep = [0, 1, 1, 1, 1, 0];

J = [];
for i=1:length(types)
  if keep(i)
    for pat = patients_forEach_type{i}'
      J = [J, regexpcell(names, sprintf('^%d\\-', pat))];
    end
  end
end

features = features(J, :);
names = names(J);
agg_ids = agg_ids(J);

%%
F = [real(features), imag(features)];

k=2;
[idx,C] = kMeansImplemented(F, k, 2, .7); 

type_of_each_patient = zeros(100, 1, 'uint8');

for i = 2:5
  for j = patients_forEach_type{i}'
      type_of_each_patient(j) = i-1;
  end
end

M = zeros(k, 4);
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
for mut_type = 2:5
    I = patients_forEach_type{mut_type};
    disp(size(I));
    order = [order; I];
end

figure();
imagesc(Mpat(:, order));


disp(M);
figure;
imagesc(M);
