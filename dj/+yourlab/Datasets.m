%{
# datasets
datasetid                   : varchar(50)                   # unique name
project                     : varchar(50)
---
projectidx                  : int(3)                        # 
idx                         : int(3) auto_increment
shortdescr=null             : varchar(250)                  # 
longdescr=null              : varchar(6000)                          # 
%}

classdef Datasets < dj.Manual
end
