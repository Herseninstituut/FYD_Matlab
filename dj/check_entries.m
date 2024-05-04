function check_entries( metadata, name)
    if isstruct(metadata)
        flds = fields(metadata);
        for i=1:length(flds)
             if isempty(metadata.(flds{i}))
                 disp(['Entry: ', flds{i}, ' in ', name, ' has no value'])
             end
        end
    end