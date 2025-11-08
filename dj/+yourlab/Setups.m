%{
# setups
setupid     : varchar(30)      # unique name
---
url = NULL  : varchar(250)
type = NULL :enum("fMRI", "ephys", "ophys")
shortdescr = NULL : varchar(250)
longdescr = NULL : varchar(6000)
%}

classdef Setups < dj.Manual
end