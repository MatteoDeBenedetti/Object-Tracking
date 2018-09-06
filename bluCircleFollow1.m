%% IMPOSTAZIONI ACQUISIZIONE
camera_name = 'winvideo';
cameraId = 1;
% formato= 'RGB24_432x240';

% camera_info = imaqhwinfo(camera_name);
% resolution = camera_info.DeviceInfo.SupportedFormats(end);
resolution = 'RGB24_640x360'; %RGB24_432x240 RGB24_640x360 RGB24_800x600 RGB24_960x720 RGB24_1024x576 RGB24_1280x960
% Calcolo coordinate centro
coord = strsplit(resolution, '_');
coord = strsplit(coord{2}, 'x');
coord = [str2double(coord{1})/2 str2double(coord{2})/2];

vid = videoinput(camera_name, cameraId, resolution);

set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
vid.FrameGrabInterval = 5;

% posizioni iniziali
posPan = 0.5;
posTilt = 0.5;
% per microservo 9g
a = arduino('COM6', 'Uno');
sPan = servo(a, 'D5', 'MinPulseDuration', 6.50*10^-4, 'MaxPulseDuration', 24.0*10^-4);
writePosition(sPan, posPan);
sTilt = servo(a, 'D6', 'MinPulseDuration', 6.50*10^-4, 'MaxPulseDuration', 24.0*10^-4);
writePosition(sTilt, posTilt);

%% INIZIO ACQUISIZIONE
start(vid)

%% ELABORAZIONE

% Dura 200 frames
while(vid.FramesAcquired<=200)
    
    % Cattura lo screenshot
    data = getsnapshot(vid);
    %subplot(2,2,1), imshow(data), title('Original image')
    
    % Estrazione componente colorata
	bluImg = imsubtract(data(:,:,2), rgb2gray(data));
    %subplot(2,2,2), imshow(diff_im), title('red component')
    
    % Filtro mediano
    bluImg = medfilt2(bluImg);
    % Uso il close per togliere le righe del foglio
    SE = strel('square',10);
    bluImg = imclose(bluImg, SE);
    % Stretching
    bluImg=imadjust(bluImg);
    %subplot(2,2,3), imshow(bluImg), title('Filtered red component')
    
    % Sogliatura
    bluImg = imbinarize(bluImg, 0.8);
    
    % Rimuovo le parti troppo piccole
    bluImg = bwareaopen(bluImg,300);
    %subplot(2,2,4), imshow(bluImg), title('After threshold')
    %figure(1), subplot(1,2,2), imshow(bluImg), title('After threshold')
    
    % Estraggo i contorni
    %bluImg = edge(bluImg);
    %bluImg = imsubtract(bluImg, imerode(bluImg, ones(3)));
    
    % Cerco il miglior cerchio
    rMin1=10;
    rMax1=20;
    centers1=[];
    radii1=[];
    metric1=[];
    [centers1,radii1, metric1] = imfindcircles(bluImg, [rMin1 rMax1]); %, 'EdgeThreshold',0.7);
    
    rMin2=20;
    rMax2=60;
    centers2=[];
    radii2=[];
    metric2=[];
    [centers2,radii2, metric2] = imfindcircles(bluImg, [rMin2 rMax2]);
    
    if((numel(centers1)>0 && numel(radii1)>0) || (numel(centers2)>0 && numel(radii2)>0))
        centers=[centers1 metric1; centers2 metric2];
        radii=[radii1 metric1; radii2 metric2];
        
        centers=centers(centers(:,3) == max(centers(:,3)),1:2);
        radii=radii(radii(:,2) == max(radii(:,2)),1);
    else
        centers=[];
        radii=[];
    end
    
    % Mostro l'immagine con il tracking
    %figure(1), subplot(1,2,1), imshow(data), title(strcat('Circle detection r=', num2str(rMin1),'--', num2str(rMax2)))
    figure(1), imshow(data), title(strcat('Circle detection r=', num2str(rMin1),'--', num2str(rMax2)))
    
    % Inserisco contorni e raggio
    if(numel(centers)>0 && numel(radii)>0)
        hold on
        
        %creo il contorno
        viscircles(centers(1,:),radii(1), 'color', 'yellow', 'lineStyle', '-', 'lineWidth', 0.3);
        %scrivo le coord del raggio
        plot(centers(1,1),centers(1,2), '-m+', 'color', 'y')
        a=text(centers(1,1)+10,centers(1,2), strcat('X: ', num2str(round(centers(1,1))), '    Y: ', num2str(round(centers(1,2))), '    R: ', num2str(round(radii(1)))));
        set(a, 'FontName', 'Cambria', 'FontWeight', 'bold', 'FontSize', 11, 'Color', 'yellow');
        
        hold off
        
        xCoord=centers(1,1);
        yCoord=centers(1,2);
        
        % sends correction to servos
        % [posPan, posTilt] = adjust_position(coord, xCoord, yCoord, posPan, posTilt);
        run('adjust_position_script.m');
    end
    
end

%% Termino l'acquisizione
stop(vid);
flushdata(vid);

%gradually get back to pan = tilt = 0.5:
% position_start();

clear sTilt;
clear sPan;
clear a;

% clear all
% close all
% clc
