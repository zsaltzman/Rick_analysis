READ_DATA_TYPE = lower(READ_DATA_TYPE);

files = dir(READ_DATA_PATH);

switch READ_DATA_TYPE
    case 'processed'
        if ~exist('READ_DATA_PROCESSED', 'var')
           fprintf('Reading processed data from %s\n', READ_DATA_PATH);
           READ_DATA_PROCESSED = readTableFromFolder(READ_DATA_PATH, FP_PROC_SUBSET);
        else
           fprintf('Processed data for this pipeline is already in memory, continuing...\n');
        end
    case 'raw'
        if ~exist('READ_DATA_RAW', 'var')
            fprintf('Reading raw data from %s\n', READ_DATA_PATH);
            READ_DATA_RAW = readTableFromFolder(READ_DATA_PATH, FP_PROC_SUBSET);
        else 
            fprintf('Raw data for this pipeline is already in memory, continuing...\n');
        end
end

% Reads .csv data from a folder with the following parameters: 
% folder - The full path of the folder to read from on disk. Globs for .csv
% subset - i.e. FP_PROC_SUBSET, replicated in the signature for script
% specific reasons (functions do not share scope with calling context)
% outputnames - i.e. READ_DATA_OUTPUTFOLDERNAMES. See above. 
function data = readTableFromFolder(folder, subset)
    C = dir([folder, '\*.csv']);
    filenames = {C(:).name}.';
    data_index = 1;
    read = cell(length(C),2);
    for i=1:length(C)
        filename = filenames{i};
        
        % do checks for raw files
        if findItemInArray(filename, subset)
            fullname = [ folder '/' filename ];
            read{data_index, 1} = { filename };
            read{data_index, 2} = readtable(fullname, 'PreserveVariableNames', true );
            data_index = data_index + 1;
        end
    end
    
    % strip out empty entries then return
    read = read(1:sum(~cellfun(@isempty, read), 1), :);
    data = read;
end

function found = findItemInArray(item, entries)
    
    if isempty(entries) 
        found = 1; 
        return;
    end
    
    for entry = entries'
       if contains(item, entry)
          found = 1; 
          return;
       end
    end
    
    found = 0;
end