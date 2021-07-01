function varargout = getdbfields(varargin)
% GETDBFIELDS MATLAB code for getdbfields.fig
%      GETDBFIELDS, by itself, creates a new GETDBFIELDS or raises the existing
%      singleton*.
%
%      H = GETDBFIELDS returns the handle to a new GETDBFIELDS or the handle to
%      the existing singleton*.
%
%      GETDBFIELDS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETDBFIELDS.M with the given input arguments.
%
%      GETDBFIELDS('Property','Value',...) creates a new GETDBFIELDS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before getdbfields_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to getdbfields_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help getdbfields

% Last Modified by GUIDE v2.5 29-Jan-2019 17:25:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @getdbfields_OpeningFcn, ...
                   'gui_OutputFcn',  @getdbfields_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before getdbfields is made visible.
function getdbfields_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to getdbfields (see VARARGIN)

    %parameters for the vision and cognition database
    if nargin < 4
        disp('Error, no input:') 
        disp('1st VC or MVP to select database')
        disp('2nd argument(optional); default values = output from previous selection')
        guidata(hObject, handles);
        return
    end
    
    strP = fileparts(mfilename('fullpath'));
    addpath( strP ...
        ,fullfile(strP, 'dependent') ...
        ,fullfile(strP, 'par') ...
        ,fullfile(strP, 'jsonlab') ...
        ,fullfile(strP, 'mysql') );
    
    if strcmp(varargin{1}, 'VC')         %roelfsemalab
        dbpar = nhi_fyd_VCparms();
    elseif strcmp(varargin{1}, 'MVP')    %leveltlab
        dbpar = nhi_fyd_MVPparms();
    elseif strcmp(varargin{1}, 'NandB')  %Willuhnlab
        dbpar = nhi_fyd_NandBparms();
    elseif strcmp(varargin{1}, 'CSF')    %heimellab
        dbpar = nhi_fyd_CSFparms();
    elseif strcmp(varargin{1}, 'SBL')    %socialbrainlab
        dbpar = nhi_fyd_SBLparms();
    elseif strcmp(varargin{1}, 'CCC')    %dezeeuwlab
        dbpar = nhi_fyd_CCCparms();
    elseif strcmp(varargin{1}, 'AXS')    %kolelab
        dbpar = nhi_fyd_AXSparms();
    elseif strcmp(varargin{1}, 'SandC')   %vansomererenlab
        dbpar = nhi_fyd_SandCparms();
    elseif strcmp(varargin{1}, 'NandN')   %saltalab
        dbpar = nhi_fyd_NandNparms();
    elseif strcmp(varargin{1}, 'TM')     %TestMe database
        dbpar = nhi_fyd_TMparms();
    else
        disp('Error: No valid database parameters');
        return;
    end
    handles.dbpar = dbpar;
    
    handles.uipanel1.Title = ['Get Database fields for ' dbpar.Database];

    dgc = mysql('open', dbpar.Server, dbpar.User, dbpar.Passw);
    dbdb = mysql('use', dbpar.Database);
    
    VC.projects = mysql('SELECT projectid FROM projects');
    VC.datasets = [];
    VC.subjects = [];
    VC.conditions = [];
    VC.investigators = [];
    VC.setups = [];
    VC.stims = [];
    record = [];
    set(handles.e_date, 'String', datestr(now, 'yyyymmdd'));
    record.date = datestr(now, 'yyyymmdd');
    record.version = '1.0'; %json field version
    
    if ~isempty(VC.projects)
        record.project = VC.projects{1,1}; 
        if length(varargin)> 1 %setting to previous values if they exist
           entries = varargin{2};
           if isfield(entries, 'project') && ~isempty(find(strcmp(VC.projects, entries.project),1))
               indx = find(strcmp(VC.projects, entries.project),1);
               if indx > 0
                   record.project = VC.projects{indx,1};
                   set(handles.e_project,'Value', indx); 
               end
           end         
        end
    
    
     %   projectidx = mysql(['SELECT idx FROM projects where projectid="' record.project '"']);
     %   handles.projectidx = projectidx{1};

        VC.datasets = mysql(['SELECT datasetid FROM datasets WHERE project="' record.project '"']);
       % VC.subjects = mysql(['SELECT subjectid FROM subjects WHERE projectidx = "' projectidx{1} '"']);        
        VC.subjects = mysql(['SELECT subject FROM projects_subjects WHERE project="' record.project '"']);
                        
        VC.conditions = {' '}; %mysql('SELECT conditionid FROM conditions');
        VC.investigators = mysql('SELECT investigatorid FROM investigator');
        VC.setups = mysql('SELECT setupid FROM setups');
        VC.stims = mysql( ['SELECT stimulus FROM projects_stimulus WHERE project = "' record.project '" ']);
                     
        set(handles.figure1, 'Name', dbpar.Database)
        set(handles.e_project, 'String', VC.projects);

        
        if ~isempty(VC.datasets)
            record.dataset = VC.datasets{1,1};
            set(handles.e_dataset, 'String', VC.datasets);
            if exist('entries', 'var') && isfield(entries, 'dataset') && ~isempty(find(strcmp(VC.datasets(:,1), entries.dataset),1))
               indx = find(strcmp(VC.datasets, entries.dataset),1);
               if indx > 0
                   record.dataset = VC.datasets{indx,1};
                   set(handles.e_dataset,'Value', indx);
               end
           end
        else
            record.dataset = '';
            set(handles.e_dataset, 'String', ' ');
            set(handles.e_dataset, 'Enable', 'off');
        end

        if ~isempty(VC.subjects)
            record.subject = VC.subjects{1,1};
            set(handles.e_subject, 'String', VC.subjects);
        else
           record.subject = '';
           set(handles.e_subject, 'String', ' ');
           set(handles.e_subject, 'Enable', 'off');
        end

        if ~isempty(VC.investigators)
            record.investigator = VC.investigators{1,1};
            set(handles.e_investigator, 'String', VC.investigators);
        else
            record.investigator = '';
            set(handles.e_investigator, 'String', ' ');
            set(handles.e_subject, 'Enable', 'off');
        end
        if ~isempty(VC.setups)
            record.setup = VC.setups{1,1};
            set(handles.e_setup, 'String', VC.setups); 
        end
        if ~isempty(VC.stims)    
            record.stimulus = VC.stims{1,1};
            set(handles.e_stim, 'String', VC.stims);
        else
            record.stimulus = '';
            set(handles.e_stim, 'String', ' ');
            set(handles.e_subject, 'Enable', 'off');
        end

    %conditions depend on datasets
        if ~isempty(record.dataset)
            VC.conditions = mysql(['SELECT conditionid FROM conditions WHERE dataset = "' record.dataset '"' ...
                                   'and project = "' record.project '" ']);

             if ~isempty(VC.conditions)
                record.condition = VC.conditions{1,1};
                set(handles.e_group, 'Value', 1);
                set(handles.e_group, 'String', VC.conditions );
            else
                record.condition = '';
                set(handles.e_group, 'String', ' ' );
                set(handles.e_group, 'Enable', 'off');
            end
        end
    
        mysql('close')



        if exist('entries', 'var')%setting to previous values if they exist

           if isfield(entries, 'subject') && ~isempty(find(strcmp(VC.subjects, entries.subject),1))
               indx = find(strcmp(VC.subjects, entries.subject),1);
               if indx > 0
                    record.subject = VC.subjects{indx,1};
                    set(handles.e_subject,'Value', indx);
               end
           end
           if isfield(entries, 'condition') && ~isempty(find(strcmp(VC.conditions, entries.condition),1))
               indx = find(strcmp(VC.conditions, entries.condition),1);
               if indx > 0
                   record.condition = VC.conditions{indx,1};
                   set(handles.e_group,'Value', indx);
               end
           end
           if isfield(entries, 'investigator')
               indx = find(strcmp(VC.investigators, entries.investigator),1);
               if indx > 0
                   record.investigator = VC.investigators{indx,1};
                   set(handles.e_investigator,'Value', indx);
               end
           end
           if isfield(entries, 'setup') && ~isempty(find(strcmp(VC.setups, entries.setup),1))
               indx = find(strcmp(VC.setups, entries.setup),1);
               if indx > 0
                   record.setup = VC.setups{indx,1};
                   set(handles.e_setup,'Value', indx);
               end
           end
           if isfield(entries, 'stimulus') && ~isempty(find(strcmp(VC.stims, entries.stimulus),1))
               indx = find(strcmp(VC.stims, entries.stimulus),1);
               if indx > 0
                    record.stimulus = VC.stims{indx,1};
                    set(handles.e_stim,'Value', indx);
               end
           end
        end
    end

