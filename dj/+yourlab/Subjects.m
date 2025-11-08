%{
# subjects
subjectid   : varchar(50)      # unique name
---
species     : varchar(10) 
projectidx  : int(3)
idx         : int(5) auto_increment
genotype = NULL     : varchar(20)
sex         : enum('M', 'F', 'U')   #sex - Male, Female, or Unknown
birthdate = NULL    : date
age = NULL  : varchar(30)        # age : days, weeks, months, years
weight      : varchar(20)
hemisphere  : enum('l', 'r', 'u')   # which hemisphere
location = NULL     : varchar(60)   # location/ area in brain
shortdescr = NULL   :varchar(250)
%}

classdef Subjects < dj.Manual
end