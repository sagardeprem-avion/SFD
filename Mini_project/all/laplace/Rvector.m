function R=Rvector(theta, phi, H)
global f Re wE
% This function calculates the geocentric equatorial position and
% velocity vectors of an object from radar observations of range,
% azimuth, elevation angle and their rates.
% deg - conversion factor between degrees and radians
% pi - 3.1415926...
% Re - equatorial radius of the earth (km)
% f - earth's flattening factor
% wE - angular velocity of the earth (rad/s)
% omega - earth's angular velocity vector (rad/s) in the
% geocentric equatorial frame
% theta - local sidereal time (degrees) of tracking site
% phi - geodetic latitude (degrees) of site
% H - elevation of site (km)
% R - geocentric equatorial position vector (km) of tracking site
% Rdot - inertial velocity (km/s) of site
% rho - slant range of object (km)
% rhodot - range rate (km/s)
% A - azimuth (degrees) of object relative to observation site
% Adot - time rate of change of azimuth (degrees/s)
% a - elevation angle (degrees) of object relative to observation site
% adot - time rate of change of elevation angle (degrees/s)
% dec - topocentric equatorial declination of object (rad)
% decdot - declination rate (rad/s)
% h - hour angle of object (rad)
% RA - topocentric equatorial right ascension of object (rad)
% RAdot - right ascension rate (rad/s)
% Rho - unit vector from site to object
% Rhodot - time rate of change of Rho (1/s)
% r - geocentric equatorial position vector of object (km)
% v - geocentric equatorial velocity vector of object (km)
% User M-functions required: none
deg = pi/180;
theta = theta*deg;
phi = phi *deg;
R = [(Re/sqrt(1-(2*f - f*f)*sin(phi)^2) + H)*cos(phi)*cos(theta),...
    (Re/sqrt(1-(2*f - f*f)*sin(phi)^2) + H)*cos(phi)*sin(theta),...
    (Re*(1 - f)^2/sqrt(1-(2*f - f*f)*sin(phi)^2) + H)*sin(phi) ];
omega = [0 0 wE];
Rdot = cross(omega, R);


end