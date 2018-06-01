%% load all data

data = load('features-deg50-all-interpolated-500.mat');

features = data.data.features;
names = data.data.filenames;
agg_ids = data.data.agg_ids;

%% filter out FSB

I_fsb = regexpcell(names, '.*\-DYEfsb\-.*');

fsb_features = features(I_fsb, :);
fsb_names = names(I_fsb);
fsb_agg_ids = agg_ids(I_fsb);

data = struct();
data.features = fsb_features;
data.filenames = fsb_names;
data.agg_ids = fsb_agg_ids;

save('features-deg50-fsb-interpolated-500.mat', 'data');

%% filter out BF-188

I_bf1 = regexpcell(names, '.*\-DYEbf1\-.*');

bf1_features = features(I_bf1, :);
bf1_names = names(I_bf1);
bf1_agg_ids = agg_ids(I_bf1);

data = struct();
data.features = bf1_features;
data.filenames = bf1_names;
data.agg_ids = bf1_agg_ids;

save('features-deg50-bf1-interpolated-500.mat', 'data');

%% filter out Curc

I_cur = regexpcell(names, '.*\-DYEcur\-.*');
cur_features = features(I_cur, :);
cur_names = names(I_cur);
cur_agg_ids = agg_ids(I_cur);

data = struct();
data.features = cur_features;
data.filenames = cur_names;
data.agg_ids = cur_agg_ids;

save('features-deg50-cur-interpolated-500.mat', 'data');