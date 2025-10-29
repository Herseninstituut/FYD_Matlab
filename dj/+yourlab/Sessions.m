%{
# sessions
sessionid                   : varchar(100)                   # unique name
url                         : varchar(500)                  # 
server                      : varchar(30)                   # 
---
idx : int(11) autoincrement
-> yourlab.Projects
-> yourlab.Datasets
-> yourlab.Subjects
-> yourlab.Stimulus
-> yourlab.Conditions
-> yourlab.Setups
date : date
logfile : varchar(50)
-> yourlab.Investigator
%}

classdef Sessions < dj.Manual
end