handles.record = record;
handles.VC = VC;  

fl.project = 30;
fl.dataset = 30;
fl.subject = 50;
fl.stimulus = 50;
fl.condition = 30;
fl.setup = 30;
fl.investigator = 30;
handles.fieldlength = fl;

% Choose default command line output for getdbfields
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes getdbfields wait for user response (see UIRESUME)
 uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = getdbfields_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
if isfield(handles, 'record')
    varargout{1} = handles.record;
else
    varargout{1} = []; 
end
mysql('close'); 
delete(hObject)

% --- Executes on selection change in e_project.
function e_project_Callback(hObject, eventdata, handles)
% hObject    handle to e_project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_project contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_project
 projects = get(hObject,'String');
 sel = get(hObject,'Value');
 if ~isempty(projects)
     handles.record.project =  projects{sel};
     guidata(hObject, handles);
     project_selected(hObject, handles);
 end
 
 function project_selected(hObject, handles)
     
     dbpar = handles.dbpar;
     dgc = mysql('open', dbpar.Server, dbpar.User, dbpar.Passw);
     dbdb = mysql('use', dbpar.Database);

    % projectidx = mysql(['SELECT idx FROM projects where projectid = "' handles.record.project '"']);
     datasets = mysql(['SELECT datasetid FROM datasets WHERE project="' handles.record.project '"']);
