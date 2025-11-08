%{
# sessions
sessionid    : varchar(100)                  # unique name
idx          : int(11) autoincrement
---
url          : varchar(500)                  # 
server       : varchar(30)                   # 
-> yourlab.Projects
-> yourlab.Datasets
-> yourlab.Subjects
-> yourlab.Stimulus
-> yourlab.Conditions
-> yourlab.Setups
date         : date
logfile      : varchar(60)
-> yourlab.Researcher
%}

classdef Sessions < dj.Manual
end
