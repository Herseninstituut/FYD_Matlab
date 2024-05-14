function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'bids', 'bids');
end
obj = schemaObject;
end
