    %example using a limited json schema for database recording
%this is the metadata that is stored in the database, but much more can be
%stored in the json files
json = [];
json = getdbfields('MVP', json);   %'MVP' for Leveltlab , 'VC' for Roelfsemalab; you also need uical.m for the calendar

%ID = Subject_Date_Sessionnr ( 'Abc_01082018_001') 
ID = [json.subject '_' json.date '_001'];
json.logfile =[ID '_log.mat']; %name for your logfile : 
json.comment = 'This is up to you; Add some comments'; 

strpath = uigetdir('*');
savejson('', json, [strpath '\' ID '_session.json']);

%ID is data record identifier, each datafile associated with this record
%should contain this identifier

%with matlab 2017b
%StrJson = jsonencode(json);
%fwrite('test1.json', 'StrJson')

%otherwise use jsonlab (download)

