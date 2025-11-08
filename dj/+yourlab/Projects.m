%{
# projects
projectid                   : varchar(50)                   # unique name
---
idx : int(3) auto_increment
url=null                    : varchar(250)                  # 
shortdescr=''               : varchar(250)                  # 
longdescr=''                : varchar(6000)                 # 
author=''                   : varchar(100)
entrydate                   : timestamp
status                      : tinyint(1)
department_name             : varchar(60)
%}
classdef Projects < dj.Manual
end
