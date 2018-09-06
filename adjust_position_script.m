% Definisco kPan e kTilt. Sono i kp del regolatore che agisce sui servo
kPan = 0.00052*.5;
kTilt = -0.00081*.5;

% Calcolo errore
xErrLin = coord(1) - xCoord; 
yErrLin = coord(2) - yCoord; 

% calcolo nuove posizini:
posPan = posPan + kPan*xErrLin;
posTilt = posTilt + kTilt*yErrLin;

% limito posPan e posTilt:
if posPan > 0.99
    posPan = 0.99;
elseif posPan < 0.01
    posPan = 0.01;
end
if posTilt > 0.99
    posTilt = 0.99;
elseif posTilt < 0.01
    posTilt = 0.01;
end

posPan;
posTilt;

%mando posPan e posTilt ai servo
writePosition(sPan, posPan);
writePosition(sTilt, posTilt);

pause(0.01);