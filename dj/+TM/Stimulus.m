%{
# stimulus
stimulusid : varchar(30)      # unique name
---
idx : int(6) auto_increment
url = NULL : varchar(250)
shortdescr = NULL : varchar(250)
longdescr = NULL : varchar(3000)
%}

classdef Stimulus < dj.Manual
end