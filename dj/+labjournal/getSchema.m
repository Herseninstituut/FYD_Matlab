function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'labjournal', 'labjournal');
end
obj = schemaObject;
end
