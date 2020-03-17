
% Makes a directory specified by MDIR_DIRECTORY_NAME with some basic error
% handling
[status, msg, msg_id] =  mkdir(MDIR_DIRECTORY_NAME);
dir_status = status; dir_msg = msg; dir_msg_id = msg_id;
if contains(dir_msg_id, 'DirectoryExists')
    % fprintf('Directory %s detected, continuing...\n', MDIR_DIRECTORY_NAME);
else
    fprintf('Created directory %s\n', MDIR_DIRECTORY_NAME);
end