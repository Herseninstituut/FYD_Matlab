%{
# sessions
sessionid                   : varchar(50)                   # unique name
url                         : varchar(250)                  # 
server                      : varchar(20)                   # 
---
idx : int(11) autoincrement
-> kamermanslab.Projects
-> kamermanslab.Datasets
-> kamermanslab.Subjects
-> kamermanslab.Stimulus
-> kamermanslab.Conditions
-> kamermanslab.Setups
date : date
logfile : varchar(50)
-> kamermanslab.Researcher
%}

classdef Sessions < dj.Manual
end