%     if isempty(datasets)
%         datasets = mysql('SELECT datasetid FROM datasets');
%     end
    % subjects = mysql(['SELECT subjectid FROM subjects WHERE projectidx = "' projectidx{1} '"']);
     subjects = mysql(['SELECT subject FROM projects_subjects WHERE project = "' handles.record.project '"']);
                        
     stims = mysql( ['SELECT stimulus FROM projects_stimulus WHERE project= "' handles.record.project '" ']);

    %initialize conditions at empty
    set(handles.e_group,'Value', 1);
    handles.record.condition = '';
    set(handles.e_group, 'String', ' ' );
    set(handles.e_group, 'Enable', 'off'); 
    
     if isempty(datasets)
         set(handles.e_dataset, 'String', ' ');
         set(handles.e_dataset, 'Enable', 'off');
         set(handles.e_dataset,'Value', 1);
         
         handles.record.dataset = '';
         set(handles.e_group, 'String', ' ' );
         set(handles.e_group, 'Enable', 'off');
         set(handles.e_group,'Value', 1);
     else
        set(handles.e_dataset, 'String', datasets);
        set(handles.e_dataset, 'Value',1)
        set(handles.e_dataset, 'Enable', 'on' );
        handles.record.dataset = datasets{1};
       % handles.datasetidx = datasets{1,2};   
        handles.VC.conditions = mysql(['SELECT conditionid FROM conditions WHERE dataset = "' handles.record.dataset '"' ...
                                       'and project = "' handles.record.project '" ']);
        mysql('close');                           
        
        %so if there is a dataset , update conditions if they exist
        if ~isempty(handles.VC.conditions)
            handles.record.condition = handles.VC.conditions{1,1};            
            set(handles.e_group, 'String', handles.VC.conditions );
            set(handles.e_group, 'Enable', 'on');
        end
        
     end
     
     set(handles.e_subject,'Value', 1);
     if isempty(subjects)
         set(handles.e_subject, 'String', ' ' );
         set(handles.e_subject, 'Enable', 'off' );
         handles.record.subject = '';
     else
        set(handles.e_subject, 'String', subjects );        
        set(handles.e_subject, 'Enable', 'on' );
        handles.record.subject = subjects{1};
     end
     
     set(handles.e_stim,'Value', 1);
     if isempty(stims)
         set(handles.e_stim, 'String', ' ' );
         set(handles.e_stim, 'Enable', 'off' );
         handles.record.stimulus = '';
     else
        set(handles.e_stim, 'String', stims );        
        set(handles.e_stim, 'Enable', 'on' );
        handles.record.stimulus = stims{1};
     end

%     handles.projectidx = projectidx{1};
     handles.VC.datasets = datasets;
     handles.VC.subjects = subjects;
     handles.VC.stims = stims;
     %because we have changed the project we also need to set the default
     %choices for dataset and subject.
     
     
     guidata(hObject, handles);
     
% --- Executes during object creation, after setting all properties.
function e_project_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in e_subject.
function e_subject_Callback(hObject, eventdata, handles)
% hObject    handle to e_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_subject contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_subject
    subjects = get(hObject,'String');
    sel = get(hObject,'Value');
    if ~isempty(subjects)
        handles.record.subject = subjects{sel};
        guidata(hObject, handles);
    end

