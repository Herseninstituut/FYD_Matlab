function initDJ(lab)
% initDJ(lab)
%input : name of your lab's database: 

p = mfilename('fullpath');
filepath = fileparts(p);

%% Check if Datajoint schema exists for this lab, if not create.
if ~exist(fullfile(filepath,['+' lab]), 'dir')
    % copy the yourlab template and rename yourlab in each text file
    src=fullfile(filepath,'+yourlab');
    dest=fullfile(filepath,['+' lab]);
    mkdir(dest)
    copyfile(src, dest)
    files = dir(dest);
    for i=1:length(files)
        if ~files(i).isdir
            fn = fullfile(dest, files(i).name);
            text = fileread(fn);
            if contains(text, 'yourlab')
                text = replace(text, 'yourlab', lab);
                fid = fopen(fn , 'w');
                fwrite(fid, text);
                fclose(fid);
            end
        end
    end
end

global dbpar

%% get credentials file from data manager and rename or uncomment for your lab, 
%dbpar = nhi_fyd_parms();
dbpar = nhi_fyd_VCparms();
%dbpar = nhi_fyd_MVPparms();
if ~strcmp(lab, dbpar.Database)
    errordlg('You do not have the correct credentials')
    return
end

setenv('DJ_HOST', dbpar.Server)
setenv('DJ_USER', dbpar.User)
setenv('DJ_PASS', dbpar.Passw)

Con = dj.conn();