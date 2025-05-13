function  task_metadata = getStimulus( stim )

global dbpar

if nargin == 0
     return
end

Database = dbpar.Database;  %= yourlab
query = eval([Database '.Stimulus']);
stimSel = ['stimulusid= "' stim '"'];

md = fetch(query & stimSel, 'stimulusid', 'shortdescr', 'longdescr');
source = '';
if isfile(which(md.stimulusid))
    source = fileread(which(md.stimulusid));
else
    disp("Path to stimulus presentation mfile is required!!")
end

if isempty(md.longdescr)
    disp("Please add a task description!!!")
end

task_metadata = struct( 'task_name', md.stimulusid, 'task_shortdescr', md.shortdescr, 'task_description', md.longdescr, 'source', source );