%% rick_actions_heatmaps_all_phases_v4

%v4: edited for 2019-14
%v3: Adding back in mean/sem compiling for prism, also changed to jet
%v2: changing labeling+numbering for publication.

% built from rick_2019_06_means_heatmaps_all_phases_v3
%to merge 2018-07 in with it


%v3 make sure the arrays get cleared
%v2 making heatmaps that are in line with tone_to_poke maps

%Removed this SEM stuff so heatnumbers just becomes the variable
%Note: this has remnants of from when I was plotting mean data in Prism.
%The action arrays are actually twice as large as number of days, with each
%first column being mean and second column being the SEM. They heatmaps use
%indexing that accounts for this when making heatnumbers variable

%Copy of heatmaps_sep_by_phase_Ribicoff
%mod'd to put all phases together


%% clear
clear

% exp = '2018-07';
exp = '2019-14';

codename = 'rick_actions_heatmaps_all_phases_v4';
%% Set folder/files


if strcmp(exp,'2019-14')
    
    folder = 'C:\Users\User\Google Drive\2019-14\Doric\Processed\MATLAB\MATLAB Outputs\Individual Day Graphs\MATLAB vars' ;
    
    load([folder '\current_mean_sem.mat'])
%     load([folder '\indiv_graph_data.mat'])
    
    
    outputfolder = 'C:\Users\User\Google Drive\2019-14\Doric\Processed\MATLAB\MATLAB Outputs\Summary Graphs by action';
    outputfile = 'MATLAB means+sem for prism';
    timestampfile = 'C:\Users\User\Google Drive\2019-14\timestamp.xlsx';
    
    skips = ["0849 Timeout Day 09"; "0849 Timeout Day 11"; "0856 ZExtinction Day 01"];
    
    
elseif strcmp(exp,'2018-07')
    
    folder = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\Individual Day Graphs' ;
    
    load([folder '\2018-07 App MATLAB graph data 08-Nov-2019_rick_mean_SEM..._v3.mat'])
    
    outputfolder = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\Doric\Processed\2018-07 App MATLAB\Summary Graphs';
    outputfile = '2018-07 MATLAB means+sem for prism';
    timestampfile = 'C:\Users\User\Google Drive\2018-07 BLA Fiber Pho\timestamp.xlsx';
    
    skips = ["HB03_Timeout_Day_12"; "HB04_Timeout_Day_11"; "HB05_Timeout_Day_09"; "HB06_Timeout_Day_09";  "HB06_Timeout_Day_11"; "HB08_Timeout_Day_12"];
    
end




%Groups
gach = [1012 176 178 129 124];
rcamp_gach = [849 850];
camkii_gcamp = [177 179 130];
gad_gcamp = [1153 1159 1160];
NBM_BLA = [851 852 856 860];

%file to skip


variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
prism_variables = ["p_correct" "p_tone" "p_incorrect" "p_receptacle" "p_randrec" "p_tonehit" "p_tonemiss" "p_inactive"];

%import timestamp
time = xlsread(timestampfile);
graphtime = time;

%initialize
data_mouse_ID = zeros(size(datanames,1),1);



if strcmp(exp,'2019-14')
    
    %prep for cut down data to just one mouse
    
    for ii = 1:size(datanames,1)
        data_mouse_ID(ii) = str2double(datanames{ii}{1}(8:11));
    end
    
    all_mouse_ID= unique(data_mouse_ID);
    
    
    
    %for drawing white line
%     rew_threshold = ["813_Timeout_Day_20"; "814_Timeout_Day_17"; "820_Timeout_Day_19"; "827_Timeout_Day_18"];
    
    
elseif strcmp(exp,'2018-07')
    %prep for cut down data to just one mouse
    
    for ii = 1:size(datanames,1)
        data_mouse_ID(ii) = str2double(datanames{ii}{1}(11));
    end
    
    all_mouse_ID= unique(data_mouse_ID);
    
    
    %for drawing white line
    rew_threshold = ["3_Timeout_Day_08"; "4_Timeout_Day_08"; "5 was dud"; "6_Timeout_Day_13"];
    
    
end




%% cut down data to just one mouse
for num = 1:size(all_mouse_ID,1)
%     for num = 8
    %     for num = [4 5 7 8]
    % for num = 1:4
    % for num = 1:mice
    
    %Define mouse_ID number for the run of the for loop
    mouse_ID = all_mouse_ID(num);
    
    %What indicator is it?
        %doing this later instead
    
    %Cut down raw to just current mouse
    %Index all rows with mouse_ID and select those rows from graphdata
    
    mousemean = graphmean((data_mouse_ID(:,1) == mouse_ID),:);
    mousesem = graphsem((data_mouse_ID(:,1) == mouse_ID),:);
    mousenames = datanames((data_mouse_ID(:,1) == mouse_ID),:)';
    
    %not using data var anymore
%     mousedata = graphdata((data_mouse_ID(:,1) == mouse_ID),:);
    
    %making trimmed___ be equal to mouse___ to not have to change as much
    %coe
    %trim to training phase
    
    trimmedmean = mousemean;
    trimmedsem = mousesem;
    trimmednames = mousenames;
    
    %not using data var anymore
