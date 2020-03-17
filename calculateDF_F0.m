function df_f0 = calculateDF_F0(rawData)
    time = rawData(:, 1);
    df_f0 = time;
    dataColIndexes = [2, 3]; % Depending how it has been saved from DNS, the first number should be the column index of the reference, and the second one the index of the calcium signal. Change as needed.
      for colIdx = dataColIndexes(1):dataColIndexes(2) %actual calculation of DF/F0
        data = rawData(:, colIdx);
        reg = polyfit(time, data, 1);
        f0 = reg(1)*time + reg(2);
        df_f0_tmp = (data - f0)./f0 * 100;
        df_f0 = horzcat(df_f0, df_f0_tmp);
      end
         
end