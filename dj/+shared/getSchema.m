function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'shared', 'shared');
end
obj = schemaObject;
end