%     trimmeddata = mousedata;
    
    
    
    
    
    %% Make arrays for each mouse, across days
    
    %variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
    
    %need to check the flow of the loops,
    
    %initialize arrays
    %     correct = NaN(size(trimmedmean{1,1},1), size(trimmedmean,1)*2);
    %     tone = correct;
    %     incorrect  = correct;
    %     receptacle = correct;
    %     randrec = correct;
    %     tonehit = correct;
    %     tonemiss = correct;
    %     inactive = correct;
    
    
    clear correct tone incorrect receptacle randrec tonehit tonemiss inactive day_align_filenames day_label
    
    %        for action = [1 3 4 6]
    for action = 1:size(trimmedmean,2)
        
        %use day_counter to prevent black bar when skipping days
        day_counter = 0;
        
        for file = 1:size(trimmedmean,1)
            
            
            %skip shitters
            if any(strcmp(trimmednames{file}{1}(8:end-5),skips))
                
                
                continue
                
            else
                
                day_counter = day_counter+1;
                
                if action == 1
                    %determine the day of mice
                    day_align_filenames{day_counter,1} = trimmednames{1,file}{1};
                    day_label{day_counter,1} = trimmednames{1,file}{1}(end-6:end-5);
                    p_day_align_filenames{day_counter*2-1,1} = trimmednames{1,file}{1};
                    p_day_align_filenames{day_counter*2,1} = [];
                end
                
                %if that action didn't happen that day, just put NaN's
                if isempty(trimmedmean{file,action})
                    
                    
                    eval([variables{action}, '(:,day_counter) = NaN(1832,1);']);
                    eval([prism_variables{action}, '(:,day_counter*2-1) =  NaN(1832,1);']);
                    eval([prism_variables{action}, '(:,day_counter*2) = NaN(1832,1);']);
                    
                    %put the meandata in the action variable
                else
                    %Fill in mean
                    
                    %e.g. correct(:,file) = ...
                    eval([variables{action}, '(:,day_counter) = trimmedmean{file,action};']);
                    
                    
                    %fill in mean/sem for prism variables
                    %doing this with day_counter like above instead of
                    %NaNs because I'll transfer over row titles too
                    %instead of bulk copying (with blanks created by
                    %NaNs) like before
                    eval([prism_variables{action}, '(:,day_counter*2-1) = trimmedmean{file,action};']);
                    
                    %fill with NaNs if SEM is all 0 (meaning only one
                    %trial)
                    if sum(trimmedsem{file,action})==0
                        eval([prism_variables{action}, '(:,day_counter*2) = NaN(1832,1);']);
                    else
                        
                        %fill in SEM
                        eval([prism_variables{action}, '(:,day_counter*2) = trimmedsem{file,action};']);
                    end
                    
                    
                end
            end
        end
    end
    
    %% Find start day of phases
    %Find all the days that are Timeout
    timeout_test = strfind(day_align_filenames,'Timeout');
    
    %find the first non-empty cell and set that index to TO
    TO = find(~cellfun(@isempty,timeout_test),1);
    
    %Find all the days that are Ext
    if strcmp(exp,'2019-14')
        
        Ext_test = strfind(day_align_filenames,'ZExtinction');
        
    elseif strcmp(exp,'2018-07')
        Ext_test = strfind(day_align_filenames,'ZZExt');
        
    end
    
    %find the first non-empty cell and set that index to TO
    Ext = find(~cellfun(@isempty,Ext_test),1);
    


%pull back in when needed
    %Find the rew_thresh day
    %indexing by the num of GACh mouse, into the rew_threshold array that
    %has the full names for the threshold days, similar to above but
    %looking for a specific day, not just one
    
%     if any(mouse_ID == BLA_GACh)
%         rew_thresh_test = strfind(day_align_filenames,rew_threshold(GAChnum));
%         
%         rew_thresh_day = find(~cellfun(@isempty,rew_thresh_test),1);
%         
%     end
%     
%     if mouse_ID == 3 || mouse_ID ==4
%         rew_thresh_test = strfind(day_align_filenames,rew_threshold(BLAGCaMP_num));
%         
%         rew_thresh_day = find(~cellfun(@isempty,rew_thresh_test),1);
%         
%     end
    
    
    %%  Make heatmap
    
    for idx = 1:size(variables,2)
        %pull out the means into the heatnumbers variable for plotting
        %example: heatnumbers = proper(:,1:2:end)'; Note: had to break
        %this into two lines bc couldn't get an apostrpohe in the eval
        %to work.
        eval(['heatnumbers =' variables{idx} ';']);
        heatnumbers = heatnumbers';
        
        %variables = ["correct" "tone" "incorrect" "receptacle" "randrec" "tonehit" "tonemiss" "inactive"];
        

        %if statement to change clims based on indicator
        if any(mouse_ID == gach)
            indicator = 'GACh';
            climits = [-3 7];
            
            
        elseif any(mouse_ID == rcamp_gach)
            indicator = 'RCaMP + GACh';
            climits = [-3 7];
            rcamp_climits = [];
            %         climits = [-3 7];
            %         GAChnum=find(BLA_GACh==mouse_ID);
            
        elseif any(mouse_ID == camkii_gcamp)
            indicator = 'CaMKII-GCaMP';
            climits = [-2 4];
            %         climits = [-3 7];
            %         GAChnum=find(BLA_GACh==mouse_ID);
            
        elseif any(mouse_ID == gad_gcamp)
            indicator = 'Gad65-GCaMP';
            climits = [-3 4];
            %         climits = [-3 7];
            %         GAChnum=find(BLA_GACh==mouse_ID);
            
        elseif any(mouse_ID == NBM_BLA)
            indicator = 'NBM-BLA';
            climits = [-2 6];
            %         climits = [-3 7];
            %         GAChnum=find(BLA_GACh==mouse_ID);
            
        end
        
        
