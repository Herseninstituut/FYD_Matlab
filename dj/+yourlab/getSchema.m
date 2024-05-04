function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'yourlab', 'yourlab');
end
obj = schemaObject;
end
