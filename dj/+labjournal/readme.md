

**Labjournal database**
A place to create your own lab journals
Simply create a new table after initializing Datajoint : 
```
% Initialize
initDJ('leveltlab')

% Create new table
dj.new

Enter <package>.<ClassName>: labjournal.Huub

Choose table tier:
  L=lookup
  M=manual
  I=imported
  C=computed
  P=part
 (L/M/I/C/P) > M
 ```
 Then a file is created called Huub.m in the +labjournal folder with:
```MATLAB
%{
# my newest table
# add primary key here
-----
# add additional attributes
%}

classdef Huub < dj.Manual
end
```

You can now add fields to this tabel schema. For example;
```MATLAB
%{
# Huub's lab Journal
# add primary key here
sessionid   : varchar(100)
-----
# add additional attributes
url     :   varchar(500)
project :   varchar(50)
dataset :   varchar(50)
excond   :  varchar(30)
subject :   varchar(30)
date    :   date
setup   :   varchar(30)
stimulus    : varchar(50)
comment = '' :   varchar(500) 
%}

classdef Huub < dj.Manual
end
```
If you need to change and update the table, first delete it with :
```MATLAB
drop(labjournal.Huub)
```

Now let's fill this table wth some data. First we will get the relevent sessions (get data for subject Beta):
```MATLAB
Ses = getSessions(subject='Beta')

Ses = 

  25×1 struct array with fields:

    sessionid
    url
    server
    idx
    project
    dataset
    subject
    stimulus
    excond
    setup
    date

```
The output in this case contains to many fields. We can reduce them with:
```MATLAB
nwSes = rmfield(Ses, {'server', 'idx'})
nwSes = 

  25×1 struct array with fields:

    sessionid
    url
    project
    dataset
    subject
    stimulus
    excond
    setup
    date
```
Nice! Now we can simply insert these into our labjournal.

```MATLAB
insert(labjournal.Huub, nwSes)
```
To retrieve whats in the database, we should use fetch on Huub and use '*' to retrieve all the fields:
```MATLAB
huubs_labjournal = fetch(labjournal.Huub, '*');
```
Simply click on this object to open a spreadsheet with the data. You will see that the comments are empty!
So how to add additional metadata:


```MATLAB
update(labjournal.Huub & 'sessionid="Beta_20211029_002"', 'comment', 'Hey there This is a comment')
```
Here you see that we can update the comment field for a specific record by it's sessionid.   
Another way, if you need to update several fields at once, is to retrieve the whole record, change the values in the record, then delete the record in the database and insert the updated version. You cannot simply insert the updated record, this will lead to an error caused by a duplicate sessionid.

But wait, I would like to import values from the associated json or log files that are not in the json database.

```MATLAB
p2json = fullfile(huubs_labjournal(1).url, [huubs_labjournal(1).sessionid '_session.json'])
% Load json file as a data structure
J = loadjson(p2json);

  struct with fields:

            date: '20210916'
         version: '1.0'
         project: 'AudioVisual'
         dataset: 'Dark_rearing'
         subject: 'Beta'
    investigator: 'HuubT'
           setup: 'Gaia'
        stimulus: 'frequencyAmplitudeMap'
       condition: 'Dark_reared'
         logfile: 'Beta_20210916_002_log'
         display: [1×1 struct]

%get the url to the logfile
logpath = fullfile(huubs_labjournal(1).url, [J.logfile '.mat'])
log  = load(logpath)

  struct with fields:

           log: [720×1 double]
    Parameters: [1×1 struct]
```
For example I would like to add two columes to the labjournal; the stimulus distance from the display parameters and stimulus time from the logs.

```MATLAB
stim_time = log.Parameters.time;
screen_distance = J.display.ScreenDistance;
```
To script this I should run a loop to retrieve these values and add them to the huubs_labjournal;

```MATLAB
for i = 1:length(huubs_labjournal)
  p2json = fullfile(huubs_labjournal(i).url, [huubs_labjournal(i).sessionid '_session.json']);
  J = loadjson(p2json);
  screen_distance = J.display.ScreenDistance;
  comment = '';
  if isfield(J, 'comment')
    comment = J.comment;
  end

  try
    log = load(fullfile(huubs_labjournal(i).url, [J.logfile '.mat']));
    stim_time = log.Parameters.time;
  catch
    stim_time = 0;
  end
  huubs_labjournal(i).screen_distance = screen_distance;
  huubs_labjournal(i).stim_time = stim_time;
  huubs_labjournal(i).comment = comment;
end
```
You will now see that Huubs_labjournal is updated in matlab. However, it is not updated in the labjournal database. We need to add the collumns in the schema, drop the table and insert the values again.

```MATLAB
% add two attributes below the stimulus attribute and save the schema.

%{
# Huub's lab Journal
# add primary key here
sessionid   : varchar(100)
-----
# add additional attributes
url     :   varchar(500)
project :   varchar(50)
dataset :   varchar(50)
excond   :  varchar(30)
subject :   varchar(30)
date    :   date
setup   :   varchar(30)
stimulus    : varchar(50)
screen_distance : int
stim_time       : float
comment = '' :   varchar(500) 
%}

classdef Huub < dj.Manual
end

% Then drop the schema
drop(labjournal.Huub)

%Renew the table
insert(labjournal.Huub, huubs_labjournal)

```

Clear your workspace and check using the initial code to verify that huubs labjournal was updated.