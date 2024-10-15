%{
# researcher
investigatorid : varchar(30)      # unique name
---
idx : int(3) auto_increment
email = NULL : varchar(100)
%}

classdef Investigator < dj.Manual
end