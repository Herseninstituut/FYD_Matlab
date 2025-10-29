

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
huubs_labjournal = fetch(labjournal.Huub, '*')
```
Simply click on this object to open a spreadsheet with the data. You will see that the comments are empty!
So how to add additional metadata:


```MATLAB
update(labjournal.Huub & 'sessionid="Beta_20211029_002"', 'comment', 'Hey there This is a comment')
```
Here you see that we can update the comment field for a specific record by it's sessionid.   
Another way, if you need to update several fields at once, is to retrieve the whole record, change the values in the record, then delete the record in the database and insert the updated version. You cannot simply insert the new record, this will lead to an error caused by a duplicate sessionid.