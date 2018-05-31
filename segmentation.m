function [aggregates, labels] = segmentation(zproj_1, zproj_30)
%segmentation gets two Z-projections as input (starting from 1 and starting
% from 30), and returns a list of aggregate images, saved in a cell.

% perform edge detection using Sobel filter
[~, threshold] = edge(zproj_30, 'sobel');
fudgeFactor = 1.0;
BWs = edge(zproj_30,'sobel', threshold * fudgeFactor);

% dilate the image to connect nearby edges
sedisk = strel('disk', 3);
BWsdil = imdilate(BWs, sedisk);

% fill inside holes (a hole is a set of background pixels that cannot
% be reached by filling in the background from the edge of the image.)
BWdfill = imfill(BWsdil, 'holes');

% remove small connected components (<1000 pixels area)
BWremsmall = bwareaopen(BWdfill, 1000, 8);

%TODO: maybe need to remove connected components based on the intensity.
% here we may lose small aggregates.

% Erode the image to the previous state (for smoothing)
seD = strel('disk',1);
BWfinal = imerode(BWremsmall,seD);

% Now we should merge nearby connected components. The idea is to close the
% image with a disk of size 10, then look at the labeling of the image, and
% merge two labels if they fall inside the same component in the closed
% image
BWmap = imclose(BWfinal, strel('disk', 10));
CC = bwconncomp(BWmap, 8);

L = bwlabel(BWfinal);
L = L * 100;    % the reason is for better performance

% merging connected components: (dilato os agg que estao proximos com 
% um lencol de valor 100. para cada pixel, eu comparo o valor (0 ou 1) com 100, 
% e escolho o menor numero)

for i = 1:CC.NumObjects
    L(CC.PixelIdxList{i}) = min(L(CC.PixelIdxList{i}), i);
end

% finding all the bounding boxes
BB = regionprops(L, 'BoundingBox');

aggregates = cell(size(BB, 1), 1);

for comp = 1:size(BB, 1)
    st = BB(comp);
    
    bbleft = int32(st.BoundingBox(1));
    bbtop = int32(st.BoundingBox(2));
    bbwid = int32(st.BoundingBox(3));
    bbhei = int32(st.BoundingBox(4));
    
    % diameter of the b.b.    
    D = ceil(sqrt(st.BoundingBox(3).^2 + st.BoundingBox(4).^2));  
    
    % if the diameter is odd, we should add 1 (because of numerical issues)
    if mod(D,2)==1
        D = D+1;
    end
    
    % create a masked image out of the aggregate
    % the reason for the following "nasty" line is that multiplication of
    % integral matrices and boolean matrices is not possible in MATLAB!
    masked_image = bsxfun(@times, zproj_1, cast((L == comp), 'like', zproj_1));
    
    % create a new image for storing the aggregate
    aggr_separate = zeros(D, D, 'uint8');   

    target_left = int32(ceil((D - bbwid) / 2));
    target_top = int32(ceil((D - bbhei) / 2));

    % copy the aggregate from masked image to the new image
    aggr_separate(target_top:target_top+bbhei-1, ...
                  target_left:target_left+bbwid-1) = ...
                  masked_image(bbtop:bbtop+bbhei-1, bbleft:bbleft+bbwid-1);
    % save
    aggregates{comp, 1} = aggr_separate;
end

% also return labels
labels = L;

end

