%% FP_2019_14_prelim_graphs_v2

%v2: now plots rcamp signal and saves in indicator folders

folder = FP_PROC_FILE_DIR;
outputfolder = FP_PROC_GRAPH_DIR;

outputfile = '2019-14 MATLAB Prelim Output';

codename = 'FP_2019_14_prelim_graphs_v2';

indicator_groups = FP_INDICATOR_IDS;

%Auto Import Data

MDIR_DIRECTORY_NAME = outputfolder;
make_directory;

READ_DATA_TYPE = 'processed';
READ_DATA_PATH = folder;
read_data;
raw = READ_DATA_PROCESSED;

%add file names to data's first col
data = raw;

%initialize timecolraw (to take only first time col)
timecolraw = 0;

%Cycle through each row (session/day)
for row = 1:size(raw,1)
    %Cycle through each column/row)
    for column = 1:size(raw{row,2},2)
        
        %Grab first Time col (there are sometimes 2)
        %timecolraw probably isn't necessary bc it'd just overwrite with
        %the same thing
        if strcmp(raw{row,2}{1,column}, 'Time') && timecolraw == 0
            data{row,2}(:,1) = cell2mat(raw{row,2}(2:end,column));
            timecolraw = timecolraw + 1;
        end
        
        %Grab dF/F col
        if strcmp(raw{row,2}{1,column}, 'Corrected')
            data{row,2}(:,2) = cell2mat(raw{row,2}(2:end,column));
        end
        
        %Grab Digital input col
        if strcmp(raw{row,2}{1,column}, 'DIO')
            data{row,2}(:,3) = cell2mat(raw{row,2}(2:end,column));
        end
        
        %Grab Ref df/f
        if strcmp(raw{row,2}{1,column}, 'Reference (DF/F0)')
            data{row,2}(:,4) = cell2mat(raw{row,2}(2:end,column));
        end
        
        %Grab Signal df/f
        if strcmp(raw{row,2}{1,column}, 'Ca2+ Signal (DF/F0)')
            data{row,2}(:,5) = cell2mat(raw{row,2}(2:end,column));
        end
        
          %Grab RCaMP
        if strcmp(raw{row,2}{1,column}, 'DF/F0 RCaMP')
            data{row,2}(:,6) = cell2mat(raw{row,2}(2:end,column));
        end
        
        
    end
    timecolraw = 0;
end


%Cutting headers off when pulling now so I can make then matrices
% %cut off column headings
% for row = 1:length(data)
%     data{row,2} = data{row,2}(2:end,:);
% end



