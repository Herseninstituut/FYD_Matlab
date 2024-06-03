%%BIDS - Datajoint Examples ; update or retrieve from various Tables with Datajoint 
% this script shows you how to use Datajoint to generate and retrieve metadata
% Since Neurodata Without Borders uses yaml files for their templates I
% have now also adoptied this because they can also be viewed in matlab as
% of 2024 with syntax highlighting

initDJ('yourlab') % credentials to access the database and initialization of Datajoint


%% Structure template to create BIDS channels columns 

% The 'ephys_channels.yaml' template for electrophysiology defines BIDS spcific fields that 
% should be saved to a channels.tsv file
% You can comment out fields in the template to create a structure array with fields of your
% choice, (the channel_id and contact_id field are required). 
% Although the subject entry is not required, it's a good idea to register the subject, since channels, contacts and possibly 
% also probes will be specific for a subject. Then you can query the table using
% subject as a key. 
% fields in the template either have '' or 0 as default entry, which 
% means they either require a string or a value as an input.

% channelsJson = get_json_template('ephys_channels.jsonc');
channel_templ = yaml.loadFile('ephys_channels.yaml');


%% EXAMPLE CREATING A CHANNEL ARRAY
% Retrieve the field names (you need these to create a structure array,
% if your metadata is generated from cell array.
chanFields = fields(channel_templ);

numberOfChannels = 64;
%This creates a cell array with metadata for multiple channels 
subject_id = 'monkeyX';
system_id = 'Blackrock1';
chanCell = cell(length(chanFields), numberOfChannels);
for i = 1:numberOfChannels  
    chanCell(:,i) = {subject_id, system_id, ['channel_' num2str(i)], ['Contact_' num2str(i)], 'EXT', 'mV', 30, 'KHz',...
        'Multiunit Activity', 'MUAe', '', 'High Pass, rectification, Low Pass', ...
        '', '', '', num2str(randi(10,1)), 0, 1.0, ...
         -1, 'Chamber screw', ''};
end

%CONVERT to Structure Array 
channel_meta = cell2struct(chanCell, chanFields, 1);

%% Save the records directy to the bids database (please contact us if this doesn't work)
insert(bids.Channels, channel_meta)

%% Retreive channel metadata from the database, selecting by subject
channel_meta  = fetch(bids.Channels & ['subject="' subject_id '"'], '*'); % this gets all the fields of each record

%this will get all possible columns which you might not want, 
% to restrict the output to the fields you used to generate this metadata
channel_meta = removefields(channel_meta, chanFields); %string cell array of channels
channel_meta = keepfields(channel_meta, chanFields);

%% saving the channel metadata to a tsv file
temp_folder = uigetdir();
ChannelTbl = struct2table(channel_meta);
writetable(ChannelTbl, fullfile(temp_folder, 'channels.tsv'), ...
       'FileType', 'text', ...
       'Delimiter', '\t');
 
   
  
%% Structure template to create BIDS electrodes columns %%%%%%%%%%%%%%%%%%%%%

% contactsJson = get_json_template('ephys_contacts.jsonc');
electrodes_templ = yaml.loadFile('ephys_electrodes.yaml');
contactFields = fields(electrodes_templ);

%Generate contact Metadata structure array from an Excel spreadsheet.
%Make sure they have the correct column names or convert!!!!
electrode_meta = readtable("electrodes.xls");

% import from  tsv table    
electrode_meta = readtable("electrodes.tsv", "FileType","text", 'Delimiter', '\t');

% Save the records to the BIDS database  ->Electrode table
insert(bids.Electrodes, electrode_meta)

% save the channel metadata to a tsv file
electrodeTbl = struct2table(electrode_meta);
writetable(electrodeTbl, fullfile(temp_folder, 'electrodes.tsv'), ...
       'FileType', 'text', ...
       'Delimiter', '\t');

   
%% This is a structure template to create BIDS probe columns
% ... note that the probe_id should be unique! ......

% probeJson = get_json_template('ephys_probes.jsonc');
probe_templ = yaml.loadFile('ephys_probes.yaml');

%Fields in the template to create a structure array
probeFields = fields(probe_templ);

%EXAMPLE Create probes CELL araay
numberOfProbes = 2;
%This creates a cell array with some random metadata for multiple probes
probCell = cell(length(probeFields), numberOfProbes);
for i = 1:numberOfProbes  
    probCell(:,i) = {['Nx_A',num2str(i)], 'L01', 'Neuronexis', '', '', ['L01_' num2str(i)], ...
        'neuronexis-probe', 'silicon', randn(1), randn(1), randn(1), ...
        100, 2000, 2000, 'um', 60, 'left', 'V1', 'Paxinos'};
end

% Convert the cellarray to a structure array and insert in BIDS database -> Probes table
probe_meta = cell2struct(probCell, probeFields, 1);
insert(bids.Probes, probeMeta)

probeTbl = struct2table(probe_meta);
writetable(probeTbl, fullfile(temp_folder, 'probes.tsv'), ...
       'FileType', 'text', ...
       'Delimiter', '\t');


%% Show contents of the bids tables
bids.Channels %Show table contents
describe(bids.Channels) % Show table structure

bids.Contacts %Show table contents
describe(bids.Contacts) % Show table structure

bids.Probes %Show table contents
describe(bids.Probes) % Show table structure

%% update records (datajoint doesn't allow updates to maintain consistency over a database)
% we need to retrieve the records we want to change, delete them in the
% database, update a value in each record and then insert them again.


%% CAREFULL: Only delete entries in table bids.Probes where the subject is L01
del(bids.Probes & 'subject="monkeyX"') 