% --- Executes during object creation, after setting all properties.
function e_subject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_subject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Proj_pb.
function Proj_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Proj_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
title = 'New Project';
prompt = {'Project title','Project short description (<255 words)', 'Project long description (copy-past text!)'};
answer = inputdlg(prompt, title, [1 50; 3 85; 5 85]);

if ~isempty(answer)
    Projtitle = answer{1};
    if length(Projtitle) > handles.fieldlength.project 
        disp('invalid input, too long')
    else    
    
        Shortdescr = answer{2,1};

        T = answer{3,1};
        Text = [];
        for i = 1:size(T,1)
            Text = [Text strtrim(T(i,:)) '\n']; %one long character array, trailing white spaces deleted.
        end

        Ln = length(handles.VC.projects);
        handles.VC.projects{Ln+1} = Projtitle;
        set(handles.e_project, 'string', handles.VC.projects );
        handles.record.project = Projtitle;
        set(handles.e_project, 'Value', Ln+1)

        guidata(hObject, handles);

        dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
        dgc = mysql('use', handles.dbpar.Database);
        QUERY = ['INSERT INTO projects '  ...
            '(projectid, shortdescr, longdescr) ' ...
            'VALUES( "' Projtitle '", "' Shortdescr '", "' Text '" ) ' ];

        mysql(QUERY);
        mysql('close')

        project_selected(hObject, handles);

        %set dataset and conditions entry to empty
        handles.record.dataset = '';
        set(handles.e_dataset, 'String', ' ' );
        set(handles.e_dataset, 'Enable', 'off');

        handles.record.condition = '';
        set(handles.e_group, 'String', ' ' );
        set(handles.e_group, 'Enable', 'off');
    end
end
    
% --- Executes on button press in Subject_pb.
function Subject_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Subject_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
    dgc = mysql('use', handles.dbpar.Database);
    
    ObjSub = fieldsubject();

if ~isempty(ObjSub)
    subject = ObjSub.subject;
    if length(subject) > handles.fieldlength.subject 
        disp('invalid input, too long')
    else  
        subidx = mysql(['SELECT idx FROM subjects WHERE subjectid = "' subject '"' ] );

        Ln = length(handles.VC.subjects);
        handles.VC.subjects{Ln+1} = ObjSub.subject;
        set(handles.e_subject, 'string', handles.VC.subjects )
        set(handles.e_subject, 'Value', Ln+1)
        set(handles.e_subject, 'Enable', 'on')
        handles.record.subject = ObjSub.subject;

       %first retrieve id of project 
%        projectidx = handles.projectidx;
        project = handles.record.project;

        if isempty(subidx) %subject does not exist in database
            QUERY = ['INSERT INTO subjects '  ...
                '(subjectid, species, sex, genotype) ' ...
                'VALUES( "' subject '" , "' ObjSub.species '" , "' ObjSub.sex '" , "' ObjSub.genotype '") ' ];    
            mysql(QUERY);

 %           subidx = mysql(['SELECT idx FROM subjects WHERE subjectid = "' subject '"' ] ); %SUBJECTS are unique       
        end

        QUERY = ['INSERT INTO projects_subjects (project, subject) '...
                 'VALUES( "' project '" , "' subject '" )'];     
        mysql(QUERY);
        guidata(hObject, handles);
    end
end
     mysql('close'); 
     
     
% --- Executes on button press in date_pb.
function date_pb_Callback(hObject, eventdata, handles)
% hObject    handle to date_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
res = uical();
set(handles.e_date, 'String', datestr(res, 'yyyymmdd' ))
handles.record.date = datestr(res, 'yyyymmdd' );

guidata(hObject, handles);

% --- Executes on selection change in e_setup.
function e_setup_Callback(hObject, eventdata, handles)
% hObject    handle to e_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_setup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_setup
setups = get(hObject,'String');
sel = get(hObject,'Value');
if ~isempty(setups)
    handles.record.setup = setups{sel};
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function e_setup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setup_pb.
function setup_pb_Callback(hObject, eventdata, handles)
% hObject    handle to setup_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


