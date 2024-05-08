%{
# projects
projectid                   : varchar(30)                   # unique name
---
idx : int(3) auto_increment
url=null                    : varchar(250)                  # 
shortdescr=null             : varchar(250)                  # 
longdescr=null              : varchar(6000)                 # 
author=null		            : varchar(100)                  #
entrydate 		            : timestamp
status			            : tinyint(1)
institution_name            : varchar(60)
department_name             : varchar(60)
%}
classdef Projects < dj.Manual
end
