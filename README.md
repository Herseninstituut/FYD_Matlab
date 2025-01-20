# Follow Your Data (FYD) for matlab [![DOI](https://zenodo.org/badge/342855808.svg)](https://zenodo.org/badge/latestdoi/342855808)
A library of scripts to index global metadata automatically, and make data web/machine searchable.


You can inspect the database here (Nederlands Hersen Instituut - Follow Your Data, __but only from within the intranet of our institute__):
[nhi-fyd/](https://nhi-fyd.nin.knaw.nl/)

Notifications about FYD_MAtlab will also appear in our micrsoft teams data management channel.

***
#### Getting started ####

* Clone/download this repository to your local machine and add the root folder and the mysql folder to your Matlab path. 
* Add jsonlab if you are running Matlab older than 2017b.
* Obtain a credentials file from your systems manager.
* Create a subfolder in FYD_Matlab called `par` and copy your lab-based credentials file (`nhi_fyd_XXparms.m`) there.
* Use ```getFYD()``` to create a basic json structure with all the required fields.
* Store 1 json file with each recording session (for example, each block) in a separate folder.
* Each json file should have a unique name consisting of an id (subject_data_sessnr
* Always keep the json files together with your data.
* A server script automatically indexes the json files and keeps an up to date list of urls to your data.
* Do not put spaces in the folder names and identifiers you create for your json files.
* You may need to install [vc_redist.x64.exe (2015-2022)](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) if you see an error such as; "Invalid MEX-file....: The specified module could not be found." (Be aware that you need administrator rights to install this.)

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


[getdbfields](https://github.com/Herseninstituut/FYD_Matlab/blob/master/dbgetfields.png)

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
***
## How to make json files for an existing dataset ##
Organize your data according to the NIN  [data protocol](https://herseninstituut.sharepoint.com/sites/RDM/SitePages/FAIR-data.aspx)  first.
Each recording session with associated metadata should be in a separate folder. Ideally, the filename of each file, should contain sessionid of the containing folder.
Here is an example, according to the recommended schema: project/data_collection/dataset/subject/session
```
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
 ```

If you have ordered you data this way, you can now make an excel sheet with the neccessary metadata to automatically generate the json files at the appropriate locations. jsontemplate.xlsl contains columns for each required field.  

<img src="https://github.com/Herseninstituut/FYD_Matlab/blob/master/excel.png" >

When your list is complete, generate the json files with : **Generatejsonfiles.m** and the json files will be saved at the provided path locations. If you have done this correctly, your json files will automatically show up on the website. Be sure to register all your projects, datasets, subjects, conditions , stimuli, setups in the database befor you save the json files. Otherwise you will get foreign constraint errors.

***
## Find and Retrieve urls ##
A simple way to retrieve the urls for the data you want to access, you can use this function with search criteria.  
``` urls = getSessions(project='someProject', subject='aSubject') ```  
In any combination, you can use the following search fields ; project, dataset, excond, subject, stimulus, setup, date

Alternatively, you can use **callfydAccess.m**. Once you have filled in your search criteria press display to retrieve a list of files, associated with each json file in a selectable tree-view. Just as with the windows search bar, you can select file types with (\*) as a wild card character. nb. this can take quite a while to finish!
```
	urls = callfydAccess();
```
<img src="https://github.com/Herseninstituut/FYD_Matlab/blob/master/images/fydAccess.png" height="300" >
Select all or just a few checkboxes to retrieve the urls of interest. After pressing save&close a list of urls is returned:  

``` 
{'\\VS03\VS03-VandC-1\ACh\Active2\Beta\2Pdata\20211214\Beta_20211214_001.mat'				} 
{'\\VS03\VS03-VandC-1\ACh\Active2\Beta\2Pdata\20211214\Beta_20211214_001_Bh.mat'			} 
{'\\VS03\VS03-VandC-1\ACh\Active2\Beta\2Pdata\20211214\Beta_20211214_001_GREEN_Fullfield_ImgBase.mat' 	}   
{'\\VS03\VS03-VandC-1\ACh\Active2\Beta\2Pdata\20211214\Beta_20211214_001_GREEN_Fullfield_ImgBase_1sNL.mat'}   
{'\\VS03\VS03-VandC-1\ACh\Active2\Beta\2Pdata\20211214\Beta_20211214_1_log.mat'                           } 
```

***

### dj (datajoint) 
use datajoint  : https://docs.datajoint.io/
Datajoint is an addon in matlab and a module in python. It requires a class folder with table definitions (an example, for our test database, is included).  
testexample.m shows how to use datajoint in connection with the FYD database to make an updatable spreadsheet with a few lines of code.  
```
setenvdj    %set environment credentials for MySql database
populate(shared.Example) %update table of records with specific characteristics
```
Once you have defined a table (see example.m in the +shared folder) it is easy to update this table as new data arrives in the database. With a few extra lines you can retrieve the table contents and export it to an excel spreadsheet.
```
%% query our table of interest
Dtbl = fetch(shared.Example, '*');
T = struct2table(Dtbl);

%% Export to Excel sheet
selpath = uigetdir();
filename = fullfile(selpath, 'Example.xlsx');
writetable(T,filename,'Sheet',1)
```
GetDouble_JSONS.mlx and importandgenerate.mlx are two additional tools to manage your database
```GetDouble_JSONS``` Checks for double entries. In some cases users copy their data to more than one location, leading to records with urls to both locations in the database. You can use this info to remove superfluous data, or to remove the jsonfiles.

```importandgenerate``` Helps to generate identifiers and json files for datasets not yet associated with json files. Usually because json files were not generated at the time of data collection. Users should first fill in an excel sheet with the required information for each instance (path, project, dataset, subject, stimulus, condition, setup, investigator, sessionid, date) that will require a json file.  
