%{
    # ephys table
    recording_setup               : varchar(30)
    ---
    institution_name    : varchar(60)
    institution_adress  : varchar(100)
    institution_department_name     : varchar(60)
    manufacturer        : varchar(60)
    manufacturers_model_name        : varchar(60)
    manufacturer_model_version      : varchar(60)
    device_serial_number            : varchar(30)
    software_name       : varchar(60)
    software_versions   : varchar(60)
    software_filters    : varchar(60)
    hardware_filters    : varchar(60)
    sampling_frequency  : int
    sampling_frequency_unit         : varchar(8)
    power_line_frequency : int
%}

classdef Ephys < dj.Manual
end

