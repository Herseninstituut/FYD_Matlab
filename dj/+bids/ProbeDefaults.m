%{
    # default probes table 
    name                    : varchar(60) # REQUIRED - A unique identifier of the probe
    ---
    manufacturer            : varchar(60)   # REQUIRED - Manufacturer of the probes system 
    probe_type              : varchar(60)  # REQUIRED - The type of the probe
    material                : varchar(60)  # A textual description of the base material of the probe.
    width                   : int   # Physical width of the probe
    height                  : int   # height
    depth                   : int   # depth
    dimension_unit          : varchar(30)
    contact_count           : int  # Number of miscellaneous analog contacts for auxiliary signals 
%}

classdef ProbeDefaults < dj.Manual
end