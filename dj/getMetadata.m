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
    
    metadata = struct('sess_meta', sess_meta, 'dataset_meta', dataset_meta, ...
                       'task_meta', task_meta, 'subject_meta', subject_meta, ...
                       'setup_meta', setup_meta );
    Okay = true;
    
    %% Retrieve recording method metadata. This will be a combination of metadata
    % entered on the webapp and data retrieved from the recorded files.
    
    switch lower(setup_meta.type)
        case 'ephys' %this is an electrophysiology dataset
            ephys = yaml.loadFile('template_ephys.yaml');
            flds = fields(ephys);
            for i = 1:length(flds)
                if isfield(setup_meta, flds{i}), ephys.(flds{i}) = setup_meta.(flds{i}); end
                if isfield(dataset_meta, flds{i}), ephys.(flds{i}) = dataset_meta.(flds{i}); end
                if isfield(task_meta, flds{i}), ephys.(flds{i}) = task_meta.(flds{i}); end
                if isfield(subject_meta, flds{i}), ephys.(flds{i}) = subject_meta.(flds{i}); end
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

        case 'ophys'  %see template_ophys.yaml
            
            ophys = yaml.loadFile('template_ophys.yaml');
            flds = fields(ophys);
            for i = 1:length(flds)
                if isfield(setup_meta, flds{i}), ophys.(flds{i}) = setup_meta.(flds{i}); end
                if isfield(dataset_meta, flds{i}), ophys.(flds{i}) = dataset_meta.(flds{i}); end
                if isfield(task_meta, flds{i}), ophys.(flds{i}) = task_meta.(flds{i}); end
            end
            % these are retrieved from the template
            metadata.dataset_meta.institution_name = ophys.institution_name;
            metadata.dataset_meta.institution_adress = ophys.institution_adress;
            
            filepath = fullfile(sess_meta.url, sess_meta.sessionid);
            if isfile([filepath '_normcorr.sbx']) 
                filepath = [filepath '_normcorr'];
            end
            if isfile([filepath '.sbx'])
                global info
                sbxread(filepath, 0, 0);
                scanmode = info.scanmode;
                if scanmode == 1
                    ophys.image_acquisition_protocol = 'unidirectional';
                    Tline = 1.0/info.resfreq; %unidirectinal
                    Tframe = 512/info.resfreq; %frame time in both cases is rows/resonance freq
                else 
                    ophys.image_acquisition_protocol = 'bidirectional';
                    scanmode = 2;
                    Tline = 0.5/info.resfreq; %bidirectional,
                    Tframe = 256/info.resfreq;            
                end
               % dims = [info.Shape(1), info.Shape(2), info.max_idx];
                ophys.laser_excitation_wave_length = [num2str(info.config.wavelength) 'nm'];
                ophys.sampling_frequency = info.resfreq * scanmode /(info.Shape(2) * info.Shape(3));
                ophys.pixel_dimensions = num2str([info.Shape(1) info.Shape(2)]);
                ophys.channels = info.Shape(3);
                ophys.recording_duration = [num2str(ceil(info.max_idx / ophys.sampling_frequency)) 's'];
                ophys.number_of_frames = info.max_idx;
                ophys.objective = info.objective;
                ophys.numerical_aperture = 0.8;
                ophys.magnification = info.config.magnification;
                ophys.firmware = info.firmware;
                ophys.scanning_frequency = [num2str(info.resfreq) 'Hz'];
                
                %There is a problem with the frame events from the
                %Neurolabware system, in that their numbers fold back to
                %zero after uint16 max (65535)
                framevents = info.frame;
                ix = find(diff(framevents) < 0); 
                 if ~isempty(ix)
                     for i=1:length(ix)
                         framevents(ix(i)+1:end) = framevents(ix(i)+1:end) + 65535;
                     end
                 end
                
                events = struct();
                task_events = struct( 'time', framevents * Tframe + info.line * Tline, 'event_id', info.event_id);
                %path_evts = fullfile(sess_meta.url, [sess_meta.sessionid '_events.mat']);
                %save(path_evts, 'task_events')  
                events.task_events = struct2table(task_events);
          
                ophys.number_of_trials = sum(task_events.event_id == 1);
                ophys.task_name = task_meta.task_name;
                ophys.task_description = task_meta.task_description;
                

                path_ophys = fullfile(sess_meta.url, [sess_meta.sessionid '_ophys.json']);
                f = fopen(path_ophys, 'w' ); 
                txtO = jsonencode(ophys);
                fwrite(f, txtO);
                fclose(f);
                metadata.ophys = ophys;
                
                %Is there a running record ?
                path_quad = fullfile(sess_meta.url, [sess_meta.sessionid '_quadrature.mat']);
                if isfile(path_quad)
                    quad = load(path_quad); %loads quad_data!
                    if isfield(quad, 'quad_data')
                        quad = quad.quad_data;
                        Times = (1:length(quad))'*Tframe;
                        quad(quad < 0) = 0; %get rid of negative artifacts
                        % See sbxgettimeinfo; this is rather arbitrary:
                        % what arduino script was used to record this?

                        circumference = 2*pi*10; % in cm
                        Speed = circumference * double(quad)/1000; % in cm/s
                        events.run_events = struct2table(struct( 'speed', Speed(:), 'time', Times(:)));
                        %save(path_evts, 'run_events', '-append')  
                    end
                    clear quad
                else
                    disp('Warning: No running record'); 
                end
                
                %Is there an eye position / pupil record
                path_eye = fullfile(sess_meta.url, [sess_meta.sessionid '_eye.mat']);
                if isfile(path_eye)
                    pupil = load(path_eye, 'eye', 'time');
                    if isfield(pupil, 'eye')
                       events.pupil_events = struct2table(pupil); 
                      % save(path_evts, 'pupil_events', '-append') 
                       clear pupil
                    else
                        disp("WARNING: No eye recording to add")
                    end
                end
                

                metadata.event_tbl = events;

               % get ROI metadata; What software was used to process the 2p
               % data; Suit2p, SpecSeg, ...
               switch  lower(ophys.image_processing_toolbox)
                   case 'specseg'  % Then this session should contain a SPSIG file
                       if isfile([filepath '_SPSIG.mat'])
                           spsig = load([filepath '_SPSIG.mat'], 'Mask', 'frameTimes', 'sigCorrected');
                           if isempty(spsig.frameTimes) || isempty(spsig.sigCorrected) 
                               disp('WARNING:: Missing ROI data, please run retrievesignals on this SPSIG file.')
                           end
                           metadata.ROIdata = spsig;
                       else 
                           disp('NO SPSIG file for this session, Please add or run the SpecSeg pipeline to generate this file')
                           return
                       end
                       
                   case ''
                       disp('Missing imaging_processing_toolbox in the metadata for this setup')
                   
                   otherwise
                       disp('This image processing toobox is not yet implemented!')
               end
                    
                
            else
                disp('sbx file does not exist, cannot retrieve metadata from file.')
                return
            end
            
        
        otherwise
            disp('Unkown setup type; Please enter setup metadata.')
    end
    