answer = inputdlg('New setup', '');
if ~isempty(answer)
    strinput = answer{1};
    if length(strinput) > handles.fieldlength.setup 
        disp('invalid input, too long')
    else
        Ln = length(handles.VC.setups);
        handles.VC.setups{Ln+1} = strinput;
        set(handles.e_setup, 'string', handles.VC.setups );
        set(handles.e_setup, 'Value', Ln+1);

        handles.record.setup = strinput;

        guidata(hObject, handles);

        dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
        dgc = mysql('use', handles.dbpar.Database);
        QUERY = ['INSERT INTO setups '  ...
            '(setupid) ' ...
            'VALUES( "' handles.record.setup '" ) ' ];

        mysql(QUERY);
        mysql('close')
    end
end

% --- Executes on selection change in e_stim.
function e_stim_Callback(hObject, eventdata, handles)
% hObject    handle to e_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_stim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_stim
    stims = get(hObject,'String');
    sel = get(hObject,'Value');
    if ~isempty(stims)
        handles.record.stimulus = stims{sel};
        guidata(hObject, handles);
    end

% --- Executes during object creation, after setting all properties.
function e_stim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_stim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stim_pb.
function stim_pb_Callback(hObject, eventdata, handles)
% hObject    handle to stim_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
    dgc = mysql('use', handles.dbpar.Database);
%answer = inputdlg({'Name for new stimulus'}, 'New' );
    ObjStim = fieldstimulus();

if ~isempty(ObjStim)
    stimulus = ObjStim.stimulus;
    if length(stimulus) > handles.fieldlength.stimulus 
            disp('invalid input, too long')
    else
        stimulusidx = mysql(['SELECT idx FROM stimulus WHERE stimulusid = "' stimulus '"' ] );

        Ln = length(handles.VC.stims);
        handles.VC.stims{Ln+1} = stimulus;
        set(handles.e_stim, 'string', handles.VC.stims )
        set(handles.e_stim, 'Value', Ln+1)
        set(handles.e_stim, 'Enable','on')
        handles.record.stimulus = stimulus;
        guidata(hObject, handles);

        if isempty(stimulusidx) %does not exist in database
            QUERY = ['INSERT INTO stimulus ( stimulusid, shortdescr ) VALUE( "' stimulus '", "' ObjStim.shortdescr '" ) ' ];
            mysql(QUERY);

  %          QUERY = ['SELECT idx FROM stimulus WHERE stimulusid = "' stimulus '"'];    
  %          stimulusidx = mysql(QUERY);
        end

   %     projectidx = handles.projectidx;
        project = handles.record.project;

        QUERY = ['INSERT INTO projects_stimulus ( project, stimulus ) '...
                 'VALUES ( "' project '" ,"' stimulus '" )'];
        mysql(QUERY);
    end
end
    mysql('close');
    
% --- Executes on selection change in e_investigator.
function e_investigator_Callback(hObject, eventdata, handles)
% hObject    handle to e_investigator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%    investigators = get(hObject,'String');
%    sel = get(hObject,'Value');
    investigators = get(hObject,'String');
    sel = get(hObject,'Value');
    if ~isempty(investigators)
        handles.record.investigator = investigators{sel};
        guidata(hObject, handles);
    end

% --- Executes during object creation, after setting all properties.
function e_investigator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_investigator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Research_pb.
function Research_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Research_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    answer = inputdlg({'Name for new investigator'}, 'New' );
    if ~isempty(answer)
        strinput = answer{1};
        if length(strinput) > handles.fieldlength.investigator 
            disp('invalid input, too long')
        else
            Ln = length( handles.VC.investigators);
            handles.VC.investigators{Ln+1} =  strinput;
            set(handles.e_investigator, 'string', handles.VC.investigators)
            set(handles.e_investigator, 'Value', Ln+1)
            handles.record.investigator = strinput;

            dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
            dgc = mysql('use', handles.dbpar.Database);
            QUERY = ['INSERT INTO investigator '  ...
                '( investigatorid ) ' ...
                'VALUES( "' strinput '" ) ' ];

            mysql(QUERY);
            mysql('close');

            guidata(hObject, handles);
        end
    end
    
   


% --- Executes on button press in Done_pb.
function Done_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Done_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
record = handles.record;
%chec output for empty / invalid entries
flds = fields(record);
for i = 1:length(flds)
    if strcmp(record.(flds{i}), '') == true
        warndlg([flds{i} ' is empty, please fill before saving!!!'])
        return
    end
end

uiresume(gcbf)


