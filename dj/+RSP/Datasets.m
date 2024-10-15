%{
# datasets
datasetid                   : varchar(30)                   # unique name
projectidx                  : int(3)                        # 
---
idx                         : int(3) auto_increment
shortdescr=null             : varchar(250)                  # 
longdescr=null              : varchar(6000)                          # 
%}

classdef Datasets < dj.Manual
end
