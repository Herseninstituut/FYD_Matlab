%% query and Import records from FYD 
%a simply way to retrieve urls to access the data
urls = getSessions(project='SomeProject', subject='aSubject');

%% Making a spreadsheet that can be updated as new json files are added to the server
%first add the datajoint toolbox to matlab from matlab addons
setenvdj    %set environment credentials for MySql database
populate(shared.Example) %update table of records with specific characteristics

%% query our table of interest
Dtbl = fetch(shared.Example, '*');
T = struct2table(Dtbl);

%% Export to Excel sheet
selpath = uigetdir();
filename = fullfile(selpath, 'Example.xlsx');
writetable(T,filename,'Sheet',1)


