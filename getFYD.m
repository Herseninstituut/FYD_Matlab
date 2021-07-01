function fields = getFYD()

%setup path definitions
    strP = fileparts(mfilename('fullpath'));
    addpath( strP ...
        ,fullfile(strP, 'dependent') ...
        ,fullfile(strP, 'par') ...
        ,fullfile(strP, 'jsonlab') ...
        ,fullfile(strP, 'mysql') );

%You cannot easily export data from a mlapp, but you can pass it a class 
%handle to store the data you need after the mlapp is deleted 
    HStore = Fydflds(); %Class handle store
    app = getFYDfields(HStore); %mlapp GUI to select input values
    waitfor(app) 
    fields = HStore.fields; %return values
    