%{
# sessions
sessionid                   : varchar(50)                   # unique name
url                         : varchar(250)                  # 
server                      : varchar(20)                   # 
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
-> yourlab.Researcher
%}

classdef Sessions < dj.Manual
end
