indir = FP_PROC_FILE_DIR;
outdir = FP_PROC_GRAPH_DIR;

% Read annotated file for the subjects in this pipeline from disk
% Annotated file should contain time stamps for each relevant event (e.g.
% nose poke, light/dark transition, etc.)
annotatedfiledata = readcell(FP_ANNOTATED_FILENAME);

MDIR_DIRECTORY_NAME = outdir;
make_directory;


data = cell(100000, 2); 

% TODO: Recalculated this number from 122Hz because of some inconsistencies
% in the time I got 
fs = 122; % sampling frequency of device (actually 120.5)
rfac = 1; % reduction factor, aka how much the data is binned. For decimation, this number would equal 10.

% get suspension and imipramine files from the general directory by subject
% number
files = dir([ indir '/**/*.csv' ]);
filenames =  split([ files.name ], '.csv' );
dataidx = 1;

for file = filenames'
    b = 0; e = 0;
    [match, token, ext] = regexp(file, "PROCESSED_(\d*)[\w- ]*?(\d+)_?(\d+)?", 'match', 'tokens', 'forceCellOutput'); % extract the run from the file
    
    if size(token{1,1}, 1) ~= 0
        t = string(token{1,1}{1,1}{1,1});
        index = split(t, '_');
        if (strlength(index) > 0)
            % kept track of separately to retain zero padding in string
            index = index(1); 
            if findItemInArray(file, filenames, 1)
                data{dataidx, 1} = readmatrix([ indir '/' file{1,1} ]);
                data{dataidx, 2} = file;
                dataidx = dataidx + 1;
            end
        end
    end
end

data = data(1:dataidx - 1, [ 1 2 ]);
intdata = cell(size(data, 1), 4);

% downsample data before further processing
for i=1:size(data, 1)
    rawsusdata = data{i};
    len = floor(length(rawsusdata) / rfac);
    current_intdata = zeros(1, len);
    
    for j=1:len
       low_index = floor((j - 1) * rfac) + 1; high_index = floor(j * rfac);
       if (j < len)
           slice = rawsusdata(low_index:high_index, 4);
           int_point = sum(slice, 1) / rfac;
       else 
           high_index = length(rawsusdata);
           slice = rawsusdata(low_index:high_index, 4);
           int_point = sum(slice, 1) / length(slice);
       end
       
       current_intdata(1, j) = int_point;
    end
    
    intdata{i, 1} = current_intdata;
    intdata{i, 2} = diff(current_intdata);
    % intdata{i, 3} left unused for legacy reasons
    intdata{i, 4} = string(data{i, 2});
end


%% Parse annotated file and create lines at nose pokes
% Read columns for information about data structure
ann_data_header = annotatedfiledata(1, :);
first_idx = find( strcmp(ann_data_header(:), FP_FIRST_COL_INDEX ) ); % index of first data point recorded by device (for MedPC this would be B(1), B(2)...)
first_col = find( strcmp(ann_data_header(:), FP_FIRST_COL_NAME ) ); % index of columns that will tell you how many of the first data points follow the metadata columns. 
first_data_points = cell(10000, 10000); 

max_first_points = -1;
for row=2:size(annotatedfiledata, 1)
    num_first_data_points = annotatedfiledata{row, first_col}; 
    if num_first_data_points > max_first_points
        max_first_points = num_first_data_points; 
    end
    
    first_data_points{row - 1, 1} = num2str(num_first_data_points);
    first_data_points(row - 1, 2:num_first_data_points+1) = annotatedfiledata(row, first_idx:first_idx + num_first_data_points - 1);
end

