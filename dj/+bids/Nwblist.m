%{
# nwblist
sessionid : varchar(60) 
---
url : varchar(500)
status : enum('todo', 'doing', 'done')  
%}

classdef Nwblist < dj.Manual
end