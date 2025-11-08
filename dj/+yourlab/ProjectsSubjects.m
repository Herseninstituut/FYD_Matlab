%{
# projects_subjects
project     : varchar(50)      # unique name
subject     : varchar(50)
---
projectidx  : int(3)
subjectidx  : int(3)
%}

classdef ProjectsSubjects < dj.Manual
end