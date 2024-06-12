function Con = initDJ(lab)
% Con = initDJ(lab)
% input : name of your lab's database: 
% Chris van der togt, 2024

p = mfilename('fullpath');
filepath = fileparts(p);

% Get the parent directory => fyd_matlab and addpath relevent subdirectories
cstr = strsplit(filepath, '\');
ln = length(cstr);
fyd_path = char(join(cstr(1:ln-1), '\'));
addpath(fyd_path, ...
        [fyd_path '\dj'], ...
        [fyd_path '\ophys'], ...
        [fyd_path '\par'], ...
        [fyd_path '\YAML'] )

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

%% get credentials file from data manager if this fails, 

dbpar = getlab(lab);
if isempty(dbpar)
    return
end

setenv('DJ_HOST', dbpar.Server)
setenv('DJ_USER', dbpar.User)
setenv('DJ_PASS', dbpar.Passw)

Con = dj.conn();


function dbpar = getlab(strlab)

% a struct to relate database name to abbreviation in parameter file.
    labs = struct( 'roelfsemalab', 'VC', 'leveltlab', 'MVP', ...
                   'heimellab', 'CSF', 'lohmannlab', 'SND', ...
                   'kolelab', 'AXS', 'willuhnlab', 'NandB', ...
                   'socialbrainlab', 'SBL', 'dezeeuwlab', 'CCC', ...
                   'vansomerenlab', 'SandC', 'siclarilab', 'SandD', ...
                   'saltalab', 'NandN', 'verhagenlab', 'NRG', ...
                   'kalsbeeklab', 'HYP', 'huitingalab', 'IMM' );
    
    lab = labs.(strlab);
    dbpar = [];

    prmfile = ['nhi_fyd_' lab 'parms'];
    if exist(prmfile, 'file')
        dbpar = eval(prmfile);
    else 
        errordlg(["No parameterfile found for: " strlab "."...
          "Please contact Chris van der Togt to obtain this file." ...
          "email:c.vandertogt@nin.knaw.nl"], 'Warning')
    end