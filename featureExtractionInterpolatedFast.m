aggrFolder = '/home/vesna/Thesis/Code/aggregates';
max_zernike_deg = 50;
image_size = 200;

files = dir(sprintf('%s/*.png', aggrFolder)); %for all agg in the folder - it takes forever

disp('Precomputing the Zernike Basis...');
tic
Rads = precomputeZernikeBasis(image_size, max_zernike_deg);
toc
disp('Done.');

features = [];
names = {};
agg_ids = [];

for fid = 1:size(files, 1)
    file = files(fid);
    [J, tok] = regexpi(file.name, '(.*)\-agg\-(\d+).png', 'match', 'tokens', 'once');
    if size(J)
	tic
        fprintf('[%% %.2f] Processing %s ...\n', 100. * (double(fid) / size(files, 1)), file.name);
        names{end+1} = tok{1,1};
        agg_ids = [agg_ids, str2num(tok{2})];
        
        aggregate = imread(sprintf('%s/%s', file.folder, file.name));
               
        %interpolate image
        aggregate = imresize (aggregate, [image_size, image_size], 'bilinear');
        im = im2double(aggregate);
        
        features = [features; zernikeUsingPrecomputed(Rads, im, max_zernike_deg)];
	toc
    end
end

data = struct;
data.features = features;
data.filenames = names;
data.agg_ids = agg_ids;

save(sprintf('features-deg%d-all-interpolated-%d.mat', max_zernike_deg, image_size), 'data');
