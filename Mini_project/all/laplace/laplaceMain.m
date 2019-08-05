%This script file calls other functions and does Orbit determination using
%laplace method. 
%Referred paper:
%http://articles.adsabs.harvard.edu/cgi-bin/nph-iarticle_query?1991SvA....35..428K&defaultprint=YES&page_ind=0&filetype=.pdf
clear
close all

% Re - equatorial radius of the earth (km)
% f - earth's flattening factor
% wE - angular velocity of the earth (rad/s)
global f Re wE
Re =  6378.137;
f = 0.003353;
wE = 7.2921159* 10^-5 ;
muEarth=398600;

%% DataDetails
H=839.91;%m Bangalore elevation above sea
TrackingStationNo=1;
longi=360-282.48831;
lati=13.0344722; %geodetic(normal)
sampChos=300;% Final sample at which od is done on Filtered data!!
dataFile='ang_ri1_BL1_24076.xls';

%%
[jd,azh,elevation,y,m,d,UT]=loadData(dataFile);
lst=zeros(1,length(jd)); %local sidereal time
for i=1:length(jd)
    lst(i)=LST(y(i), m(i), d(i), UT(i), longi);
    [RA(i),dec(i)]=topoToEci(azh(i),elevation(i),lst(i),lati,H/1000);
end
%plot(RA); hold on;
%plot(dec)
%plot(jd,'.');hold on;

% Cutting the curve to make the samples better
% Only JD, elevation and azhimuth are important from now on
jd=jd';
RA=RA';
dec=dec';
fittedRA = polyfit([1:length(RA)]',RA,30) ;%Function of sampke no; not the jd values
RA=polyval(fittedRA,1:length(RA));
%plot(RA)

fitteddec= polyfit([1:length(dec)]',dec,30); %Function of sampke no; not the jd values
dec=polyval(fitteddec,1:length(dec));
%plot(dec)

fittedjd= polyfit([1:length(jd)]',jd,1); %Function of sampke no; not the jd values
jd=polyval(fittedjd,1:length(jd));
%plot(jd);
jddot=polyder(fittedjd);
%plot(polyval(jddot,1:length(jd)));%Seems to be constant perfectly(because of fitting curve :P)
jd_samples=mean(polyval(jddot,1:length(jd))); %JD per sample count


%All the future calculations are on new fit values of jd, elevation and
%azhimut

%% Differentiation polynomial
% Dequation=[cos(fittedRA*pi/180).*cos(fitteddec*pi/180);
%     sin(fittedRA*pi/180).*cos(fitteddec*pi/180);
%     sin(fitteddec*pi/180)];% Input is sample number
% DdotEquation=[polyder(Dequation(1,:));
%                 polyder(Dequation(2,:));
%                 polyder(Dequation(3,:))]/jd_samples*1/(24*60*60);
% DdotdotEquation=[polyder(DdotEquation(1,:));
%                 polyder(DdotEquation(2,:));
%                 polyder(DdotEquation(3,:))]/jd_samples*1/(24*60*60);           
%                 

%%
%D vector calculations/substitutions
D=[cos(RA*pi/180).*cos(dec*pi/180);
    sin(RA*pi/180).*cos(dec*pi/180);
    sin(dec*pi/180)];

% Ddot = [ polyval(DdotEquation(1,:),1:length(jd));
%           polyval(DdotEquation(2,:),1:length(jd));
%           polyval(DdotEquation(3,:),1:length(jd))];
% Ddotdot = [ polyval(DdotdotEquation(1,:),1:length(jd));
%           polyval(DdotdotEquation(2,:),1:length(jd));
%           polyval(DdotdotEquation(3,:),1:length(jd))];      
%SIMPLE derivative
for i=1:3
    Ddot(i,:)=diff(D(i,:))/jd_samples*1/(24*60*60);%KM/s units
end
for i=1:3
    Ddotdot(i,:)=diff(Ddot(i,:))/jd_samples*1/(24*60*60);%KM/s units
end


%% R calculation

for i=1:length(jd)
    R(:,i)=Rvector(lst(i),lati,H/1000);
end
for i=1:3
    Rdot(i,:)=diff(R(i,:))/jd_samples*1/(24*60*60);%KM/s units
end
for i=1:3
    Rdotdot(i,:)=diff(Rdot(i,:))/jd_samples*1/(24*60*60);%KM/s units
    
end

%% Finding P and Q
%r=R+rho D
% rho=P-Q/r^3
Rs=R(:,sampChos);% R sample of choice
Ds=D(:,sampChos);% R sample of choice
Rsdot=Rdot(:,sampChos);
Rsdotdot=Rdotdot(:,sampChos);
Dsdot=Ddot(:,sampChos);
Dsdotdot= Ddotdot(:,sampChos);


P=-dot(Rsdotdot,cross(Dsdot,Ds)  )/(dot(Dsdotdot,cross(Dsdot,Ds)))
Q=muEarth*( dot(Rs,cross(Dsdot,Ds))   )/(dot(Dsdotdot,cross(Dsdot,Ds)))
Pdash=-dot(  R(:,sampChos), cross(Rdotdot(:,sampChos),D(:,sampChos)  )  )...
    /2/dot( R(:,sampChos), cross(Ddot(:,sampChos),D(:,sampChos) )   )
Qdash=dot(  R(:,sampChos), cross(Ddotdot(:,sampChos),D(:,sampChos)  )  )...
    /2/dot( R(:,sampChos), cross(Ddot(:,sampChos),D(:,sampChos) )   )

%% Have to solve and find rho numerically now using r interms of rho equation
syms rho
syms f
f=  Q^2-(P-rho) ^2*( (norm(Rs))^2 + rho^2 *norm(Ds)^2 + 2*rho*dot(Ds,Rs)    )^3 
%assume(rho, 'real')
rho=vpasolve(f==0,rho,[0,50000])

%% Finding Pos and Velocity in ECI
subs rho
pos = Rs+rho*Ds
vel = Rsdot+(Pdash-Qdash*rho)*Ds+rho*Dsdot

%% Keplerian elements finding
coe_from_sv(pos,vel,muEarth)'









