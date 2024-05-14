%{
  # contacts table for BIDS contacts tsv
  ---
  contact_id    : varchar(60)  # REQUIRED - ID of the contact (expected to match channel.tsv)
  probe_id      : varchar(60)  # REQUIRED - Id of the probe the contact is on
  subject       : varchar(50)  #  - Subject identifier
  x             : float  #  recorded position along the local width-axis relative to the probe origin and rotation (see probes.tsv)
  y             : float  #
  z             : float  #
  physical_unit : varchar(30)  # units used for x y and z coordinates as well as contact size internal_pipette_diameter and external_pipette_diameter
  impedance     : float  # mpedance of the contact or pipette (pipette_resistance)
  impedance_unit: varchar(30)   #  The unit of the impedance (kOhm).
  shank_id      : varchar(60)   #  Id to specify which shank of the probe
  contact_size  : float   # size of the contact e.g. non-insulated surface are
  contact_shape : varchar(60)   # description of the shape of the conta
  material      : varchar(60)   # material of the contact surface for solid electrodes
  location      : varchar(60)    # An indication on the location of the contact (e.g. cortical layer 3)
  insulation    : varchar(60)    # Material used for insulation around the contact
  pipette_solution          : varchar(60)   #  Solution used to fill the pipette see also openMINDS pipette.
  internal_pipette_diameter : varchar(30)   # internal diameter of the pipette
  external_pipette_diameter : varchar(30)  #  external diameter of the pipette
%}
classdef Contacts < dj.Manual
end