%          figure
        figure('Visible', 'off')
        cf = imagesc(graphtime,1, heatnumbers, climits);
        
        colormap jet
        nanmap = [0 0 0; colormap];
        colormap(nanmap);
        
        ax = gca;
        xlim([-5 5]);
        ax.TickDir = 'out';
        ax.XAxis.TickLength = [0.02 0.01];
        ax.XAxis.LineWidth = 1.75;
        
        %add y ticks and labels, just sep phases
%         ax.YTick = [0.5 TO-0.5];
%         yline(TO-0.5, 'LineWidth', 1.75);
%         ax.YTickLabel = {'Cued', 'TO'};
        
        
        %add y ticks/labels for just the day
       ax.YTick = 1:size(day_label,1);
       ax.YTickLabel = day_label;
       yline(TO-0.5, 'LineWidth', 1.75);
       
       if ~isempty(Ext)
           yline(Ext-0.5, 'LineWidth', 1.75);
       end
        
        %bring back in and mod when needed
        %TO and Ext change based on when the different phases happened
        
%         %lines to draw/label if BLA_GACh
%         if any(mouse_ID == BLA_GACh)
%             ax.YTick = [0.5 TO-0.5 rew_thresh_day - 0.5  Ext-0.5];
%             yline(TO-0.5, 'LineWidth', 1.75)
%             yline(Ext-0.5, 'LineWidth', 1.75)
%             yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.75)
%             
%             ax.YTickLabel = {'Cued', 'TO', 'Acq.','Ext.'};
%             
%             %lines to draw/label for non-BLA_GACh
%             
%         elseif mouse_ID == 3 || mouse_ID ==4
%             %             ax.YTick = [0.5 TO-0.5 rew_thresh_day - 0.5  Ext-0.5];
%             yline(TO-0.5, 'LineWidth', 1.25)
%             yline(Ext-0.5, 'LineWidth', 1.25)
%             yline(rew_thresh_day - 0.5 , 'w', 'LineWidth', 1.25)
%             
%             %             ax.YTickLabel = {'Cued', 'TO', 'Acq.','Ext.'};
% 
%             
%         else
%             ax.YTick = [0.5 TO-0.5 Ext-0.5];
%             yline(TO-0.5, 'LineWidth', 1.25)
%             yline(Ext-0.5, 'LineWidth', 1.25)
%             
%             ax.YTickLabel = {'Cued', 'TO', 'Ext'};
%             
%         end
%         
        
        
        set(gca,'YDir','normal')
        
        %remove yticks and yticklabels
%         set(gca,'ytick',[])
%         set(gca,'yticklabel',[])
        
        
                title([ indicator ' ' num2str(mouse_ID) ' ' variables{idx}],'fontsize',16)
        %         ylabel('Training Day','fontsize',16)
        %         xlabel('Seconds from event onset','fontsize',16)
        cb = colorbar;
        ylabel(cb, 'Z %\DeltaF/F0' ,'fontsize',16)
        xticks([-4:2:4]);
        
        
        
        
        print([outputfolder '\' indicator  '\' indicator ' ' num2str(mouse_ID) ' ' variables{idx}], '-dpng');
        
        
        close all
        
        
    end
    
    %write to xlsx file
    
    p_day_align_filenames = p_day_align_filenames';
    
    for idx = 1:size(prism_variables,2)
        eval([prism_variables{idx},' = [p_day_align_filenames; num2cell(', prism_variables{idx}, ')];']);
        writecell(eval(prism_variables{idx}), [outputfolder '\' indicator  '\' indicator ' '  num2str(mouse_ID) ' ' outputfile '.xlsx'], 'Sheet', prism_variables{idx});
    end
    
    
    
    clear day_align correct tone incorrect receptacle randrec tonehit tonemiss inactive day_align_filenames day_label
    clear p_correct p_tone p_incorrect p_receptacle p_randrec p_tonehit p_tonemiss p_inactive p_day_align_filenames
    
end


%print the version of the code used
fileID = fopen([outputfolder '\' date 'codeused.txt'],'w');
fprintf(fileID, codename);