first_data_points = first_data_points(1:row-1, 1:max_first_points+1);
%% collect data from right bounded transition points using compiled data from previous step
bound = [ -5 5 ]; % seconds before and seconds after transition point to measure
window = bound(2) - bound(1);
std_mov = zeros(size(intdata, 1), 2);
std_stl = zeros(size(intdata, 1), 2);
mean_transitions = cell(size(intdata, 1), 2);

    
for row=1:size(intdata, 1)
    intdata_row = intdata{row, 1}; 
    points = first_data_points(row, :);
    points = points(2:str2double(points{1}) + 1); % scrub empty entries using number of points stored at beginning of entry
    time = linspace(0, length(intdata_row) / (fs / rfac), length(intdata_row)); % to recover original second count of signal, divide length of reduced signal by sampling frequency and multiply by reduction factor
    
    plot(time, intdata_row);
    hold on;
    yl = ylim;
    % skip the first index since that's the number of entries in the row
    for pt = 1:size(points, 2) 
        % adjusted_pt = floor(points{pt} * (fs / rfac)); % Actual data point in intdata will be at the second mark times the sampling frequency divided by the reduction factor
        line([ points{pt} points{pt} ], [ yl(1) yl(2) ], 'Color', 'black', 'LineStyle', '--');
    end
    hold off;
    
    title(join([ constructGraphName(intdata{row, 4}), ' with ', FP_FIRST_COL_NAME], '') ); 
    xlabel('Time'); % 
    ylabel('df/f');
    
    print(join([outdir, "/", constructGraphName(intdata{row, 4}), " corrected with ", FP_FIRST_COL_NAME], ""), '-dpng');
    clf('reset');
    
    % TODO: This code uses the data from the raw data as it is, i.e.
    % unprocessed. It may be innacurate for tone hits in particular, as it
    % will not account for the time discrepency between tone onset and correct
    % nose poke
    window_time = linspace(bound(1), bound(2), ( ( bound(2) - bound(1) ) * (fs / rfac) ) + 1); % Add one to account for Matlab bounds being inclusive
    window_time_forder = linspace(bound(1), bound(2), ( bound(2) - bound(1)) * ( fs / rfac) );
    
    windowed_points = zeros(size(points, 2), length(window_time));
    windowed_points_forder = zeros(size(points, 2), length(window_time) - 1); % Differentiation removes one point from the dataset, so we have to too
    
    adj_low_bound = bound(1) * (fs / rfac); adj_high_bound = bound(2) * (fs / rfac);
    % pull the data for the relevant event from a sheet on disk
    for pt = 1:size(points, 2)
        % NOTE: The nose pokes may not happen at an integer time, so they
        % are alligned to the floor of the time at which the nose poke
        % occurs. This may introduce some small inaccuracies.
        % The first check has to be greater than one and not zero because
        % otherwise you will attempt to retrieve data from index zero,
        % which does not exist in Matlab
        if (points{1, pt} + adj_low_bound > 1 )&& (points{1,pt} + adj_high_bound) < length(intdata_row)
            pts = intdata_row(1, floor( points{1, pt} + adj_low_bound ):floor( points{1, pt} + adj_high_bound ));
            windowed_points(pt, 1:end) = pts;
            windowed_points_forder(pt, 1:end) = diff(pts);
        end
    end

    
    % Plot windowed points
    p = plot(window_time, windowed_points, 'k');
    hold on;
   
    % Make non-mean lines partially transparent
    for pl=1:length(p) 
        p(pl).Color(4) = 0.2;
    end
    
    mean_windowed_points = mean(windowed_points, 1);
    m_line = plot(window_time, mean_windowed_points, 'b');
    mean_windowed_points_forder = mean(windowed_points_forder, 1);
    ms_line = plot(window_time_forder, mean_windowed_points_forder, 'r');
    hold off; 
    
    addChartStyling([ FP_FIRST_COL_NAME ' in window for ' constructGraphName(intdata{row, 4}) ], [m_line, ms_line], { 'Mean', 'Mean Slope' }, bound);
    print(join([outdir, "/", constructGraphName(intdata{row, 4}), " ", FP_FIRST_COL_NAME ], ""), '-dpng');
    clf('reset');
    
    hold on;
    m_line = plot(window_time, mean_windowed_points, 'b');
    % ms_line = plot(window_time_forder, mean_windowed_points_forder, 'r');
    hold off;
    
    addChartStyling([ FP_FIRST_COL_NAME ' in window for ' constructGraphName(intdata{row, 4}) ' (means only)'], [m_line], { 'Mean' }, bound);
    print(join([outdir, "/", constructGraphName(intdata{row, 4}), " ", FP_FIRST_COL_NAME  " means only"], ""), '-dpng');
   
end

function found = findItemInArray(item, entries, emptybehavior)
    
    if isempty(entries) 
        found = emptybehavior;
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

% takes a raw filename and extracts the information relevant to the mouse
% to construct a filename. 
function fid = constructGraphName(filename)
    searchRegex = '(\d+)';
    matches = regexp(filename, searchRegex, 'match');
    
    % Bit of a stop-gap to account for days that are labeled by day type,
    % e.g. if there's a day 1 for both 'Cued' and 'Timeout' type days.
    % May need to find a more intelligent solution in the future
    daytype = '';
    if contains(lower(filename), 'cued')
       daytype = 'Cued';
    elseif contains(lower(filename), 'timeout')
        daytype = 'Timeout';
    end
    mouseid = matches{1};
    day = matches{2};
    fid = join([ mouseid, daytype "day", day ]);
end

function addChartStyling(name, lines, line_titles, bound)
    title(name); 
    xlabel('Time within window)');
    ylabel('df/f');
    xticks(bound(1):1:bound(2));
    legend(lines, line_titles);
end