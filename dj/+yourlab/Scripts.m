%{
# scripts
scriptid : varchar(30)      # unique name
---
idx : int(3) auto_increment
url = NULL : varchar(250) 
fileex : varchar(5)
shortdescr = NULL : varchar(250)
longdescr = NULL : varchar(3000)
%}

classdef Scripts < dj.Manual
end