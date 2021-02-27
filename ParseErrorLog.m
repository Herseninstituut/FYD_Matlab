% Use the url to the logfile you want to parse (select from your system webbrowser url bar)    
%url = 'https://nhi-fyd.nin.knaw.nl/logMVP.html';
    url = 'https://nhi-fyd.nin.knaw.nl/logCCC.html';
    html = webread(url);

%%
% Parse log output using regular expressions to select error records, from these the
% VALUE strings, and from these the actual values per ERROR record

Rec1 = regexp(html,'(?>(Error))[\S\s]*?(?=(REFERENCES))', 'match')'; %records on mnt
Rec2 = regexp(html,'(?>(Exception))[\S\s]*?''vs03''\)', 'match')';   %records on vs03

Rec = [Rec1; Rec2];
%parse values from jsonfile input
Txt = cellfun(@(rc) regexp(rc,'(?<=VALUES \().+?(?=\))', 'match'), Rec, 'UniformOutput', false); %value strings
it = cellfun(@(tx)(~isempty(tx)), Txt);                %remove empty cells
Txt = Txt(it);

Tbl = cellfun( @(txt) strtrim(split(txt, ',')), Txt, 'UniformOutput', false);
Tbl = cellfun( @(T) cellfun(@(v) v(2:end-1), T, 'UniformOutput', false), Tbl, 'UniformOutput', false);
Tbl = reshape([Tbl{:}], 12, numel(Tbl))';  %reshape to make conversion to table possible

%parse foreign key errors
Errfk = cellfun(@(rc) regexp(rc,'(?<=FOREIGN KEY \(`).+?(?=`)', 'match'), Rec, 'UniformOutput', false); %value strings
it = cellfun(@(ex)(~isempty(ex)), Errfk);                %remove empty cells
Errfk  = Errfk(it);

%% make table with entries from values; path, sessionid', project, dataset, subject, date, setup, condition, stimulus, logfile, investigator, server 

T = cell2table(Tbl, 'VariableNames', {'path' 'sessionid' 'project' 'dataset' 'subject' 'date' 'setup' 'condition' 'stimulus' 'logfile' 'investigator' 'server'});
T.Errors = Errfk;

%with this table we can now check if the neccessary identifiers exist in
%the database using importandgenerate.mlx

%% Save to excel sheet

selpath = uigetdir();
filename = fullfile(selpath, 'Logoutput.xlsx');

writetable(T,filename,'Sheet',1)