% designate a subset of files to process (or leave it empty to process all)
FP_PROC_SUBSET = [ "103119" ];
% FP_PROC_SUBSET = [ "0124", "0129" ];

% change these to the relevant locations on your disk
FP_RAW_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\Alexa reformatted';
FP_PROC_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\Alexa Processed';
FP_RAW_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\raw graph (of alexa)';
FP_PROC_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\proc graph (of alexa)';
FP_ANNOTATED_FILE = 'C:\Users\zls5\Desktop\Zach\Stuff Rick Just gave me 2-18\Full\2019-14 MedPC Full.xlsx'

% FP_RAW_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\raw files'; % raw file directory
% FP_PROC_FILE_DIR = 'C:\Users\zls5\Desktop\Zach\Processed'; % destination for processed files
% FP_RAW_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\raw graph (of rick)';
% FP_PROC_GRAPH_DIR = 'C:\Users\zls5\Desktop\Zach\proc graph (of rick)';

ALEXA_GRAPH_DIR = "C:\Users\zls5\Desktop\Zach\Alexa movement graphs";
ALEXA_SUSFILES = [ "103119" ];
ALEXA_IMPFILES = [ "111819" ];

FP_INDICATOR_IDS = {
    [ 103119, 111819 ], 'Norep';
};
Basic_FP_processing_2019_14_v4
    %takes raw files and turns them into processed (calculates corrected df/f0,
    %while keeping the individual channel ones too)
    
% Alexa_norep_parsing
Rick_modified_pipeline

FP_2019_14_prelim_graphs_raw_v2
    %Plots the raw Ch1 and 2 and a zoomed in graph

FP_2019_14_prelim_graphs_v2
    %plots the individual df/f0's for ref and sig, as well as the corrected
    %trace, both zoomed and full