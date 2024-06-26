function setup_meta = getSetup( setupname )

global dbpar

Database = dbpar.Database;  %= yourlab
query = eval([Database '.Setups']); % setups table in FYD database for particular lab
Sel = ['setupid= "', setupname, '"'];
metadata = fetch(query & Sel, 'shortdescr', 'longdescr', 'type');
setup_meta = [];

if strcmp(metadata.type, 'ephys')
    query = bids.Ephys;  %ephys table in bids general database
    Sel = ['recording_setup= "' setupname '"'];
    setup_meta = fetch(query & Sel, '*' );
    
elseif strcmp(metadata.type, 'ophys')
    query = bids.Ophys;  %ephys table in bids general database
    Sel = ['recording_setup= "' setupname '"'];
    setup_meta = fetch(query & Sel, '*' );
    
else 
    disp('No type information for this setup! Cannot retrieve bids data.')
end

if ~isempty(setup_meta)
    setup_meta.shortdescr = metadata.shortdescr;
    setup_meta.longdescr = metadata.longdescr;
    setup_meta.type = metadata.type;
end