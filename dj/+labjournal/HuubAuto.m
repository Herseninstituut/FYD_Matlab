%{
     # Huub's automated lab Journal
     sessionid                   : varchar(100)                  # 
     ---
     url                         : varchar(500)                  # 
     dataset                     : varchar(50)                   # 
     condition                   : varchar(30)                   # 
     subject                     : varchar(30)                   # 
     genotype=null               : varchar(20)                   # 
     sex="U"                     : enum('M','F','U')             # 
     age=null                    : varchar(30)                   # age : days, weeks, months, years
     hemisphere=null             : enum('l','r','u')             # which hemisphere
     location=null               : varchar(60)                   # 
     date                        : date                          # 
     setup                       : varchar(30)                   # 
     stimulus                    : varchar(50)                   # 
     screen_distance=null        : int                           # 
     stim_time=null              : float                         # 
     comment = null              : varchar(500)                  # 
%}

classdef HuubAuto < dj.Imported
    properties (Dependent)
        keySource
    end
    methods(Access=protected)
        function makeTuples(self, key)
            [dataset, subject, excond, stimulus, date, url, setup] = fetch1(leveltlab.Sessions & key, 'dataset', 'subject', 'excond', 'stimulus', 'date', 'url', 'server'); 
            Subject_meta = fetch(leveltlab.Subjects & ['subjectid="' subject '"'], 'genotype', 'age', 'sex', 'hemisphere', 'location');

            key.url = self.geturl(url);
            key.dataset = dataset;
            key.subject = subject;
            key.genotype = Subject_meta.genotype;
            key.sex = Subject_meta.sex;
            key.age = Subject_meta.age;
            key.hemisphere = Subject_meta.hemisphere;
            key.location = Subject_meta.location;
            key.condition = excond;
            key.stimulus = stimulus;
            key.date = date;
            key.setup = setup;

            p2json = fullfile(key.url, [key.sessionid '_session.json']);
            J = loadjson(p2json);
            key.screen_distance = J.display.ScreenDistance;
              comment = '';
            if isfield(J, 'comment')
               comment = J.comment;
            end
            key.comment = comment;

            try
                log = load(fullfile(key.url, [key.sessionid  '_log.mat']));
                stim_time = log.Parameters.time;
            catch
                stim_time = 0;
            end
            key.stim_time = stim_time;

            self.insert(key);
        end
    end
    methods
        function id = get.keySource(~)
            id = labjournal.HuubRecords;
        end
        function url = geturl(~, urlin)
             url = fileparts(fullfile(strrep(urlin, 'mnt', '')));
        end
    end
end