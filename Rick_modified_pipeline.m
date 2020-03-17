clear; clc;

% designate a subset of files to process (or leave it empty to process all)
% TODO: Make this a number or the indicators a string?
%FP_PROC_SUBSET = [ "0129", "0124" ];
FP_PROC_SUBSET = []

% change these to the relevant locations on your disk
FP_RAW_FILE_DIR = 'C:\Users\zls5\Desktop\Rick Modified Pipeline Files\Rick Doric Data 12-4-19'; % raw file directory
FP_PROC_FILE_DIR = 'C:\Users\zls5\Desktop\Rick Modified Pipeline Files\rick proc'; % destination for processed files
FP_PROC_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\proc tone graph (of rick)';
FP_COMPILE_OUTDIR = 'C:\Users\zls5\Desktop\Rick Modified Pipeline Files\Compiled'
FP_ANALYSIS_OUTDIR = 'C:\Users\zls5\Desktop\Rick Modified Pipeline Files\Analysis'
FP_COMPILE_MATLAB_VARS = 'MATLAB vars';

FP_ANNOTATED_FILENAME = 'C:\Users\zls5\Desktop\Rick Modified Pipeline Files\2019-14 MedPC Full.xlsx';

% Determined the MedPC index of each data by examining the sheet manually.
% B is proper nose pokes
% K is tone counter
% H is reward time
FP_SHEET_NAME = 'tone';
FP_FIRST_COL_INDEX = 'K(0)';
FP_FIRST_COL_NAME = "Tone Counter"; % Name of the column that contains the number of data points recorded in the B's (for MedPC)

FP_INDICATOR_IDS = {
    % [ 124, 129 ], 'GACh';
};

%takes raw files and turns them into processed (calculates corrected df/f0,
%while keeping the individual channel ones too)
Basic_FP_processing_2019_14_v4
    
% FP_Compile_2019_14_v3

% Rick_modified_norep_parsing

FP_tonehit_analysis



