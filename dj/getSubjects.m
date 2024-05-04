function  subjects = getSubjects( subnames )

global dbpar

subjects = [];
if nargin == 0
     return
else
    strSel = '';
    if iscell(subnames)  % is this a cell array of subject names or njust one name
        for i = 1: length(subnames)
            if i == 1
                strSel = ['subjectid="' subnames{i} '"' ]; 
            else
                strSel = [strSel ' OR subjectid="' subnames{i} '"' ];
            end
        end
    else
        strSel = ['subjectid="' subnames '"' ];
    end
end

if strSel == ""
    return
end


Database = dbpar.Database;  %= yourlab
query = eval([Database '.Subjects']);

subjects = fetch(query & strSel, 'species', 'genotype', 'sex', 'birthdate', 'shortdescr');



