%% FP_2019_14_prelim_graphs_raw_v2

%v2: now plots rcamp signal and saves in indicator folders

fprintf('Beginning raw graph generation...\n');

folder = FP_RAW_FILE_DIR;
outputfolder = FP_RAW_GRAPH_DIR;
outputfile = '2019-14 MATLAB Prelim Output';

codename = 'FP_2019_14_prelim_graphs_raw_v2';

MDIR_DIRECTORY_NAME = FP_RAW_GRAPH_DIR;
%Groups
% gach = [1012 176 178 129 124];
% rcamp_gach = [849 850];
% camkii_gcamp = [177 179 130];
% gad_gcamp = [1153 1159 1160];
% NBM_BLA = [851 852 856 860];

indicator_groups = FP_INDICATOR_IDS;

make_directory

% FP_PROC_SUBSET = ["0130", "0177"];

outputfoldercontents = dir(fullfile(outputfolder, '**\*'));
outputfoldernames = string([outputfoldercontents.name]);

READ_DATA_TYPE = 'raw';
READ_DATA_PATH = folder;
READ_DATA_OUTPUTFOLDERNAMES = outputfoldernames;
read_data;
raw = READ_DATA_RAW;

%add file names to data's first col
data = raw(:,1);

%initialize timecolraw (to take only first time col)
timecolraw = 0;

%Cycle through each row (session/day)
for row = 1:size(raw,1)
    %Cycle through each column/row)
    for column = 1:size(raw{row,2},2)
        
        %Grab first Time col (there are sometimes 2)
        %timecolraw probably isn't necessary bc it'd just overwrite with
        %the same thing
        if strcmp(raw{row,2}{1,column}, 'Time(s)') && timecolraw == 0
            data{row,2}(:,1) = raw{row,2}(3:end,column);
            timecolraw = timecolraw + 1;
        end
        
        %Grab raw ref
        if strcmp(raw{row,2}{1,column}, 'AIn-1 - Dem (AOut-1)')
            data{row,2}(:,2) = raw{row,2}(3:end,column);
        end
        
        %Grab raw signal
        if strcmp(raw{row,2}{1,column}, 'AIn-1 - Dem (AOut-2)')
            data{row,2}(:,3) = raw{row,2}(3:end,column);
        end
        
        
          %Grab raw rcamp signal
        if strcmp(raw{row,2}{1,column}, 'AIn-2 - Dem (AOut-3)')
            data{row,2}(:,4) = raw{row,2}(3:end,column);
        end
        
    end
    timecolraw = 0;
    headersize = size(data{row,2}, 2);
    if headersize == 4
       header = { 'Time', 'Ref', 'Sig', 'RCaMP' }; 
    elseif headersize == 3
       header = { 'Time', 'Ref', 'Sig' };
    end
    
    data{row, 2}.Properties.VariableNames = header;
end


%Cutting headers off when pulling now so I can make then matrices
% %cut off column headings
% for row = 1:length(data)
%     data{row,2} = data{row,2}(2:end,:);
% end



%% Loop through all data files
for file = 1:size(data,1)
    %% Scrub weird spikes
    %turn weird spikes to NaN
    % TODO: No longer scrubbing spikes because it's unbearably slow. Add
    % this back later? 
    nums = parseNumerics(data{file,1}{1});
    mouse_ID = nums{1,1};
    day = nums{2,1};
    
%     for i=1:length(ref)
%         if ref{i} >= 99 | ref{i} <= -99
%             ref{i} = NaN;
%         end
%         
%         if sig{i} >= 99 | sig{i} <= -99
%            sig{i} = NaN; 
%         end
%     end
    
    if str2double(mouse_ID) == 849 || str2double(mouse_ID) == 850
        
        for col = 4
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
    
    
    %determine group/indicator
%     if any(str2double(mouse_ID) == gach)
%         indicator = 'GACh';
%         %         climits = [-2 4.5];
%         
%     elseif any(str2double(mouse_ID) == rcamp_gach)
%         indicator = 'RCaMP + GACh';
%         %         climits = [-3 7];
%         %         GAChnum=find(BLA_GACh==mouse_ID);
%         
%     elseif any(str2double(mouse_ID) == camkii_gcamp)
%         indicator = 'CaMKII-GCaMP';
%         %         climits = [-3 7];
%         %         GAChnum=find(BLA_GACh==mouse_ID);
%         
%     elseif any(str2double(mouse_ID) == gad_gcamp)
%         indicator = 'Gad65-GCaMP';
%         %         climits = [-3 7];
%         %         GAChnum=find(BLA_GACh==mouse_ID);
%         
%     elseif any(str2double(mouse_ID) == NBM_BLA)
%         indicator = 'NBM-BLA';
%         %         climits = [-3 7];
%         %         GAChnum=find(BLA_GACh==mouse_ID);
%     else 
%         indicator = 'IND-UNKNOWN';
%     end
    
    figure('Visible', 'off')
    hold on
    
    % need to clean time in order to convert it to double
    time = cellfun(@cleanArrayEntry, data{file,2}.Time);
    ref = cellfun(@cleanArrayEntry, data{file,2}.Ref);
    sig = cellfun(@cleanArrayEntry, data{file,2}.Sig);
    

    
    % TODO: Removed this when reworking groups (add it back later?)
%     if any(str2double(mouse_ID) == rcamp_gach)
%         f1 = plot(data{file,2}(:,1), data{file,2}(:,2), 'g', data{file,2}(:,1), data{file,2}(:,3), 'r', data{file,2}(:,1), data{file,2}(:,4), 'c');
%     end

    f1 = plot(time, ref, 'g', time, sig, 'r');
    lim = [ 0 time(end, 1) ];
    xlim([lim(1) lim(2)]);
    title([mouse_ID ' ' indicator ' raw'] ,'fontsize',16)
    
    MDIR_DIRECTORY_NAME = [ outputfolder '\' indicator ];
    make_directory
    
    graphfilename = [outputfolder '\' indicator  '\' indicator ' ' constructGraphName(data{file,1}{1}) ' raw sig+ref'];
    print(graphfilename, '-dpng');
    
    zoomedfilename = [ graphfilename ' zoom'];
    lim = [ time(ceil(length(time) * 0.4), 1) time(ceil(length(time) * 0.4 + 1000), 1) ];
    xlim([lim(1) lim(2)]);
    print(zoomedfilename, '-dpng');
    
    close all
    
end




%% Save data in file

%save all variables together
% save([outputfolder '\' outputfile '.mat'], '-v7.3');



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
