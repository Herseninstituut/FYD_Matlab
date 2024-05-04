%{
# projects
projectid                   : varchar(30)                   # unique name
---
idx : int(3) auto_increment
url=null                    : varchar(250)                  # 
shortdescr=null             : varchar(250)                  # 
longdescr=null              : varchar(6000)                 # 
%}
classdef Projects < dj.Manual
end