% --- Executes on selection change in e_dataset.
function e_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to e_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_dataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_dataset
    datasets = get(hObject,'String');
    sel = get(hObject,'Value');
    if ~isempty(datasets)
        handles.record.dataset = datasets{sel};

        dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
        dgc = mysql('use', handles.dbpar.Database);
        handles.VC.conditions = mysql(['SELECT conditionid FROM conditions WHERE dataset = "' handles.record.dataset '"' ...
                                       'and project = "' handles.record.project '" ']);
        mysql('close');                           
        
        set(handles.e_group,'Value', 1);
        if ~isempty(handles.VC.conditions)
            handles.record.condition = handles.VC.conditions{1,1};           
            set(handles.e_group, 'String', handles.VC.conditions );
            set(handles.e_group, 'Enable', 'on');
        else
            handles.record.condition = '';
            set(handles.e_group, 'String', ' ' );
            set(handles.e_group, 'Enable', 'off');
        end
                        
    else %empty dataset, also means no conditions
            handles.record.condition = '';
            set(handles.e_group, 'String', ' ' );
            set(handles.e_group, 'Enable', 'off'); 
    end
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function e_dataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dataset_pb.
function dataset_pb_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
title = 'New Dataset';
prompt = {'Dataset title','Dataset short description (<160 letters)', 'Dataset long description (copy-past text!)'};
answer = inputdlg(prompt, title, [1 50; 3 85; 5 85]);

if ~isempty(answer)
    Dsettitle = answer{1};
    if length(Dsettitle) > handles.fieldlength.dataset 
        disp('invalid input, too long')
    else
        Shortdescr = answer{2,1};

        T = answer{3,1};
        Text = [];
        for i = 1:size(T,1)
          Text = [Text strtrim(T(i,:)) '\n']; %one long character array, trailing white spaces deleted.
        end

        DSln = length(handles.VC.datasets);
        handles.VC.datasets{DSln+1} =  Dsettitle;
        set(handles.e_dataset, 'string', handles.VC.datasets)
        set(handles.e_dataset, 'Value', DSln+1)
        set(handles.e_dataset, 'Enable', 'on')
        handles.record.dataset = Dsettitle;

        dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
        dgc = mysql('use', handles.dbpar.Database);

        %first retrieve id of project 
%        projectidx = handles.projectidx;
        project = handles.record.project;

        QUERY = ['INSERT INTO datasets '  ...
            '(datasetid, project, shortdescr, longdescr) ' ...
            'VALUES( "' Dsettitle '", "' project '", "' Shortdescr '", "' Text '") ' ];   
        mysql(QUERY); 

        %create default condition
        handles.record.condition = 'none'; 
        set(handles.e_group, 'String', 'none' );
        set(handles.e_group, 'Enable', 'on');
        set(handles.e_group,'Value', 1);
        
        QUERY = ['INSERT INTO conditions '  ...
                 '(conditionid, dataset, project) ' ...
                 'VALUES( "none", "' Dsettitle '", "' project '")' ];

        mysql(QUERY);  
        mysql('close');
        
        guidata(hObject, handles);
    end
end

% --- Executes on selection change in e_group.
function e_group_Callback(hObject, eventdata, handles)
% hObject    handle to e_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns e_group contents as cell array
%        contents{get(hObject,'Value')} returns selected item from e_group
    conditions = get(hObject,'String');
    sel = get(hObject,'Value');
    if ~isempty(conditions)
        handles.record.condition = conditions{sel};
        guidata(hObject, handles);
    end

% --- Executes during object creation, after setting all properties.
function e_group_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Group_pb.
function Group_pb_Callback(hObject, eventdata, handles)
% hObject    handle to Group_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = inputdlg({'Name for new condition'}, 'New' );
if ~isempty(answer)
    strinput = answer{1};
    if length(strinput) > handles.fieldlength.condition 
        disp('invalid input, too long')
    else
        Ln = length(handles.VC.conditions);
        
        conditionid = strinput;
        handles.VC.conditions{Ln+1} =  strinput;
        set(handles.e_group, 'string', handles.VC.conditions)
        set(handles.e_group, 'Value', Ln+1)
        set(handles.e_group, 'Enable', 'on')
        handles.record.condition = strinput;
        dataset = handles.record.dataset;
        project = handles.record.project;

        dgc = mysql('open', handles.dbpar.Server, handles.dbpar.User, handles.dbpar.Passw);
        dgc = mysql('use', handles.dbpar.Database);

        QUERY = ['INSERT INTO conditions '  ...
                 '(conditionid, dataset, project) ' ...
                 'VALUES( "' conditionid '", "' dataset '", "' project '")' ];

        mysql(QUERY);
        mysql('close');

        guidata(hObject, handles);
    end
end


