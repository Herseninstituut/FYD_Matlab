# Follow Your Data (FYD) for matlab [![DOI](https://zenodo.org/badge/342855808.svg)](https://zenodo.org/badge/latestdoi/342855808)
A library of scripts to create session.json files, and retrieve metadata from the FYD database. The session.json files are used as persistent identifiers to data objects and provide the searchable metadata to the FYD database. Once they have been created by a user and saved with the data of a single recording session on our storage server (VS03), they are automatically processed by a filesystemwatcher script. This script saves the session.json metadata and it's url to a record in a database.  
Changes in the content and location of these session.json files are detected by the filesystemwatcher and the database is then automatically updated, hence the name Follow Your Data (FYD).

Each lab has it's own database. You can inspect the contents of these databases here (Nederlands Hersen Instituut - Follow Your Data, __but only from within the intranet of our institute__):
[nhi-fyd/](https://nhi-fyd.nin.knaw.nl/)

Hundreds of json files may be saved for a single project. However, the name of a project and other identifiers should be consistent across a dataset to support searchability. To enforce consistency, users are required to create valid identifiers from a user interface (UI). When users create their json files thay should only select items from these previously generated options. When metadata is added to the database, the filewatcher script checks whether the input values have been registered in advance.  
If users do not use these UIs to create valid identifiers, session.json files may generate errors after being placed on our storage server because the indexing script finds that some identifiers have not been registered in advance. As a user you can verify this by looking at the log on the FYD website. Each lab has a log file to check the consistency of it's database, which can be viewed after logging in.

Each session.json file has a unique identifier (ID). This is included in the name of the file; ID_session.json. If two or more session.json files have the same ID, this will also be rejected and generate an error in the log file.


***
#### Getting started

* Clone/download this repository to your local machine and add the root folder and the mysql folder to your Matlab path. 
* Add jsonlab if you are running Matlab older than 2017b.
* Obtain a credentials file from your systems manager.
* Create a subfolder in FYD_Matlab called `par` and copy your lab-based credentials file (`nhi_fyd_XXparms.m`) there.
* Use ```getFYD()``` to create a basic json structure with all the required fields.
* Store 1 json file with each recording session (for example, each block) in a separate folder.
* Each json file should have a unique name consisting of an id (subject_data_sessnr
* Always keep the json files together with your data.
* Do not put spaces in the folder names and identifiers you create for your json files.
* You will likely need to install [vc_redist.x64.exe (2015-2022)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170).  Particularly, if you see an error such as; "Invalid MEX-file....: The specified module could not be found." (Be aware that you need administrator rights to install this.)

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


<img src=images/dbgetfields.png>

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
json.foo = 'bar';

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

GetDouble_JSONS.mlx and importandgenerate.mlx are two additional tools to manage your database
```GetDouble_JSONS``` Checks for double entries. In some cases users copy their data to more than one location, leading to records with urls to both locations in the database. You can use this info to remove superfluous data, or to remove the jsonfiles.

```importandgenerate``` Helps to generate identifiers and json files for datasets not yet associated with json files. Usually because json files were not generated at the time of data collection. Users should first fill in an excel sheet with the required information for each instance (path, project, dataset, subject, stimulus, condition, setup, investigator, sessionid, date) that will require a json file.  
***
## How to make json files for an existing dataset ##
Organize your data according to the NIN  [data protocol](https://herseninstituut.sharepoint.com/sites/RDM/SitePages/FAIR-data.aspx)  first.
Each recording session with associated metadata should be in a separate folder. Ideally, the filename of each file, should contain sessionid of the containing folder.
Here is an example, according to the recommended schema: project/data_collection/dataset/subject/session

~~~
L5_Tuftapicsoma
  /data_collection
	/Passive
		/Pollux
			/20200323_003  
				Pollux_20200323_003.mat
				Pollux_20200323_003.sbx
				Pollux_20200323_003_eye.mat
				Pollux_20200323_003_log.mat
				Pollux_20200323_003_realtime.mat
				Pollux_20200323_003_session.json
~~~

Whether you have ordered your data this way or not, make an excel sheet with the neccessary metadata to automatically generate the json files at the appropriate locations. jsontemplate.xlsl contains columns for each required field.  

<img src=/images/excel.png >

When your list is complete, generate the json files with : **Generatejsonfiles.m** and the json files will be saved at the provided path locations. If you have done this correctly, your json files will automatically show up on the website. Be sure to register all your projects, datasets, subjects, conditions , stimuli, setups in the database befor you save the json files. Otherwise you will get foreign constraint errors.

***
## Find and Retrieve urls
In the background getFYD and getdbfields use mysql.mexw64, This is Microsoft visual studio compiled C code to a matlab mex function.  
Examples of it's use can be found in getdbfields;  
    dgc = mysql('open', dbpar.Server, dbpar.User, dbpar.Passw);  
    dbdb = mysql('use', dbpar.Database);  
    projects = mysql('SELECT projectid FROM projects');  
mysql can be called with standard sql queries.

(Matlab has its own mysql client since 2020, which can also be used to access a mysql database but its usage differs from this implementation.)

### Using Datajoint (dj) to access and retrieve metadata
Datajoint makes it a lot easier to access and retrieve data from the FYD database.  
use [datajoint](https://docs.datajoint.io/)  
Datajoint is an addon in matlab and a module in python. In matlab, go to APPS, select 'Get more Apps'. Search for Datajoint, add.

I've created a function called: initDJ to make it easier to start working with datajoint.  
Call with the identifier for your lab. For example ```initDJ('somelab')```  
If you don't know the name of your lab, just run the previous line and you will see a list of lab names that are valid.

You may enter a valid name but still get an error because you do not have a credentials file. Ask one of your labmembers or contact me to get your lab's credentials file.

The first time you run initDJ it will create a schema for your lab. DJ requires a class folder with table definitions (an example, +yourlab, is included).  

When you get a successful connection we can start using Datajoint.  
To understand what can be retrieved, look in the +yourlab folder. Here you see a list of tables from which metadata can be retrieved.  
See if this works by simply typeing; ```yourlab.Projects```  
You should see an abbreviated view of this table.  

Retrieving records follows this pattern;
```records = fetch(yourlab.Projects,'*');```  
This simply gets all the records and all the field values from the projects table.  
Commonly, you will want to make subselections from a table. For example;  
```rec = fetch(yourlab.Sessions & 'project="Ach" AND dataset="PassiveVisualStimulus" AND stimulus="grating"', 'url', 'subject', 'setup')```  
This retrieves the records from the sessions table, for a particular project, dataset and stimulus, and limits the fields retrieved to url, subject and setup.
For your conveniance I've created a few scripts to make it easier to retrieve metadata from the various tables in FYD;  
For example, use *getSessions* to retrieve the urls to the data you want to access. You can use this function with search criteria in any combination. The following search fields are valid; project, dataset, excond, subject, stimulus, setup, date.  
~~~
	records = getSessions(project='someProject', subject='aSubject') 

%% Export your records to an Excel sheet  
	T = struct2table(records);
	selpath = uigetdir();  
	filename = fullfile(selpath, 'Example.xlsx');  
	writetable(T,filename,'Sheet',1)  
~~~

Searching and selection of records can actually get quit complex and you might need to use queries like this;  
```records = fetch(yourlab.Sessions & 'SELECT subject Like "LM%"', '*')```  
If you want to understand more about MYSQL queries check [this](https://dev.mysql.com/doc/?target=_blank).

