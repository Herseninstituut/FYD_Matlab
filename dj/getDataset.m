function  dataset_meta = getDataset( project, dataset )

global dbpar

if nargin == 0
     return
end

Database = dbpar.Database;  %= yourlab

query = eval([Database '.Datasets']);
dsetSel = ['project= "' project '" AND datasetid= "' dataset '"'];
dataset_meta = fetch(query & dsetSel, 'shortdescr', 'longdescr');

query = eval([Database '.Projects']);
projSel = ['projectid= "' project '"'];
proj_meta = fetch(query & projSel, 'author', 'shortdescr', 'longdescr', 'department_name');

dataset_meta.author = proj_meta.author;
dataset_meta.institution_department_name = proj_meta.department_name;

% if values for short and long description are empty 
% use project values(if these are empty too 
% you should have doen your RDM properly!!.
if isempty(dataset_meta.shortdescr)
    dataset_meta.shortdescr = proj_meta.shortdescr;
end

if isempty(dataset_meta.longdescr)
    dataset_meta.longdescr = proj_meta.longdescr;
end