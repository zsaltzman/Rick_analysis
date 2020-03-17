function data = subtractReferenceAndSave_2019_14_rcamp(df_f0, directory, filename, DIO, df_f0_rcamp)
  subtractedData = df_f0(:, 3) - df_f0(:, 2);
  data = horzcat(df_f0, subtractedData,DIO, df_f0_rcamp);
  cHeader = {'Time' 'Reference (DF/F0)' 'Ca2+ Signal (DF/F0)' 'Corrected' 'DIO' 'DF/F0 RCaMP'};
  commaHeader = [cHeader;repmat({','},1,numel(cHeader))];
  commaHeader = commaHeader(:)';
  textHeader = cell2mat(commaHeader);
  textHeader = textHeader(1:end-1);
  filename_w = strcat(directory,'\','PROCESSED_', filename); %so basically all it does is to take the raw data and saves the corrected signal with a filename preceded by "processed_" (to avoid overwriting the original file... and the other function calls for that
  fid = fopen(filename_w,'w'); 
  fprintf(fid,'%s\n',textHeader);
  fclose(fid);
  dlmwrite(filename_w, data, 'delimiter', ',', '-append', 'precision','%.5f'); 
end