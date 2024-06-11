function [metadata, Okay] = getMetadata(sessionid)
% Get neccessary metadata, this contains references to other tables in FYD
% to run this function you will need FYD2BIDS
% Chris van der Togt


    metadata = [];
    Okay = false;
    
    sess_meta = getSessions(sessionid=sessionid); % metadata in JSON files and in Sessions table
    if isempty(sess_meta)
        disp('ERROR: invalid sessionid')
        return
    end
    
    project = sess_meta.project;
    dataset = sess_meta.dataset;
    subject = sess_meta.subject;
    setup = sess_meta.setup;
    stim = sess_meta.stimulus;

    % Other tables in FYD
    dataset_meta = getDataset( project, dataset );
    check_entries(dataset_meta)
    
    task_meta = getStimulus(stim);
    check_entries(task_meta)
    
    subject_meta = yaml.loadFile('template_subject.yaml');
    sub_meta = getSubjects(subject); % multiple subjects as cell array
    check_entries(sub_meta)
    flds = fields(subject_meta);
    for i = 1:length(flds)
        if isfield(sub_meta, flds{i}), subject_meta.(flds{i}) = sub_meta.(flds{i}); end
    end     
    
    
    setup_meta = getSetup(setup);
    if ~isempty(setup_meta)
        check_entries(setup_meta)
    else 
        disp('ERROR: No setup metadata, aborting.')
        return
    end
    
    %Is there extra metadata from the original json file
    fpjson = fullfile(sess_meta.url, [sess_meta.sessionid '_session.json']);
    txt_json = fileread(fpjson);
    J_meta = jsondecode(txt_json);
    if isfield(J_meta, 'display') % runexperiment always saves the display parameters!!
        setup_meta.display = J_meta.display;        
    end
    
    metadata = struct('sess_meta', sess_meta, 'dataset_meta', dataset_meta, ...
                       'task_meta', task_meta, 'subject_meta', subject_meta, ...
                       'setup_meta', setup_meta );
    Okay = true;
    
    fprintf('All metadata retrieved from FYD database, please update invalid values \n\n');
    
    %% Retrieve recording method metadata. This will be a combination of metadata
    % entered on the webapp and data retrieved from the recorded files.
    
    switch lower(setup_meta.type)
        case 'ephys' %this is an electrophysiology dataset
            disp(['This is an electrophysiology dataset, using the ' setup ' setup.'])
            
            ephys = yaml.loadFile('template_ephys.yaml');
            flds = fields(ephys);
            for i = 1:length(flds)
                if isstring(ephys.(flds{i}) )
                    ephys.(flds{i}) = char(ephys.(flds{i})); 
                    if isfield(setup_meta, flds{i}), ephys.(flds{i}) = char(setup_meta.(flds{i})); end
                    if isfield(dataset_meta, flds{i}), ephys.(flds{i}) = char(dataset_meta.(flds{i})); end
                    if isfield(task_meta, flds{i}), ephys.(flds{i}) = char(task_meta.(flds{i})); end
                    if isfield(subject_meta, flds{i}), ephys.(flds{i}) = char(subject_meta.(flds{i})); end     
                else 
                    if isfield(setup_meta, flds{i}), ephys.(flds{i}) = setup_meta.(flds{i}); end
                    if isfield(dataset_meta, flds{i}), ephys.(flds{i}) = dataset_meta.(flds{i}); end
                    if isfield(task_meta, flds{i}), ephys.(flds{i}) = task_meta.(flds{i}); end
                    if isfield(subject_meta, flds{i}), ephys.(flds{i}) = subject_meta.(flds{i}); end                    
                end

            end  
            % these are retrieved from the template
            metadata.dataset_meta.institution_name = ephys.institution_name;
            metadata.dataset_meta.institution_adress = ephys.institution_adress;

            key = ['subject="', subject,'"'];
            probe_meta = fetch(bids.Probes & key, '*'); % '*' -> retrieve all fields
            if isempty(probe_meta)
                %nwblog('<br>Probe metadata not present, please upload probe table')
                disp('Probe metadata not present, please upload probe, contact and channel table')
                return
            end
            electrode_meta = fetch(bids.Electrodes & key, '*');
            if isempty(electrode_meta)
                %nwblog('<br>Contact metadata not present, please upload contact table')
                disp('Electrode metadata not present, please upload electrode and channel table')
                return
            end
            channel_meta  = fetch(bids.Channels & key, '*');
            if isempty(channel_meta)
                %nwblog('<br>Channel metadata not present, please upload channel table')
                disp('Channel metadata not present, please upload channel table')
                return
            end

            metadata.probe_meta = probe_meta;
            metadata.electrode_meta = electrode_meta;
            metadata.channel_meta = channel_meta;
            metadata.ephys = ephys;
            fprintf('Done retrieving meta data for this sessionid: %s \n', sessionid);

            
        case 'ophys'  %see template_ophys.yaml
            % This case is for all optical physiological datasets, 2
            % photon, wide field, miniscope etc.
            disp(['This is an optical physiology dataset, using the ' setup ' setup.'])
            %First a yaml file is imported with all necessary fields, and
            %these will be filled in from the FYD database, using the
            %collected general metadata associated with this sessionid.
            ophys = yaml.loadFile('template_ophys.yaml');
            flds = fields(ophys);
            for i = 1:length(flds)
                if isstring(ophys.(flds{i}) )
                    ophys.(flds{i}) = char(ophys.(flds{i})); 
                    if isfield(setup_meta, flds{i}), ophys.(flds{i}) = char(setup_meta.(flds{i})); end
                    if isfield(dataset_meta, flds{i}), ophys.(flds{i}) = char(dataset_meta.(flds{i})); end
                    if isfield(task_meta, flds{i}), ophys.(flds{i}) = char(task_meta.(flds{i})); end    
                else
                    if isfield(setup_meta, flds{i}), ophys.(flds{i}) = setup_meta.(flds{i}); end
                    if isfield(dataset_meta, flds{i}), ophys.(flds{i}) = dataset_meta.(flds{i}); end
                    if isfield(task_meta, flds{i}), ophys.(flds{i}) = task_meta.(flds{i}); end                     
                end

            end
            
            % these are retrieved from the template
            metadata.dataset_meta.institution_name = ophys.institution_name;
            metadata.dataset_meta.institution_adress = ophys.institution_adress;
            
            filepath = fullfile(sess_meta.url, sess_meta.sessionid); 
            
            % Now that we have the general lmetadata we need to retrieve
            % data specifically associated with the recording method used.
            
            switch lower(ophys.manufacturer)
                
                case 'neurolabware'
                    fprintf('The setup uses a neurolabware device. \n\n')
                    metadata = neurolabware(filepath, ophys, metadata);
                    fprintf('Done retrieving meta data for this sessionid: %s \n', sessionid);
                    
                otherwise 
                    disp('ERROR: Unknown optical recording system')
                    
            end  % What optical recording setup ws used
                   
        otherwise
            disp('Unkown setup type; Please enter setup metadata.')
    end
    