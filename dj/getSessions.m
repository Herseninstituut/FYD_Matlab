function Sessions = getSessions(varargin)
% urls = getSessions(project='someProject', subject='aSubject')
% valid entries;
% sessionid, project, dataset, condition, subject, stimulus, setup, investigator
% date as '< date', '> date' or 'date - date'

%Database access with Datajoint
global dbpar

 p = inputParser;
 addOptional(p,'sessionid','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'project','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'dataset','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'condition','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'subject','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'stimulus','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'setup','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'date','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'server','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'investigator','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 
if nargin == 0
     return
else
   parse(p,varargin{:})
   Ins = p.Results;
   flds = fields(Ins);
   strSel = '';
   for i = 1:length(flds)
       fld = flds{i};
       val = Ins.(fld);
       if strcmp(fld, 'investigator') %in database this is investid
           fld = 'investid';
       elseif strcmp(fld, 'condition')
           fld = 'excond';
       end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
        if ~strcmp(val, '-')
            if strcmp(fld, 'date')
                resa = regexp(val, '^[<>] ', 'match');
                resb = regexp(val, '\d{4}-\d{2}-\d{2} +- +\d{4}-\d{2}-\d{2}', 'match');
                if ~isempty(resa)
                    val = erase(val, resa{1});
                    whereclause = [fld ' ' resa{1} '"' val '"'];
                elseif ~isempty(resb)
                    val = split(resb{1}, ' - ');
                    val = strip(val);
                    whereclause = [fld ' > "' val{1} '" AND ' fld ' < "' val{2} '"'];
                else
                    whereclause = [fld '="' val '"'];
                end
            else
                whereclause = [fld '="' val '"'];
            end
            
            if isempty(strSel)
                strSel = whereclause;
            else
                strSel = [strSel ' AND ' whereclause];
            end
        end
   end
end

if isempty(strSel)                                                                                                                                                                                                                                                                      
    return
end

Database = dbpar.Database;  %= yourlab
query = eval([Database '.Sessions']);

Sessions = fetch(query & strSel, 'project', 'dataset', 'subject', 'excond', 'stimulus', 'date', 'sessionid', 'url', 'setup', 'server');

if isempty(Sessions)
    return
end
%converts from linux path to path of user system
urls = arrayfun(@geturl, Sessions, 'UniformOutput', false);
urls =  fileparts(urls);

if iscell(urls)
    for i = 1:length(Sessions)
     Sessions(i).url = urls{i};
    end
else
    Sessions.url = urls;
end

%Sessions = rmfield(Sessions, 'idx');
end

function url = geturl(obj)
   switch obj.server
       case {'VS03', 'VS01', 'mnt'}
            url = fullfile(erase(obj.url, 'mnt'));

       otherwise
           url = fullfile(strrep(obj.url, './', ['\\' obj.server '\']));
   end
end
