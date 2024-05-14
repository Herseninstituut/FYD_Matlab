%{
    # probes table for BIDS probes tsv
    probe_id            : varchar(60) # REQUIRED - A unique identifier of the probe
    ---
    subject             : varchar(50) # subject identifier
    manufacturer        : varchar(60)   # REQUIRED - Manufacturer of the probes system 
    manufacturers_model_name        : varchar(60)  # REQUIRED - 
    manufacturer_model_version      : varchar(60)
    device_serial_number            : varchar(30)
    probe_type          : varchar(60) # REQUIRED - The type of the probe
    material            : varchar(60) # A textual description of the base material of the probe.
    x                   : float # coordintaes of probe in subject
    y                   : float 
    z                   : float 
    width               : int   # Physical width of the probe
    height              : int   # height
    depth               : int   # depth
    dimension_unit      : varchar(30)
    contact_count       : int  # Number of miscellaneous analog contacts for auxiliary signals 
    hemisphere          : varchar(30)  # Side of brain
    location            : varchar(30) # brain area 
    reference_atlas     : varchar(60) # reference atlas used for associated brain region
%}

classdef Probes < dj.Manual
end