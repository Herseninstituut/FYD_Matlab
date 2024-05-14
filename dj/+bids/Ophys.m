%{
    # Ophys table
    recording_setup               : varchar(30)
    ---
    institution_name    : varchar(60)
    institution_adress  : varchar(100)
    institution_department_name     : varchar(60)
    manufacturer        : varchar(60)
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
    pixel_size                      : float
    pixel_size_units                : varchar(30)
    pixel_dimensions                : varchar(30)
    objective                       : varchar(30)
    numerical_aperture              : float
    magnification                   : int
    image_acquisition_protocol      : varchar(45)
    channels                        : int
    emission_wave_length            : varchar(45)
    sampling_frequency              : varchar(45)
    number_of_frames                : int
    task_name                       : varchar(45)
    task_description                : varchar(124)
%}

classdef Ophys < dj.Manual
end

