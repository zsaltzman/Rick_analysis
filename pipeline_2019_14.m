clear; clc;

% designate a subset of files to process (or leave it empty to process all)
% TODO: Make this a number or the indicators a string?
%FP_PROC_SUBSET = [ "0129", "0124" ];
FP_PROC_SUBSET = []

% change these to the relevant locations on your disk
FP_RAW_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\Hao'; % raw file directory
FP_PROC_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\hao proc'; % destination for processed files
FP_RAW_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\raw graph (of hao)';
FP_PROC_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\proc graph (of hao)';

% FP_RAW_FILE_DIR = 'C:\Users\zls5\Desktop\2020-03 Raj\Handling'; % raw file directory
% FP_PROC_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\rick handling proc'; % destination for processed files
% FP_RAW_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\raw handling graph (of rick)';
% FP_PROC_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\proc handling graph (of rick)';

FP_INDICATOR_IDS = {
    % [ 124, 129 ], 'GACh';
};

Basic_FP_processing_2019_14_v4
    %takes raw files and turns them into processed (calculates corrected df/f0,
    %while keeping the individual channel ones too)

% FP_Compile_2019_14_v3
    %integrates MedPC and Doric data. Yields:
        %1) rawtoghether and filenames saved as .mat file, with options to save
        %all at once or do it day by day
        %2)Saves the MATLAB_... .xlsx files with the doric signal 5 sec prior and 
        %10 sec after actions of interest, separated into sheets. 
        %3) grabs rcamp col for those mice
        %Requires:
            %1) PROCESSED_... excel files from above
            %2) ... MedPC Full file that was generated from MPC2XL program
        %Options:
            %1) Can change it to import corrected or plain signal df/f0 columns
        %To Do: 
            %rerun rcamp mice and get the full deal 


FP_2019_14_prelim_graphs_raw_v2
    %Plots the raw Ch1 and 2 and a zoomed in graph

FP_2019_14_prelim_graphs_v2
    %plots the individual df/f0's for ref and sig, as well as the corrected
    %trace, both zoomed and full

% rick_mean_SEM_calc_indiv_plots_v5
    %1)makes mean and sem variables from the MATLAB_...xlsx files and saves
    %those variables for action heatmaps script
    %2)plots the individual traces/heatmaps for each mouse, each day, each
    %action

% combine_mean_sem
    %combines the mean, sem, and filenames vars for day to day data 
    
% rick_actions_heatmaps_all_phases_v4
    %makes action summary heatmaps across days and saves excel files for
    %prism plotting

% combine_rawtogether_filenames
    %combines rawtogether and filenames vars for day to day data
    
% rick_tone_poke_rec_heatmaps_by_mouse_v3
    %makes tone_poke_rec heatmaps from rawtogether and filenames
    
%Manually: move processed and raw to extracted folders

