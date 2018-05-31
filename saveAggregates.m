zprojFolder = '/local/rvesna/Thesis/Code/zprojections';
outputFolder = '/local/rvesna/Thesis/Code/aggregates';

files = dir(sprintf('%s/*.png', zprojFolder));

% first we create a list of all images-series
all_images = {};

for file = files'
    [J, tok] = regexpi(file.name, '(.*)\-zproj\-(\d+).png', 'match', 'tokens', 'once');
    if size(J)
        if tok{2} == '1'    % save for each z-projection once
            all_images{end+1} = tok{1};
        end
    end
end

parfor i = 1:size(all_images, 2)
    fprintf('Loading %s ...\n', all_images{i});
    zproj_1 = imread(sprintf('%s/%s-zproj-1.png', zprojFolder, all_images{i}));
    zproj_30 = imread(sprintf('%s/%s-zproj-30.png', zprojFolder, all_images{i}));
    
    [aggregates, L] = segmentation(zproj_1, zproj_30);
    for j = 1:size(aggregates, 1)
        imwrite(aggregates{j, 1},  ...
                sprintf('%s/%s-agg-%d.png', outputFolder, all_images{i}, j));
    end
    imwrite(uint8(L), sprintf('%s/%s-labels.png', outputFolder, all_images{i}));
end

 