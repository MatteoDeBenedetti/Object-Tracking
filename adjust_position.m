function [ posPan, posTilt ] = adjust_position( coord, xCoord, yCoord, posPan, posTilt )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% Definisco kPan e kTilt. Sono i kp del regolatore che agisce sui servo
kPan = 0.2;
kTilt = 0.2;

% Calcolo errore
xErrLin = coord(1) - xCoord; 
yErrLin = coord(2) - yCoord; 

% calcolo nuove posizini:
posPan = posPan + kPan*xErrLin;
posTilt = posTilt + kTilt*yErrLin;

%mando posPan e posTilt ai servo
%rileggo centro, calcolo xErrLin e yErrLin
%rimando le nuove posPan e posTilt ai servo
%e continuo così

end
