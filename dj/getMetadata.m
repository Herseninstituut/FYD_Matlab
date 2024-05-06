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
    check_entries(dataset_meta, 'dataset_meta')
    
    stim_meta = getStimulus(stim);
    check_entries(stim_meta, 'stim_meta')
    
    subject_meta = getSubjects(subject); % multiple subjects as cell array
    check_entries(subject_meta, 'subject_meta')
    
    setup_meta = getSetup(setup);
    if ~isempty(setup_meta)
        check_entries(setup_meta, 'setup_meta')
    else 
        disp('ERROR: No setup metadata, aborting.')
        return
    end
    
    metadata = struct('sess_meta', sess_meta, 'dataset_meta', dataset_meta, ...
                       'stim_meta', stim_meta, 'subject_meta', subject_meta, ...
                       'setup_meta', setup_meta );
    Okay = true;
    
    %% Retreive probe, contact and channel metadata from the database, selecting by subject for ephys data
    
    if strcmp(setup_meta.type, 'ephys') %this is an electrophysiology dataset
        Okay = false;
        
        key = ['subject="', subject,'"'];
        probe_meta = fetch(bids.Probes & key, '*'); % '*' -> retrieve all fields
        if isempty(probe_meta)
            %nwblog('<br>Probe metadata not present, please upload probe table')
            disp('Probe metadata not present, please upload probe, contact and channel table')
            return
        end
        contact_meta = fetch(bids.Contacts & key, '*');
        if isempty(contact_meta)
            %nwblog('<br>Contact metadata not present, please upload contact table')
            disp('Contact metadata not present, please upload contact and channel table')
            return
        end
        chan_meta  = fetch(bids.Channels & key, '*');
        if isempty(contact_meta)
            %nwblog('<br>Channel metadata not present, please upload channel table')
            disp('Channel metadata not present, please upload channel table')
            return
        end

        metadata.probe_meta = probe_meta;
        metadata.contact_meta = contact_meta;
        metadata.chan_meta = chan_meta;
        
        Okay = true;
        
    elseif isempty(setup_meta.type)
        disp('Unkown setup type; Please enter setup metadata.')
    end
    