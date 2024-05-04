function  stim_metadata = getStimulus( stim )

global dbpar

if nargin == 0
     return
end

Database = dbpar.Database;  %= yourlab
query = eval([Database '.Stimulus']);
stimSel = ['stimulusid= "' stim '"'];

stim_metadata = fetch(query & stimSel, 'stimulusid', 'shortdescr');

