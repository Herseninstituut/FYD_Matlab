%{
# conditions
conditionid : varchar(30)      # unique name
---
idx : int(3) auto_increment
shortdescr = NULL : varchar(250)
longdescr = NULL : varchar(3000)
%}

classdef Conditions < dj.Manual
end