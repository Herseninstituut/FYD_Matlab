function metadata = neurolabware(filepath, ophys, metadata)

global info                  

fnNormcorr = [filepath '_normcorr']; % registered imaging movie


if ~isfile([fnNormcorr '.sbx']) 
    disp('ERROR: Normcorr.sbx file is not present in this folder.')
end
if isfile([filepath '.sbx'])

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
    FrameTimes = (1:info.max_idx) * Tframe;

    ophys.number_of_trials = sum(info.event_id== 1);
    ophys.task_name = metadata.task_meta.task_name;
    ophys.task_description = metadata.task_meta.task_description;

%                 path_ophys = fullfile(sess_meta.url, [sess_meta.sessionid '_ophys.json']);
%                 f = fopen(path_ophys, 'w' ); 
%                 txtO = jsonencode(ophys);
%                 fwrite(f, txtO);
%                 fclose(f);
    metadata.ophys = ophys;

    events = struct();
    %Is there a running record ?
    sess_meta = metadata.sess_meta; % get basic session metadata   
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
        else
            disp("WARNING: Run recording invalid")
        end
        clear quad
    else
        disp('Warning: No running record'); 
    end

    %Is there an eye position / pupil record defined by _eye.mat
    path_eye = fullfile(sess_meta.url, [sess_meta.sessionid '_eye.mat']);
    path_facemap = fullfile(sess_meta.url, [sess_meta.sessionid '_proc.mat']);
    if isfile(path_eye)
        pupil = load(path_eye, 'eye', 'time');
        if isfield(pupil, 'eye')
           struct_eye = struct('time', pupil.time, 'Pos', pupil.eye.Pos(:,:), 'Area', pupil.eye.Area);
           events.pupil_events = struct2table(struct_eye); 
          % save(path_evts, 'pupil_events', '-append') 
           clear pupil
        else
            disp("WARNING: Eye recording invalid. Please extract eye position and area.")
        end

    elseif isfile(path_facemap)  
        fm = load(path_facemap, 'Parameters', 'log', 'pupil');
        if isfield(fm, 'Parameters') && isfield(fm, 'log') 
            Parameters = fm.Parameters;
            log = fm.log;
            path_log = fullfile(sess_meta.url, [sess_meta.sessionid '_log.mat']);
            save(path_log, 'Parameters', 'log')  
        end   
        if isfield(fm, 'pupil') 
            pupil = fm.pupil{1};
            struct_eye = struct('time', FrameTimes(:), 'Pos', pupil.com_smooth, 'Area', pupil.area_smooth(:));
            events.pupil_events = struct2table(struct_eye); 
        end
    else
        disp("WARNING: No eye recording to add")
    end

    % Trial events and their identity which depends on the task
    path_log = fullfile(sess_meta.url, [sess_meta.sessionid '_log.mat']);   
    trial_onsets = framevents(info.event_id==1) * Tframe + info.line(info.event_id==1) * Tline;
    % other_events = framevents(info.event_id==2) * Tframe + info.line(info.event_id==2) * Tline;
    events.task_events = table;
    events.task_events.times = trial_onsets;
    
    
    if isfile(path_log)
        stim = load(path_log);
        flds = fields(stim);
        if isfield(stim, 'Parameters')
            events.task_parameters = stim.Parameters;
        end
        if isfield(stim, 'log')
            log = stim.log;
            % get the events associated with the stimulus
            % onsets: event_id == 1
            if length(log) == length(trial_onsets) % Should be the same number
                events.task_events.log = log;
            end
        else
            disp(['WARNING: no logfile for stimulus: ' sess_meta.stimulus])
        end

       if isfield(stim, 'Texary') % This is to store a texture array in the event table
            tex = stim.Texary;
            tex = int8(tex);
            if size(tex,3) == length(trial_onsets) % Should be the same number
                tex = shiftdim(tex,2);
                events.task_events.texture = tex;
            end
        end


        % It could be usefull to save the remaining fields whatever they are
        ix = contains(flds, {'Parameters', 'log', 'Texary'});
        stim = rmfield(stim, flds(ix));
        flds = fields(stim);
        for i = 1:length(flds)
            events.(flds{i}) = stim.(flds{i});
        end
    else
        disp('WARNING: no log file....')
    end

    metadata.events = events;

   % get ROI metadata; What software was used to process the 2p
   % data; Suit2p, SpecSeg, ...
   switch  lower(ophys.image_processing_toolbox)
       case 'specseg'  % Then this session should contain a SPSIG file
           if isfile([fnNormcorr '_SPSIG.mat'])
               spsig = load([fnNormcorr '_SPSIG.mat'], 'Mask', 'frameTimes', 'sigCorrected');
               if ~(isfield(spsig, 'Mask') && isfield(spsig, 'sigCorrected'))
                   disp('WARNING:: Missing ROI data, please run retrievesignals on this SPSIG file.')
               end
               metadata.ROI_data = spsig;
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
