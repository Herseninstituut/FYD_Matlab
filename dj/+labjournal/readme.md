

**Labjournal database**  
Create your own lab journal:  

We will create a new table called "Huub" in the *labjournal* database after initializing Datajoint : 
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
 We will choose **M**  (for Manual) and then a file is created called Huub.m in the +labjournal folder with:
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

This is a datajoint table schema and you can can add fields to this schema. For example here are some fields from the FYD session table;
```MATLAB
% To see how they are defined in the FYD session table use: 
describe(leveltlab.Sessions)

%Add fields to your labjournal table

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
% getSessions is a conveniance script I wrote to get sessions associated with a particular project, dataset, subject, stimulus, setup or date range.
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
To retrieve what's in the database, we should use fetch on labjournal.Huub and use '*' to retrieve all the fields:
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

**Adding metadata from other tables**  
But I would like to add metadata from other tables, such as metadata associated with the subject:  
First get the selected subjects:
```MATLAB
% I only have one subject in this case
subjects = unique({ nwSes(:).subject });
subject_meta = getSubjects(subjects);   % Conveniance script to get subject metadata.
for i = 1:length(subjects)
    sel = find([ arrayfun(@(x) strcmp(x.subject, subjects{i}), huubs_labjournal) ])
    for j = 1:length(sel)
      huubs_labjournal(sel(j)).genotype = subject_meta(i).genotype;
      huubs_labjournal(sel(j)).sex = subject_meta(i).sex;
      huubs_labjournal(sel(j)).age = subject_meta(i).age;
      huubs_labjournal(sel(j)).hemisphere = subject_meta(i).hemisphere;
      huubs_labjournal(sel(j)).location = subject_meta(i).location;
    end
end
```

But wait, I would also like to import values from the associated json or log files that are not in the json database.
for example:
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
Now, I would like to add two columes to the labjournal; the stimulus distance from the display parameters and stimulus time from the logs.

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
% add the additional attributes below the stimulus attribute and save the schema.

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
genotype = null: varchar(20)
age = null : varchar(30)        # age : days, weeks, months, years
hemisphere = null : enum('l', 'r', 'u')   # which hemisphere
location = null  : varchar(60) 
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
```MATLAB
huubs_labjournal = fetch(labjournal.Huub, '*');
```

**Automating your labjournal**  
Instead of clearing and updating your labjournal, it would be nice if we could automatically add records to the table, without having to regenerate the whole table.
This is important, because you might want to manually insert data, such as comments or annotate records with a good or bad qualification. If you renew the table these additions would be lost.  
TODO this we will make a very simple manual table called HuubRecords, a list of sessionids to simply define which records I would like to add to my labjournal.
```MATLAB 
  describe(labjournal.HuubRecords)

%{
  # Huubrecords (only one field with sessionid)
  sessionid                   : varchar(100)                  # 
%}

Ses = fetch(leveltlab.Sessions & 'subject="Beta"', 'sessionid');
nwSes = rmfield(Ses, 'idx');
% inserts must be a structure or a structure array
insert(labjournal.HuubsRecords, nwSes)


% To automatically populate our labjournal we create a datajoint imported table:
%{
     # Huub's automated lab Journal
     sessionid                   : varchar(100)                  # 
     ---
     url                         : varchar(500)                  # 
     dataset                     : varchar(50)                   # 
     condition                   : varchar(30)                   # 
     subject                     : varchar(30)                   # 
     genotype=null               : varchar(20)                   # 
     sex="U"                     : enum('M','F','U')             # 
     age=null                    : varchar(30)                   # age : days, weeks, months, years
     hemisphere=null             : enum('l','r','u')             # which hemisphere
     location=null               : varchar(60)                   # 
     date                        : date                          # 
     setup                       : varchar(30)                   # 
     stimulus                    : varchar(50)                   # 
     screen_distance=null        : int                           # 
     stim_time=null              : float                         # 
     comment = null              : varchar(500)                  # 
%}

classdef HuubAuto < dj.Imported
    properties (Dependent)
        keySource
    end
    methods(Access=protected)
        function makeTuples(self, key)
            [dataset, subject, excond, stimulus, date, url, setup] = fetch1(leveltlab.Sessions & key, 'dataset', 'subject', 'excond', 'stimulus', 'date', 'url', 'server'); 
            Subject_meta = fetch(leveltlab.Subjects & ['subjectid="' subject '"'], 'genotype', 'age', 'sex', 'hemisphere', 'location');

            key.url = self.geturl(url);
            key.dataset = dataset;
            key.subject = subject;
            key.genotype = Subject_meta.genotype;
            key.sex = Subject_meta.sex;
            key.age = Subject_meta.age;
            key.hemisphere = Subject_meta.hemisphere;
            key.location = Subject_meta.location;
            key.condition = excond;
            key.stimulus = stimulus;
            key.date = date;
            key.setup = setup;

            p2json = fullfile(key.url, [key.sessionid '_session.json']);
            J = loadjson(p2json);
            key.screen_distance = J.display.ScreenDistance;
              comment = '';
            if isfield(J, 'comment')
               comment = J.comment;
            end
            key.comment = comment;

            try
                log = load(fullfile(key.url, [key.sessionid  '_log.mat']));
                stim_time = log.Parameters.time;
            catch
                stim_time = 0;
            end
            key.stim_time = stim_time;

            self.insert(key);
        end
    end
    methods
        function id = get.keySource(~)
            id = labjournal.HuubRecords;
        end
        function url = geturl(~, urlin)
             url = fileparts(fullfile(strrep(urlin, 'mnt', '')));
        end
    end
end

% Using the input from HuubRecords we populate the HuubAuto table
populate(labjournal.HuubAuto)

huubs_labjournal = fetch(labjournal.HuubAuto, '*')
```
You need to call populate on this table if you add records to the HuubRecords table, but datajoint adds new records to the HuubAuto table without dropping and renewing the table, which means you can add comments to specific records without losing them later.

For example, lets add mouse Delta:
```MATLAB
Ses = fetch(leveltlab.Sessions & 'subject="Delta"', 'sessionid');
nwSes = rmfield(Ses, 'idx');
% inserts must be a structure or a structure array
insert(labjournal.HuubsRecords, nwSes)

% Records for mouse Delta are added to the labjournal
populate(labjournal.HuubAuto)
```
