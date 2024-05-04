function Sessions = getSessions(varargin)
% urls = getSessions(project='someProject', subject='aSubject')

%Database access with Datajoint
global dbpar

 p = inputParser;
 addOptional(p,'sessionid','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'project','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'dataset','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'excond','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'subject','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'stimulus','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'setup','-',@(x)validateattributes(x,{'char'},{'nonempty'}))
 addOptional(p,'date','-',@(x)validateattributes(x,{'char'},{'nonempty'}))

 
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
        if ~strcmp(val, '-')
            if isempty(strSel)
                strSel = [fld '="' val '"'];
            else
                strSel = [strSel ' AND ' fld '="' val '"'];
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
%converts from linux path to path of user system
urls = arrayfun(@geturl, Sessions, 'UniformOutput', false);
urls =  fileparts(urls);

if length(Sessions) > 1
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
        case {'VS03', 'VS01'}
            url = fullfile(strrep(obj.url, 'mnt', ''));
            
        otherwise
            url = fullfile(strrep(obj.url, './', ['\\' obj.server '\']));
    end
end
