function record = mysqlupdate(db, varargin)
%UPDATE `2PData` SET `Date` = '20161027' WHERE `2PData`.`Datetime` = '20170123_144901';

DB = db.Database;
TBL = db.Tbl;
fields = db.Fields;

if length(varargin) < 2 
    disp('Error: At least two inputs (field and value to set), third input WHERE URL = clause!')
    return
    
elseif length(varargin) == 3   
    strWhere = varargin{3};
    
else
    strWhere = '1';
end

strField = varargin{1};
if ~any(strcmp(fields, strField))
        disp(['Error: field not present: ' strField] )
    return
end

strVal = varargin{2};
if ~ischar(strVal) || ~ischar(strWhere)
            disp('Error: Values are not strings! ')
    return
end


QUERY = ['UPDATE ' DB '.' TBL ' SET ' strField ' = "' strVal '" WHERE ' TBL '.URL = "' strWhere '"'];

mysql('open', db.Server, db.User, db.Passw);
mysql('use', DB);
record = mysql(QUERY);
mysql('close');