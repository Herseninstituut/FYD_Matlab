function Sessions = getSessions(varargin)

 p = inputParser;
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

% import credentials
dbpar = nhi_fyd_MVPparms();

setenv('DJ_HOST', dbpar.Server)
setenv('DJ_USER', dbpar.User)
setenv('DJ_PASS', dbpar.Passw)

Con = dj.conn();

query = leveltlab.Sessions;

Sessions = fetch(query & strSel, 'dataset', 'subject', 'excond', 'stimulus', 'date', 'sessionid', 'url', 'server');
urls = arrayfun(@geturl, Sessions, 'UniformOutput', false);
urls =  fileparts(urls);
for i = 1:length(Sessions)
 Sessions(i).url = urls{i};
end

%Sessions = rmfield(Sessions, 'idx');
Sessions = rmfield(Sessions, 'server');
end

function url = geturl(obj)
    switch obj.server
        case {'VS03', 'VS01'}
            url = fullfile(strrep(obj.url, 'mnt', ''));
            
        otherwise
            url = fullfile(strrep(obj.url, './', ['\\' obj.server '\']));
    end
end
