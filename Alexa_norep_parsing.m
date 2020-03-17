indir = FP_PROC_FILE_DIR;
outdir = ALEXA_GRAPH_DIR;

MDIR_DIRECTORY_NAME = outdir;

make_directory;

susfiles = ALEXA_SUSFILES;
impfiles = ALEXA_IMPFILES;

susdata = cell(100000, 2); 
impdata = cell(100000, 2);

fs = 122; % sampling frequency of device

% get suspension and imipramine files from the general directory by subject
% number
files = dir([ indir '/**/*.csv' ]);
filenames =  split([ files.name ], '.csv' );
impindex = 1;
susindex = 1;

for file = filenames'
    b = 0; e = 0;
    [match, token, ext] = regexp(file, "PROCESSED_(\d*)[\w- ]*?(\d+)_?(\d+)?", 'match', 'tokens', 'forceCellOutput'); % extract the run from the file
    
    if size(token{1,1}, 1) ~= 0
        t = string(token{1,1}{1,1}{1,1});
        index = split(t, '_');
        if (strlength(index) > 0)
            % kept track of separately to retain zero padding in string
            index = index(1); 
            if findItemInArray(file, susfiles, 1)
                susdata{susindex, 1} = readmatrix([ indir '/' file{1,1} ]);
                susdata{susindex, 2} = file;
                susindex = susindex + 1;
            elseif findItemInArray(file, impfiles, 1)
                impdata{impindex, 1} = readmatrix([ indir '/' file{1,1} ]);
                impdata{impindex, 2} = file;
                impindex = impindex + 1;
            end
        end
    end
end

impdata = impdata(1:impindex - 1, [ 1 2 ]);
susdata = susdata(1:susindex - 1, [ 1 2 ]);

% weird spiky data on the first imp trial, so I cut the signal where the
% device weirdness starts
% Put this back in for Alexa's data
bad_data = impdata{1, 1};
impdata{1, 1} = bad_data(1:116894, :);

intsusdata = cell(size(susdata, 1), 4);
intimpdata = cell(size(impdata, 1), 4);

% take one second samples for each data set before doing each step
for i=1:size(susdata, 1)
    rawsusdata = susdata{i};
    len = floor(length(rawsusdata) / fs);
    int_data = zeros(1, len);
    int_movement = zeros(1, len);
    
    for j=1:len
       low_index = (j - 1) * fs + 1; high_index = j * fs;
       if (j < len)
           slice = rawsusdata(low_index:high_index, 4);
           int_point = sum(slice, 1) / fs;
          
           mov_slice = rawsusdata(low_index:high_index, 5);
           num_moving = sum(mov_slice(:) == 1);
           
           if (num_moving > 50) 
               int_movement(1, j) = 1;
           else
               int_movement(1, j) = 0;
           end
       else 
           high_index = length(rawsusdata);
           slice = rawsusdata(low_index:high_index, 4);
           int_point = sum(slice, 1) / (high_index - low_index);
       end
       
       int_data(1, j) = int_point;
       
        % Note on mouse movements: 
        % for seconds during which the mouse is partially moving and partially
        % not, break the tie by which happens more during the second
        mov_slice = rawsusdata(low_index:high_index, 5);
        num_moving = sum(mov_slice(:) == 1);
        if (num_moving > (high_index - low_index) / 2) 
           int_movement(1, j) = 1;
        else
           int_movement(1, j) = 0;
        end
    end
    
    intsusdata{i, 1} = int_data;
    intsusdata{i, 2} = diff(int_data);
    intsusdata{i, 3} = int_movement;
    intsusdata{i, 4} = string(susdata{i, 2});
end

for i=1:size(impdata, 1)
   rawimpdata = impdata{i};
   len = floor(length(rawimpdata) / fs);
   imp_data = zeros(1, len);
   int_movement = zeros(1, len);
   
   for j=1:len
      low_index = (j - 1) * fs + 1; high_index = j * fs;
      if (j < len)
          slice = rawimpdata(low_index:high_index, 4);
          imp_point = sum(slice, 1) / fs;
      else
          high_index = length(rawimpdata); 
          slice = rawimpdata(low_index:high_index, 4);
          imp_point = sum(slice, 1) / (high_index - low_index);
      end
      
      imp_data(1, j) = imp_point;
      
       % Note on mouse movements: 
       % for seconds during which the mouse is partially moving and partially
       % not, break the tie by which happens more during the second
       mov_slice = rawimpdata(low_index:high_index, 5);
       num_moving = sum(mov_slice(:) == 1);
       if (num_moving > (high_index - low_index) / 2) 
          int_movement(1, j) = 1;
       else
          int_movement(1, j) = 0;
       end
   end
   
   intimpdata{i, 1} = imp_data;
   intimpdata{i, 2} = diff(imp_data);
   intimpdata{i, 3} = int_movement;
   intimpdata{i, 4} = string(impdata{i, 2});
