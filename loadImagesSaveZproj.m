% iterate over all ".lif" files in the imageFolder directory
% and do the Z-Projection on each slice of each image

% ASSUMPTIONS:
% o  Each file *should* start with the Dye name, otherwise the script will 
% not work.
% o  If something needs to be renamed in the series' name, the
% corresponding row should be added to uniqslicenames.csv file.

imageFolder = '/local/rvesna/Thesis/Code/images';
outputFolder = '/local/rvesna/Thesis/Code/zprojections';

Tbl = readtable('patients-all-dataset-input-new.csv', 'ReadVariableNames', true, 'delimiter', ',');
LifFiles = readtable('liffiles.csv', 'ReadVariableNames', true, 'delimiter', ',');

problems = fopen('problemsinzproj-neww.txt', 'w');
othernames = 1000;

for f = 1:length(LifFiles.FileName)
    
    file = LifFiles.FileName{f};
    file_id = LifFiles.ID(f);
    
    disp(file);
    
    completeFileName = sprintf('%s/%s', imageFolder, file);
    reader = bfGetReader(completeFileName);
    metadata = reader.getMetadataStore();
    
    % data = bfopen(completeFileName);
    
    % extract dye name from the first part of filename
    % the result would be 'bf1', 'cur', or 'fsb', each representing
    % 'BF188', 'Curcumin', and 'FSB'.
    dyename = lower(extractBefore(file, 4));
    
    % find the corresponding rows in the table about this image
    TblSeries = Tbl(strcmp(Tbl.Filename, file), :);
    
    %count the number of layers/series in an image
    % seriesCount = size(data, 1);
    seriesCount = reader.getSeriesCount();

    for i = 1:seriesCount
        fprintf('.');
        reader.setSeries(i-1);
        if reader.getImageCount() < 40
            continue;
        end
        
        % series = data{i, 1}; %ith slice
        % metadata = data{i, 2}; % metadata for the slice
        % digest = getMetadata(metadata.get('Image name'));
        
        digest = getMetadata(metadata.getImageName(i-1).toCharArray');
        
        if ~size(digest)    % a problematic series will have digest={}
            continue;
        end
                
        patientnumber = TblSeries(strcmp(TblSeries.PatientID, digest{1}), :).PatientNum;
        patientId = TblSeries(strcmp(TblSeries.PatientID, digest{1}), :).NewPatientID;
        
        if size(patientId,1) == 0
            fprintf(problems, '%s\t%s\n', metadata.getImageName(i-1).toCharArray', file);
            % fprintf(problems, '%s\t%s\n', metadata.get('Image name'), file.name);
            continue;
        end
        output_filename = sprintf('%d-PAT%s-DYE%s-series%d-file%d', patientnumber, patientId{1}, dyename, digest{2}, file_id);

        series_planeCount = 40; %size(series, 1); %number of planes (wavelengths)

        image_size = size(bfGetPlane(reader, 1));
        
        zproj_30 = zeros(image_size, 'uint8');
        zproj_1 = zeros(image_size, 'uint8');
        
        % For 16-bit images, we have to find the maximum intensity over all
        % wavelengths and set it as whitest pixel, and scale everything to
        % match that range.
        if isa(bfGetPlane(reader, 1), 'uint16')
            max_intensity = 0;
            for j = 1:series_planeCount
                max_intensity = max(max_intensity, max(max(bfGetPlane(reader, j))));
            end
            
            for j = 1:series_planeCount
                % because of integer overflow and division problems, we
                % need to cast everythig to doubles.
                I = uint8(double(bfGetPlane(reader, j)) * 255. / double(max_intensity));
                
                if j >= 30
                    zproj_30 = max(zproj_30, I);
                end
                zproj_1 = max(zproj_1, I);
            end

        else
            for j = 1:series_planeCount
                if j >= 30
                    zproj_30 = max(zproj_30, bfGetPlane(reader, j));
                end
                zproj_1 = max(zproj_1, bfGetPlane(reader, j));
            end
        end
        imwrite(zproj_1,  ...
                sprintf('%s/%s-zproj-1.png', outputFolder, output_filename));
        imwrite(zproj_30,  ...
                sprintf('%s/%s-zproj-30.png', outputFolder, output_filename));
    end
    reader.close();
    fprintf('\n');
    clear data 
end

fclose(problems);
