%{
    # Ophys table
    recording_setup               : varchar(30)
    ---
    manufacturer                    : varchar(60)
    manufacturers_model_name        : varchar(60)
    manufacturer_model_version      : varchar(60)
    device_serial_number            : varchar(45)
    firmware                        : varchar(45)
    software_name                   : varchar(45)
    software_versions               : varchar(45)
    scanning_frequency              : varchar(45)
    laser_model_name                : varchar(60)
    laser_excitation_wave_length    : varchar(45)
    laser_pulse_frequency           : varchar(45)
    indicator                       : varchan(45)
    emission_wave_length            : varchar(45)
    image_processing_toolbox        : varchar(45)
    image_processing_toolbox_version : varchar(10)
%}

classdef Ophys < dj.Manual
end

