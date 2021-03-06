MDIR_DIRECTORY_NAME = FP_ANALYSIS_OUTDIR;
make_directory

fs = 120; % Sampling frequency of 120
timescale = [-5 10]; % measurements taken from 5 seconds before spike to 10 seconds after 

% If there's more than one .mat file in this directory, this will read the
% first one by default so be careful!
fpcompileoutputs = dir([ FP_COMPILE_OUTDIR '\' FP_COMPILE_MATLAB_VARS ]);
for fidx=1:size(fpcompileoutputs, 1)
   if contains(fpcompileoutputs(fidx).name, '.mat')
      fpcompilevarsfilename = join([ fpcompileoutputs(fidx).folder, '\', fpcompileoutputs(fidx).name ], '');
      break;
   end
end

% Now get the list of the files spit out by FP_Compile that contain the
% processed variables
% The last contains check is to ignore any lock files
fpcompileoutputs = dir(FP_COMPILE_OUTDIR);
fpcompilefilenames = {};
for fidx=1:size(fpcompileoutputs, 1)
   if contains(fpcompileoutputs(fidx).name, '.xls') && contains(fpcompileoutputs(fidx).name, 'MATLAB_') && ~contains(fpcompileoutputs(fidx).name, '~$')
       fpcompilefilenames{end+1, 1} =  [ FP_COMPILE_OUTDIR '\' fpcompileoutputs(fidx).name ];
   end
end


% After finding the name of the external matlab variables, load them and
% reassign one variable to have a more descriptive name
load(fpcompilevarsfilename);

% TODO: Currently the compiled data is a 15 second chunk of data taken at a
% sampling frequency of ~122Hz (though I found 120Hz to be more accurate).
% This may change at some point in the future!


spikeareas = zeros(length(fpcompilefilenames), 2);
% Read the sheet specified in modified_pipeline from the compiled variables
for fidx=1:size(fpcompilefilenames, 1)
    clf('reset');
    compiled_data = xlsread(fpcompilefilenames{fidx, 1}, FP_SHEET_NAME);
    time = linspace(timescale(1), timescale(2), size(compiled_data, 1));
    
    p = plot(time, compiled_data, 'b');
    
    hold on;
    % Make non-mean lines partially transparent
    for pl=1:length(p)
        p(pl).Color(4) = 0.2;
    end
    
    mean_cols = mean(compiled_data, 2);
    plot(time, mean_cols, 'k');
    hold off;
    
    splitfpfilename = split(fpcompilefilenames{fidx, 1}, '\');
    splitfpfilename(end);
    graphname = constructGraphName(splitfpfilename(end));
    title(join([ 'Individuals and mean for ' FP_SHEET_NAME ' for ' graphname ], ''));
    
    xlabel([ 'Seconds from/after ' FP_SHEET_NAME ]);
    ylabel('df/f');
    
    xlim([ timescale(1) timescale(2) ]);    
    
    %% Take the area under the curve for the spike
    
    % We define a 'spike' here as any region of a graph for which the its
    % slope goes sharply up, down to zero, sharply down, and up to zero again
    % denoting a region of large increase, decrease, then stabilization
    
    % We go about finding it by finding the maximum of the graph after
    % spike time, looking for the zero slope before and the zero after
    % that occurs at a value less than 25% of the max in order to account for 
    % local inflection points that clearly occur during the spike
    
    % get inflection points by looking for places where either the slope is
    % zero or the slope crosses the x axis.
     % TODO: Find spike time in a more intelligent way?
    spiketime = 0;
    event_idx = find( abs( time - spiketime ) <= ( 1/fs ), 1, 'first' ); % find the closest value to spiketime in the interpolated dataset
    
    slopemean = diff(mean_cols);
    inflection_pts = zeros(length(slopemean) - 1, 1);
    
    for pt=1:length(slopemean) - 1
        if ( slopemean(pt) > 0 && slopemean(pt+1) < 0 ) || ( slopemean(pt) < 0 && slopemean(pt+1) > 0 || slopemean(pt) == 0)
            inflection_pts(pt) = 1;
        end
    end
    

    [ max_cols, midx ] = max(mean_cols(event_idx:end));
    midx = midx - 1; % adjust mean index to be the number of indices AFTER the event rather than a simple Matlab index 
    
    % exclude the max itself from consideration, as it is also an
    % inflection point by definition. This requires taking away two
    % indices, one to make event_idx an offset, and one to remove the last
    % point
    zeros_preslope = find(inflection_pts(1:midx+event_idx-2) == 1);
    zeros_postslope = find(inflection_pts(midx+event_idx + 1:end) == 1);
    
    
    % find the inflection point that occurs at at least 25% of the value of the peak
    spike_end_idx = -1;
    for post_idx=1:length(zeros_postslope)
        if mean_cols(zeros_postslope(post_idx) + event_idx + midx - 1) <= max_cols * 0.25
            spike_end_idx = post_idx;
            break;
        end
    end
    
    % add midx and event_idx to the second inflection point after the spike (as discussed above) to
    % create the true index in time (zeros postslope is timeshifted to the
    % area after the max after the event
    spike_interval = [ zeros_preslope(end) zeros_postslope(spike_end_idx) + event_idx + midx] ;
    spike_interval_time = [ time(spike_interval(1)) time(spike_interval(2)) ];
    
    xline(spike_interval_time(1));
    xline(spike_interval_time(2));
    
    
    outfilename = join([ FP_ANALYSIS_OUTDIR '\' FP_SHEET_NAME ' for ' graphname ], '');
    print(outfilename, '-dpng');
    
    
    %% Do the volumetric calculation for this graph
    % Define area as the sum of the rectangles created between the minimum
    % of the graph and the current value with width equaling the time
    % between each point in seconds
    area_base = min(mean_cols);
    rect_width = 1/fs;
    total_area = 0; spike_area = 0;
    for t=1:length(mean_cols)
        total_area = total_area + ( mean_cols(t) - area_base ) * rect_width;
    end
    
    for t=spike_interval(1):spike_interval(2)
       spike_area = spike_area + ( mean_cols(t) - area_base ) * rect_width; 
    end
    
    spikeareas(fidx, 1) = total_area;
    spikeareas(fidx, 2) = spike_area;
    
    %% Split trace before and after spike and plot the frequency variations
   
    % Compute one sided fft of signal before and after spike
    % https://www.mathworks.com/help/matlab/ref/fft.html
    % Size of positive end of fourier transform will be a vector half the
    % length of the spike data array
    left_spike = compiled_data(1:event_idx, :);
    right_spike = compiled_data(event_idx:end, :);
     
    length_left = size(left_spike, 1);
    length_right = size(right_spike, 1);
    pos_length_left = floor(length_left / 2);
    pos_length_right = floor(length_right / 2);

    combined_left_spike = zeros(floor(size(left_spike, 1) / 2), 1);
    combined_right_spike = zeros(floor(size(right_spike, 1) / 2), 1);
    
    for col=1:size(left_spike, 2)
        clf('reset');
        
        subplot(2, 1, 1);
        fft_left = fft(left_spike(:, col));
        fft_left_abs = abs(fft_left / length_left);
        fft_left_positive = fft_left_abs(1:pos_length_left);
        fft_left_positive_scale = (1/fs) * (0:pos_length_left-1);
        % plot(fft_left_positive_scale, fft_left_positive);
        
        fft_right = fft(right_spike(:, col));
        fft_right_abs = abs(fft_right / length_right);
        fft_right_positive = fft_right_abs(1:pos_length_right);
        fft_right_positive_scale = (1/fs) * (0:pos_length_right-1);
        % plot(fft_right_positive_scale, fft_right_positive);
        
        combined_left_spike = combined_left_spike + fft_left_positive;
        combined_right_spike = combined_right_spike + fft_right_positive;
    end
    
    % normalize the combined left and right spikes and plot them
    combined_left_spike = combined_left_spike / size(left_spike, 2);
    combined_right_spike = combined_right_spike / size(right_spike, 2);
     
    % find 50% mark of frequency distribution
    left_spike_total = sum(combined_left_spike);
    right_spike_total = sum(combined_right_spike);
    
    % TODO: account for discrepant totals in normalized spikes? one has a
    % higher total than the other
    running_total_left = 0; running_total_right = 0;
    for freq=1:size(combined_left_spike)
        running_total_left = running_total_left + combined_left_spike(freq, 1);
       
        if running_total_left >= left_spike_total * 0.5
           left_halfway = fft_left_positive_scale(1, freq); 
           break;
        end    
    end
    
    for freq=1:size(combined_right_spike)
         running_total_right = running_total_right + combined_right_spike(freq, 1);
        
         if running_total_right >= right_spike_total * 0.5
           right_halfway = fft_right_positive_scale(1, freq); 
           break;
        end
    end
    
    
    p1 = subplot(2, 1, 1);
    plot( (1/fs) * (0:pos_length_left - 1), combined_left_spike);
    xl = join([ 'x=', num2str(left_halfway)], '');
    xline(left_halfway, '-', xl);
    title([ 'Receptor frequency comparison between left and right of event for ' constructGraphName(splitfpfilename(end)) ]);
    
    p2 = subplot(2, 1, 2);
    plot( (1/fs) * (0:pos_length_right - 1), combined_right_spike);
    xl = join([ 'x=', num2str(right_halfway)]);
    xline(right_halfway, '-', xl);
    xlabel('Frequency (Hz)');
    addUnifiedYLabel(p1, p2, 'Amplitude (normalized)');
    
    print(join([ FP_ANALYSIS_OUTDIR '\frequency for ' constructGraphName(splitfpfilename(end)) ], ''), '-dpng');
    
   
end

%% Create the bar graph of comparative areas
clf('reset');
area_bar = bar(spikeareas);
title('Right-bounded area of trace versus area under spike');
ylabel('Area (df/f \times second)');

% TODO: come up with this more intelligently
ticklabelarray = { 'C1', 'C2', 'C3', 'C4', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12' }
xticks(1:length(ticklabelarray));
xticklabels(ticklabelarray);

% add percentage values from whole above apike area
% https://www.mathworks.com/help/matlab/ref/bar.html
xtips = area_bar(2).XEndPoints;
ytips = area_bar(2).YEndPoints;
bar_labels = strings(size(spikeareas, 1), 1);

for a=1:size(spikeareas, 1)
     decimal_val = round(spikeareas(a, 2) / spikeareas(a, 1), 3);
     decimal_val = decimal_val * 100;
     
     bar_labels(a, 1) = strcat( num2str(decimal_val), "%");
end

text(xtips, ytips, bar_labels, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

%% Helper Functions
% Small function to create a standardized graph name from the data's
% underlying filename
function fid = constructGraphName(filename)
    searchRegex = '(\d+)';
    matches = regexp(filename, searchRegex, 'match', 'forceCellOutput');
    
    % Bit of a stop-gap to account for days that are labeled by day type,
    % e.g. if there's a day 1 for both 'Cued' and 'Timeout' type days.
    % May need to find a more intelligent solution in the future
    daytype = '';
    if contains(lower(filename), 'cued')
       daytype = 'Cued';
    elseif contains(lower(filename), 'timeout')
        daytype = 'Timeout';
    end
    matches = matches{1};
    mouseid = matches{1};
    day = matches{2};
    fid = join([ mouseid, daytype "day", day ]);
end

function addUnifiedYLabel(h1, h2, name)
	p1 = get(h1,'position');
    p2 = get(h2,'position');
    height = p1(2)+p1(4)-p2(2);
    axes('position',[p2(1) p2(2) p2(3) height],'visible','off');
    ylabel(name,'visible','on');
end

        