%% Loop through all data files
for file = 1:size(data,1)
    
    % Rename columns to something referenceable by code
    header = { 'Time', 'Ref', 'Sig', 'Corr', 'DIO' };
    filename = data{file, 1}{1};
    data{file, 2}.Properties.VariableNames = header;
    
    nums = parseNumerics(data{file,1}{1});
    mouse_ID = nums{1,1};
    day = nums{2,1};
    
    
    
    %% Scrub weird spikes
    %turn weird spikes to NaN
    % TODO: Same deal as with the raw graph code. Removed because it's
    % unbearably slow
    
    for col = [2 4 5]
        for row=1:height(data{file, 2})
            entry = data{file, 2}{row, col};
            if entry < -20 || entry > 20 % TODO: Changed this to something more reasonable for df/f
                data{file, 2}{row, col} = NaN;
            end
        % data{file,2}(data{file,2}(:,col)<-99,col) = NaN;
        % data{file,2}(data{file,2}(:,col)>99,col) = NaN;
        end
    end
    
    
    if str2double(mouse_ID) == 849 || str2double(mouse_ID) == 850
        
        for col = 6
            data{file,2}(data{file,2}(:,col)<-99,col) = NaN;
            data{file,2}(data{file,2}(:,col)>99,col) = NaN;
        end
        
    end
    
    indicator = 'IND-UNK';
    for i=1:size(indicator_groups, 1)
        if any(indicator_groups{i, 1} == str2double(mouse_ID))
           indicator = indicator_groups{i, 2}; 
        end
    end
        
    figure('Visible', 'off')
    hold on
    
    MDIR_DIRECTORY_NAME = [ outputfolder '\' indicator ];
    make_directory
    
    time = data{file, 2}.Time;
    ref = data{file, 2}.Ref;
    sig = data{file, 2}.Sig;
    % ref = cellfun(@cleanArrayEntry, ref);
    % sig = cellfun(@cleanArrayEntry, data{file, 2}.Sig);
    corr = data{file, 2}.Corr;
    dio = data{file, 2}.DIO;
    
    % find leading edge of each ttl pulse by looking for when 0 changes to
    % 1 in the raw data
    ttl_pulses = []; 
    for row=2:size(dio, 1)
        if dio(row-1, 1) == 0 && dio(row, 1) == 1
           ttl_pulses(end + 1) = time(row, 1); 
        end
    end
    
    
    f1 = plot(time, corr, 'm');

    lim = [0 time(end) ];
    xlim([lim(1) lim(2)]);
    title([mouse_ID ' ' indicator ' corrected'] ,'fontsize',16)
    
    graphname = constructGraphName(filename);
    print([outputfolder '\' indicator  '\' indicator ' ' graphname ' corr'], '-dpng');
    
    lim = [ time(ceil(0.4 * length(time))), time(ceil(0.4 * length(time)) + 1000)];
    xlim([ lim(1) lim(2) ]);
    print([outputfolder '\' indicator  '\' indicator ' ' graphname ' corr zoom'], '-dpng');
    
    %% plot sig + ref
    
    figure('Visible', 'off')
    
    
    %if rcamp mouse, plot another cyan line that is rcamp signal
    % TODO: Commented this out because I changed how groups work
    % if any(str2double(mouse_ID) == rcamp_gach)
        % f2 = plot(time), data{file,2}(:,4), 'g', data{file,2}(:,1), data{file,2}(:,5), 'r', data{file,2}(:,1), data{file,2}(:,6), 'c');
    
    % else
    %     
    % end
    
    f2 = plot(time, ref, 'g', time, sig, 'r');
    lim = [0 time(end) ];
    xlim([ lim(1) lim(2)]);
    title([mouse_ID ' ' indicator] ,'fontsize',16)
    % plot TTL pulses 
    hold on;
    yl = ylim; % current y bounds of graph
    for pulse=1:length(ttl_pulses)
        plot([ ttl_pulses(pulse), ttl_pulses(pulse) ], [ yl(1), yl(2)], '--k');
    end
    hold off;
    
    print([outputfolder '\' indicator '\' indicator ' ' graphname ' sig+ref'], '-dpng');
    
    % now plot the zoomed-in area of the pulses
    if ~isempty(ttl_pulses)
        xlim([ ttl_pulses(1) - 10 ttl_pulses(end) + 10 ]); 
        title([mouse_ID ' ' indicator]);
        print([outputfolder '\' indicator '\' indicator ' ' graphname ' sig+ref zoom'], '-dpng');
    else
       fprintf('No ttl pulses detected for %s, cannot plot the zoomed graph for this.\n', graphname); 
    end

    close all
    
end



%% Print code version text file

%print the version of the code used
fileID = fopen([outputfolder '\codeused.txt'],'w');
fprintf(fileID, codename);


function cleaned = cleanArrayEntry(entry)
    if (entry == "")
        cleaned = NaN;
    else
        cleaned = str2double(entry);
    end
end

% takes a raw filename and extracts the information relevant to the mouse
% to construct a filename. 
function fid = constructGraphName(filename)
    searchRegex = '(\d+)';
    matches = regexp(filename, searchRegex, 'match');
    % TODO: Figure out why the output is discrepant? This seems to make a
    % 1x1 cell
    mouseid = matches{1};
    day = matches{2};
    fid = [ mouseid ' day ' day ];
end

function nums = parseNumerics(filename) 
    searchRegex = '(\d+)';
    matches = regexp(filename, searchRegex, 'match');
    mouseid = matches{1};
    day = matches{2};
    nums = { mouseid; day; };
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




