%{
# nwblist
sessionid : varchar(60) 
---
lab : varchar(60)
status : enum('todo', 'doing', 'done')  
%}

classdef Nwblist < dj.Manual
end