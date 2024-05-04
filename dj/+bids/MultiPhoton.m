%{
    # mullti_photon table
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
    scanning_frequency  : int
    pixel_size          : float
    pixel_size_units    : varchar(30)
    pixel_dimensions    : varchar(30)
    objective           : varchar(30)
    numerical_aperture  : float
    magnification       : int
%}

classdef MultiPhoton < dj.Manual
end

