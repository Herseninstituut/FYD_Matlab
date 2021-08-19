# Follow Your Data (FYD) for matlab
A library of scripts to index global metadata automatically, and make data web/machine searchable.

You can inspect the database here (Nederlands Hersen Instituut - Follow Your Data, __but only from within the intranet of our institute__):
[nhi-fyd/](https://nhi-fyd.nin.knaw.nl/)

Notifications about FYD_MAtlab will also appear in our micrsoft teams data management channel.

***
#### Getting started ####

* Clone/download this repository to your local machine and add the root folder and the mysql folder to your Matlab path. 
* Add jsonlab if you are running Matlab older than 2017b.
* Obtain a credentials file from your systems manager (me).
* Create a subfolder in FYD_Matlab called `par` and copy your lab-based credentials file (`nhi_fyd_XXparms.m`) there.
* Use ```getFYD()``` to create a basic json structure with all the required fields.
* Store 1 json file with each recording session (for example, each block) in a separate folder.
* Always keep the json files together with your data.
* A server script automatically indexes the json files and keeps an up to date list of urls to your data.
* Do not put spaces in your folder names.
* You may need to install [vc_redist.x64.exe](https://support.microsoft.com/en-us/topic/the-latest-supported-visual-c-downloads-2647da03-1eea-4433-9aff-95f26a218cc0) if you see an error such as; "Invalid MEX-file....: The specified module could not be found." (Be aware that you need administrator rights to install this.)

***
## Using getFYD to create session.json files.

Getdbfields is now replaced by **getFYD**.  GetFYD is easier to use and will generate a JSON file at the location of your choice.
GetFYD is a wrapper for a matlab app, that automatically generates a sessionid based on subjectid, date and sessionnr.
Simply run getFYD to enter and select your identifiers for projects, datasets, conditions, subjects and stimuli.

## JSON file text template of required fields
```
{
	"version": "1.0",
	"project": "Ach",
	"dataset": "ActiveGo",
	"date": "20210416",
	"subject": "Andy",
	"investigator": "Cor",
	"setup": "EphysSmall",
	"condition": "awake",
	"stimulus": "NoStim",
	"logfile": "Andy_20210416_1_log",
 }
```
***
### Example mfile to create ID_session.json files using getdbfields

```Matlab
% getdbfields creates a json structure that includes the required fields for storing a
% session into the database
json = getdbfields('LAB');   %'MVP' for Leveltlab , 'VC' for Roelfsemalab;

% You need to come up with an ID for your session, for example:
% ID = Subject_Date_Sessionnr (which would look like: 'Abc_01082018_001').
% It is a good idea to use this ID in the filename of each datafile associated with this dataset.
% for example, prepend it to your log file name:

json.logfile ='ID_log.mat'; %name for your logfile :

% you can add comments, for example to give some information about how well your monkey/mouse
% worked on this particular day. This information will also show up on nhi-fyd/index.php.
json.comment = 'This is up to you; Add some comments';

% you can add as many extra fields as you want, with whatever information you find useful.
json.blablablafield = 'blablabla';

% Store the datafile along with the data: it is very important that the filename of your json file
% ends in '_session.json'!! The server will not index your json file if you don't do this. It is
% also crucial to store your json files in the same place as your data, because the URL to the json
% file will be stored in the database, as a reference to where the data is.
savejson('', json, 'strpath\ID_session.json');

% ALTERNATIVELY: if you are running a new version of matlab and don't want to use the jsonlab library:
StrJson = jsonencode(json);
save('test1.json', 'StrJson')
````
Since Matlab 2017b, you can use ```jsonencode()``` to create a json object. Prior to Matlab 2017b, you need to use ```savejson()```, which you will find inside jsonlab (included in this repository).

***
The outcome of the indexing is reported in a log with html format that can be visualized in your browser. For each Lab a link to an error log is provided on the webapp in the menu of the inlog page. It is important to check this log, it will report errors when values in a json file are not consistent with registered identifiers. To make it easier for users to interpret the errors and fix them, the script ```ParseErrorLog``` can be used.

#### ParseErrorLog usage ####
Copy the url to the log from your browser and adapt the script to always use this url.  It generates a table with the record values and the field that caused the error for each json file that failed to get indexed.
***

### dj (datajoint tools) GetDouble_JSONS.mlx and importandgenerate.mlx
These additional tools are supplied to give you a headstart using datajoint to manage your database : https://docs.datajoint.io/
Datajoint is an addon in matlab and a module in python. It requires a class folder with table definitions (an example, for our test database, is included)

```GetDouble_JSONS``` Checks for double entries. In some cases users copy their data to more than one location, leading to records with urls to both locations in the database. You can use this info to remove superfluous data, or to remove the jsonfiles.

```importandgenerate``` Helps to generate identifiers and json files for datasets not yet associated with json files. Usually because json files were not generated at the time of data collection. Users should first fill in an excel sheet with the required information for each instance (path, project, dataset, subject, stimulus, condition, setup, investigator, sessionid, date) that will require a json file. (see example)


```
% EXAMPLE USING DATAJOINT
% import credentials from your parameter file
dbpar = nhi_fyd_LABparms();

setenv('DJ_HOST', dbpar.Server)
setenv('DJ_USER', dbpar.User)
setenv('DJ_PASS', dbpar.Passw)

Con = dj.conn();
% Database = dbpar.Database;  = yourlab


%% first construct a query
% here simply for all in the table
qproj = yourlab.Projects;

% then you fetch, including extra fields the records you want to retrieve (see table
% definitions)
Projects = fetch(qproj, 'entrydate', 'status')


% here from the sessions table with a selection clause (:which project)
% but this could also be a dataset, a subject, a condition, a date
qsess = yourlab.Sessions & 'project="testProject"';
%now retrieve the sessions you want and the url field
sessions = fetch(qsess, 'url')

%% Process urls to windows path
P = arrayfun(@(x) fullfile(strrep(x.url, 'mnt', '')), sessions, 'UniformOutput', false)
```
