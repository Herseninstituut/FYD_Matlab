%{
# example table
-> dbsomelab.Sessions
---

dataset     : varchar(50)   
subject     : varchar(30)
excond      : varchar(30)
stimulus    : varchar(30)
date        : date
url         : varchar(250)
okay        : varchar(8)
%}

classdef Example < dj.Imported
    properties (Dependent)
        keySource
    end
    methods(Access=protected)
        function makeTuples(self, key)
            [dataset, subject, excond, stimulus, date, url, server] = fetch1(dbsomelab.Sessions & key, 'dataset', 'subject', 'excond', 'stimulus', 'date', 'url', 'server'); 
            key.dataset = dataset;
            key.subject = subject;
            key.excond = excond;
            key.stimulus = stimulus;
            key.date = date;
            key.url = self.geturl(url, server);
            key.okay = questdlg('Was this experiment successfull', 'Okay?', 'yes', 'no', 'yes');
            self.insert(key);
        end
    end
    methods
        function val = get.keySource(~)
            val = leveltlab.Sessions & 'project="aproject" AND excond="some_condition"';
        end
        function url = geturl(~, urlin, server)
            switch server
                case {'VS03', 'VS01'}
                    url = fullfile(strrep(urlin, 'mnt', ''));

                otherwise
                    url = fullfile(strrep(urlin, './', ['\\' server '\']));
            end
        end
    end
end