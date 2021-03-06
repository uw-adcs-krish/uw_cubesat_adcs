function fsw_params = init_time_coord_rot( fsw_params )
% ----------------------------------------------------------------------- %
% UW HuskySat-1, ADCS Team
%
% Initializes all conversions as they relate to time and coordinate frames
%
% T. Reynolds -- 4.18.18
% ----------------------------------------------------------------------- %

% Pull constants
KM2M    = fsw_params.constants.convert.KM2M;
M2KM    = fsw_params.constants.convert.M2KM;
dut1    = fsw_params.constants.time.dut1;
cent2JD = fsw_params.constants.time.cent2JD;
day2sec = fsw_params.constants.time.day2sec;

% Initialize position/velocity in TEME frame
fsw_params.constants.ic.time.gps = fsw_params.env_estimation.ic.gps_time;

[fsw_params.constants.ic.pos_teme_km,...
          fsw_params.constants.ic.vel_teme_kmps] = ...
          TLE2TEME(fsw_params.env_estimation.orb_estimation.sgp4.orbit_tle);
                        
fsw_params.constants.ic.pos_teme_m   = ...
                                KM2M*fsw_params.constants.ic.pos_teme_km;
fsw_params.constants.ic.vel_teme_mps = ...
                                KM2M*fsw_params.constants.ic.vel_teme_kmps;

% Get time values
[time_ut1,~,~,~,T_ut1_J2000,T_TT_J2000] = ...
                    time_conversion(fsw_params.constants.ic.time.gps,dut1);

% Save for epoch initialization
fsw_params.constants.ic.time.time_ut1       = time_ut1;
fsw_params.constants.ic.time.T_ut1_J2000    = T_ut1_J2000;
fsw_params.constants.ic.time.JD_J2000_TT    = T_TT_J2000 * cent2JD; 
fsw_params.constants.ic.time.JD_J2000_TT_s  = ...
                        fsw_params.constants.ic.time.JD_J2000_TT * day2sec;

% Get rotation matrices
[ecef_2_eci, ppef_2_veci, ~, teme_2_eci]  = ...
                            coordinate_rotations(T_ut1_J2000, T_TT_J2000);
eci_2_ecef          = ecef_2_eci'; 

% Save for epoch initialization
fsw_params.constants.ic.rot.ecef_2_eci  = ecef_2_eci;
fsw_params.constants.ic.rot.teme_2_eci  = teme_2_eci;

% Transform the TEME pos/vel to the ECI & ECEF frames
fsw_params.constants.ic.pos_eci_m    = ...
                        teme_2_eci * fsw_params.constants.ic.pos_teme_m;
fsw_params.constants.ic.vel_eci_mps  = ...
                        teme_2_eci * fsw_params.constants.ic.vel_teme_mps;
fsw_params.constants.ic.pos_eci_km  = ...
                        fsw_params.constants.ic.pos_eci_m * M2KM;
fsw_params.constants.ic.vel_eci_kmps = ...
                        fsw_params.constants.ic.vel_eci_mps * M2KM;
                    
                    
fsw_params.constants.ic.pos_ecef_m   = ...
                        eci_2_ecef * fsw_params.constants.ic.pos_eci_m;
fsw_params.constants.ic.vel_ecef_mps = ...
                    eci_2_ecef * ( fsw_params.constants.ic.vel_eci_mps ...
                    - ppef_2_veci * fsw_params.constants.ic.pos_ecef_m );

% Initial condition for sensor processing should be ECEF                                  
fsw_params.constants.ic.gps_all = [ fsw_params.constants.ic.pos_ecef_m; ...
                                   fsw_params.constants.ic.vel_ecef_mps; ...
                                   fsw_params.constants.ic.time.gps; 0 ];


end

