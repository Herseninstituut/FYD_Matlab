%{
# sessions
sessionid                   : varchar(50)                   # unique name
url                         : varchar(250)                  # 
server                      : varchar(20)                   # 
---
idx : int(11) autoincrement
-> leveltlab.Projects
-> leveltlab.Datasets
-> leveltlab.Subjects
-> leveltlab.Stimulus
-> leveltlab.Conditions
-> leveltlab.Setups
date : date
logfile : varchar(50)
-> leveltlab.Researcher
%}

classdef Sessions < dj.Manual
end
