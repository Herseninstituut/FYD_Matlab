function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'TM', 'TM');
end
obj = schemaObject;
end