end

for i=1:size(intsusdata, 1)
    time = linspace(0, length(intsusdata{mouse,1}) - 1, length(intsusdata{mouse, 1}));
    f1 = plot(time, intsusdata{mouse, 1});
    title(join([ 'Z corrected slope for', constructGraphName(intsusdata{i, 4})]));
    xlabel('Time (s)');
    ylabel('Z score');
    xlim([0 360]);
    
    %% create shaded regions where movement occurs
    % collate regions of movement by contiguity
    sustime = intsusdata{i, 3};
    region = cell(length(sustime), 1);
    
    region_start = 1; region_index = 1;
    yl = ylim;
    for j=1:length(sustime)
        if (sustime(j) == 1)
            if ( j == length(sustime) || (j < length(sustime) && sustime(j+1) == 0) )
                r = [ region_start yl(1); j yl(1); region_start yl(2); j yl(2);];
                region{region_index} = r;
                region_index = region_index + 1;
            end
        end
        
        if (sustime(j) == 0)
            region_start = j;
        end
    end
    
    region = region(1:sum(~cellfun(@isempty, region)));
    
    for j=1:length(region)
        patch('Faces', [1 2 4 3], 'Vertices', region{j}, 'FaceColor', 'green', 'FaceAlpha', 0.3);
    end
    
    graphname = join([ outdir, "\", constructGraphName(intsusdata{i, 4}), " shaded graph" ], "");
    print(graphname, '-dpng');
end

%% collect data from right bounded transition points
bound = [ -5 5 ]; % seconds before and seconds after transition point to measure
window = bound(2) - bound(1);
std_mov = zeros(size(intsusdata, 1), 2);
std_stl = zeros(size(intsusdata, 1), 2);
mean_transitions = cell(size(intsusdata, 1), 2);

for i=1:size(intsusdata, 1)
    movtransitions = zeros(size(intsusdata{i, 1}, 2), window + 1);
    stilltransitions = zeros(size(intsusdata{i, 1}, 2), window + 1);
    movindex = 1; stillindex = 1;
    
    movdata = intsusdata{i, 3};
    s_data = intsusdata{i, 1};
    for j= 1 - bound(1):size(movdata, 2) - bound(2)
        if movdata(1, j) == 0 && movdata(1, j+1) == 1
            movtransitions(movindex, 1:window + 1) = s_data(1, j+bound(1):j+bound(2));
            movindex = movindex + 1;
        elseif movdata(1, j) == 1 && movdata(1, j+1) == 0
            stilltransitions(stillindex, 1:window + 1) = s_data(1, j+bound(1):j+bound(2));
            stillindex = stillindex + 1;
        end
    end
    
    movtransitions = movtransitions(1:movindex-1, :);
    stilltransitions = stilltransitions(1:stillindex-1, :);
    
    meanmovtransitions = mean(movtransitions, 1);
    meanstilltransitions = mean(stilltransitions, 1);

    mean_transitions{i, 1} = meanmovtransitions; 
    mean_transitions{i, 2} = meanstilltransitions;
    mean_transitions{i, 3} = intsusdata{i, 4};
    
    std_mov(i, 1) = std(meanmovtransitions); 
    std_stl(i, 1) = std(meanstilltransitions);
    std_mov(i, 2) = std_mov(i, 1) / sqrt(size(movtransitions, 2));
    std_stl(i, 2) = std_stl(i, 1) / sqrt(size(stilltransitions, 2));
    
    clf('reset'); % clear away old plot data
    transition_time = linspace(bound(1), bound(2), window+1);
    
    % plot still-to-moving transitions (0 to 1)
    mov_lines = line(transition_time, transpose(movtransitions));
    applyGradient(mov_lines, 1);
    
    % calculate mean line plus and minus error margin
    sem_mean_mov = { meanmovtransitions + std_mov(i, 2), meanmovtransitions - std_mov(i, 2) };
    sem_mean_still = { meanstilltransitions + std_stl(i, 2), meanstilltransitions - std_stl(i, 2) };
    hold on;
    line(transition_time, meanmovtransitions, 'LineWidth', 1, 'Color', 'black');
    p = patch([ transition_time, fliplr(transition_time) ], [ sem_mean_mov{1, 1}, fliplr(sem_mean_mov{1, 2} )], 'g');
    p.FaceColor = [ 0, 0, 0 ];
    p.FaceAlpha = 0.3;
    hold off;
    
    title('Transitions from still to moving'); 
    xlabel('Time before transitions (seconds)');
    ylabel('df/f');
    
    print(join([outdir, "/", constructGraphName(intsusdata{i, 4}), " still to moving (11 sec)"], ""), '-dpng');
    clf('reset');
    
    % plot moving-to-still transitions (1 to 0)
    still_lines = line(transition_time, transpose(stilltransitions));
    applyGradient(still_lines, 1);
    
    hold on;
    line(transition_time, meanstilltransitions, 'LineWidth', 1, 'Color', 'black');
    p = patch([ transition_time, fliplr(transition_time) ], [ sem_mean_still{1, 1}, fliplr(sem_mean_still{1, 2} )], 'g');
    p.FaceColor = [ 0, 0, 0 ];
    p.FaceAlpha = 0.3;
    hold off;
    
    title('Transitions from moving to still'); 
    xlabel('Time before transitions (seconds)');
    ylabel('df/f');
    
    print(join([outdir, "/", constructGraphName(intsusdata{i, 4}), " moving to still (11 sec)"], ""), '-dpng');
end

clf('reset');

%% Take mean of transitions for each subject and calculate params for them too
sepdata = separateBySubjectNumber(mean_transitions);

for k=1:size(sepdata, 1)
    
    % Parse per subject transition data (with Gaussian metrics and error
    % bounds)
    d = sepdata{k, 1};
    subnum = sepdata{k, 2};
    
    mean_mean_transitions = cell(window+1, 2);
    sem_mean_mean = cell(window + 1, 2);

    mov_means = zeros(window + 1, size(d, 1));
    still_means = zeros(window + 1, size(d, 1));
    
    std_mov = zeros(size(d, 1), 1); 
    std_still = zeros(size(d, 1), 1);
    
    for i=1:size(mov_means, 2)
        mov_means(:, i) = d{i, 1};
        still_means(:, i) = d{i, 2};
        std_mov(i, 1) = std(d{i, 1});
        std_still(i, 1) = std(d{i, 2});
    end
    
    for i=1:size(mov_means, 1)
        mean_mean_transitions{i, 1} = mean(mov_means(i, :));
        mean_mean_transitions{i, 2} = mean(still_means(i, :));
    end
    
    std_mean_mov = std([ mean_mean_transitions{:, 1} ]);
    std_mean_still = std([ mean_mean_transitions{:, 2} ]);
    
    sem_mean_mov = { [ mean_mean_transitions{:, 1} ] + ( std_mean_mov / sqrt(size(mean_transitions, 1))), [ mean_mean_transitions{:, 1} ] - ( std_mean_mov / sqrt(size(mean_transitions, 1))) };
    sem_mean_still = { [ mean_mean_transitions{:, 2} ] + ( std_mean_still / sqrt(size(mean_transitions, 1))), [ mean_mean_transitions{:, 2} ] - ( std_mean_still / sqrt(size(mean_transitions, 1))) };
    
    % Plot still to moving transitions
    mov_lines = line(transition_time, mov_means);
    applyGradient(mov_lines, 1);
    
    hold on;
    line(transition_time, [ mean_mean_transitions{:, 1} ], 'LineWidth', 2, 'Color', 'black');
    p = patch([ transition_time, fliplr(transition_time) ], [ sem_mean_mov{1, 1}, fliplr(sem_mean_mov{1, 2} )], 'g');
    p.FaceColor = [ 0, 0, 0 ];
    p.FaceAlpha = 0.3;
    hold off;
    
    t = join( ['Mean transition time from still to moving for', subnum] );
    title(t);
    xlabel('Time before transitions (seconds)');
    ylabel('df/f');
    
    print(join([outdir, "/", subnum, " mean still to moving (11 sec)"], ""), '-dpng');
    
    clf('reset');
    
    % Plot moving to still transitions
    still_lines = line(transition_time, still_means);
    applyGradient(still_lines, 1);
    
    hold on;
    line(transition_time, [ mean_mean_transitions{:, 2} ], 'LineWidth', 2, 'Color', 'black');
    p = patch([ transition_time, fliplr(transition_time) ], [ sem_mean_still{1, 1}, fliplr(sem_mean_still{1, 2} )], 'g');
    p.FaceColor = [ 0, 0, 0 ];
    p.FaceAlpha = 0.3;
    hold off;
    
    t = join( ['Mean transition time from moving to still for', subnum] );
    title(t);
    xlabel('Time before transitions (seconds)');
    ylabel('df/f');
    
    print(join([outdir, "/", subnum, " mean moving to still (11 sec)"], ""), '-dpng');
    
    % Now plot Gaussian metrics
    bar_data = std_mov;
    bar_data(:, 2) = transpose(std_still);
    bar_data(size(bar_data, 1) + 1, :) = [ std_mean_mov, std_mean_still ];
    bar(bar_data);
    t = join( ['Per trial standard deviation for', subnum] );
    title(t);
    ylabel('std');
    
    xtlabels = cell(size(bar_data, 1), 1);
    for i=1:length(xtlabels) - 1
       xtlabels{i, 1} = join([ 'Day', string(i) ]);
    end
    xtlabels{end, 1} = 'Mean';
    xticklabels(xtlabels);
    legend('Still to moving', 'Moving to still');
    print(join([outdir, "/", subnum, " mean moving to still (11 sec)"], ""), '-dpng');
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
    % TODO: Figure out why the output is discrepant? This seems to make a
    % 1x1 cell
    mouseid = matches{1};
    day = matches{2};
    fid = join([ mouseid, "day", day ]);
end

% apply gradient from [ 255-0, 0, 0-255 ] RGB to a set of lines at a given opacity
function applyGradient(l, alpha)
    c = jet(length(l));
    for k=1:length(l)
       l(k).Color =  [ c(k,1), c(k,2), c(k,3), alpha ];
    end
end

function sep = separateBySubjectNumber(m)
    sepdata = cell(100, 2);
    found_subjects = [];
    subnumregex = 'PROCESSED_(\d+)';
    subnumindex = 1;
    
    % Apply regex to subject name to see if we've seen this subject yet
    for i=1:size(m, 1)
        [ mat, tok ] = regexp(m{i, 3}, subnumregex, 'match', 'tokens', 'forceCellOutput');
        subnum = string(tok{1,1});
        if (~findItemInArray(subnum, found_subjects, 0))
            found_subjects = [ found_subjects, subnum ];
            sepdata{subnumindex, 1} = { m{i, :} };
            sepdata{subnumindex, 2} = subnum;
            subnumindex = subnumindex + 1;
        else
            idx = [ sepdata{:, 2} ] == subnum;
            sepdata{idx, 1}(size(sepdata{idx, 1}, 1) + 1, :) = m(i, :);
        end
    end
    
    sepdata = sepdata(1:subnumindex - 1, :); 
    sep = sepdata;
end


% %% Analyze regions of movement by slope 
% avg_mov = [0, 0, 0, 0, 0];
% avg_nm = [0, 0, 0, 0, 0];
% avg_slope_mov_zcorr = [0, 0, 0, 0, 0];
% avg_slope_nm_zcorr = [0, 0, 0, 0, 0];
% for i=1:5
%     deriv = intsusdata{i, 2};
%     mov = intsusdata{i, 3};
%     deriv_len = length(deriv);
%     slope_nm = zeros(deriv_len, 1); slope_mov = zeros(deriv_len, 1);
%     index_nm = 1; index_mov = 1;
%     for j=1:deriv_len
%       if (mov(j) == 1)
%           slope_mov(index_mov) = deriv(j);
%           index_mov = index_mov + 1;
%       else 
%           slope_nm(index_nm) = deriv(j);
%           index_nm = index_nm + 1;
%       end
%     end
%     
%     slope_mov = slope_mov(1:nnz(slope_mov));
%     slope_nm = slope_nm(1:nnz(slope_nm));
%     avg_mov(i) = sum(slope_mov(:)) / length(slope_mov);
%     avg_nm(i) = sum(slope_nm(:)) / length(slope_nm);
%     
%     % calculate statistics for slope significance
%     std_deriv = std(deriv);
%     mean_deriv = mean(deriv);
%     
%     slope_mov_zcorr = zeros(length(slope_mov), 1);
%     slope_nm_zcorr = zeros(length(slope_nm), 1);
%     for j=1:length(slope_mov)
%         slope_mov_zcorr(j) = (slope_mov(j) - mean_deriv) / std_deriv;
%     end
%     
%     for j=1:length(slope_nm)
%         slope_nm_zcorr(j) = (slope_nm(j) - mean_deriv) / std_deriv; 
%     end
%     
%     avg_slope_mov_zcorr(i) = sum(slope_mov_zcorr(:)) / length(slope_mov_zcorr);
%     avg_slope_nm_zcorr(i) = sum(slope_nm_zcorr(:)) / length(slope_nm_zcorr);
% end
