% user adjustable constants
CELL_DIAMETER = 0.6; % um
DOT_DENSITY  = 1000; % per um
ARC_LENGTH_RATIO = 1.4; % unitless
CELL_LENGTH = 0.5; % um

TOTAL_GROWTH = 1; % fraction of original length
RELATIVE_PROPORTIONAL_GROWTH = 1.2;
OFFSET_Y = 3;
isDisplayRedGreenCircles = false;
fprintf('--------- \n');
% % Calculate centerline dot spacing
centerlineS = linspace(0,CELL_LENGTH,CELL_LENGTH*DOT_DENSITY);
% calculate centerline radius of curvature
centerlineRadiusCurvature = (CELL_DIAMETER/2+ARC_LENGTH_RATIO*CELL_DIAMETER/2)./(ARC_LENGTH_RATIO-1);
fprintf('Centerline curvature (original): %s\n',1/centerlineRadiusCurvature);
centerlineCurvatureOriginal = 1/centerlineRadiusCurvature;
% convert to angular space
centerLineTheta = centerlineS./(centerlineRadiusCurvature);
centerLineTheta = centerLineTheta-mean(centerLineTheta)+pi/2;
% calculate the centerline
centerLineX = centerlineRadiusCurvature*cos(centerLineTheta);
centerLineY = centerlineRadiusCurvature*sin(centerLineTheta);

% poles have half a circumference on each side
poleHalfCircum = (pi*CELL_DIAMETER/2);
fprintf('Length (original): %s\n',CELL_LENGTH+CELL_DIAMETER);

% orient the poles so that they come off the cell correctly
EndcapATheta = linspace(0,pi,poleHalfCircum*(DOT_DENSITY));
EndcapATheta = EndcapATheta + atan2(centerLineY(2)-centerLineY(1),centerLineX(2)-centerLineX(1))+pi/2;
EndcapBTheta = linspace(0,pi,poleHalfCircum*(DOT_DENSITY));
EndcapBTheta = EndcapBTheta + atan2(centerLineY(end)-centerLineY(end-1),centerLineX(end)-centerLineX(end-1))-pi/2;

% find the coordinates of the poles
EncapA_X = CELL_DIAMETER/2*cos(EndcapATheta)+centerLineX(1);
EncapA_Y = CELL_DIAMETER/2*sin(EndcapATheta)+centerLineY(1);

EncapB_X = CELL_DIAMETER/2*cos(EndcapBTheta)+centerLineX(end);
EncapB_Y = CELL_DIAMETER/2*sin(EndcapBTheta)+centerLineY(end);

% side walls are displaced from the cell body by half a cell diameter
centerlineS = linspace(0,CELL_LENGTH,CELL_LENGTH*DOT_DENSITY);
% calculate centerline radius of curvature
centerlineRadiusCurvature = (CELL_DIAMETER/2+ARC_LENGTH_RATIO*CELL_DIAMETER/2)./(ARC_LENGTH_RATIO-1);
% convert to angular space
centerLineTheta = centerlineS./(centerlineRadiusCurvature);
centerLineTheta = centerLineTheta-mean(centerLineTheta)+pi/2;

% determine length of side walls calculate centerline curvature
side1LengthIntial = (centerlineRadiusCurvature+CELL_DIAMETER/2)*(centerLineTheta(end)-centerLineTheta(1));
side2LengthIntial = (centerlineRadiusCurvature-CELL_DIAMETER/2)*(centerLineTheta(end)-centerLineTheta(1));

% put the same density of points along these arcs
side1_theta = linspace(centerLineTheta(1),centerLineTheta(end),DOT_DENSITY*side1LengthIntial);
side2_theta = linspace(centerLineTheta(1),centerLineTheta(end),DOT_DENSITY*side2LengthIntial);
Side1_X = (centerlineRadiusCurvature+CELL_DIAMETER/2)*cos(side1_theta);
Side1_Y = (centerlineRadiusCurvature+CELL_DIAMETER/2)*sin(side1_theta);
Side2_X = (centerlineRadiusCurvature-CELL_DIAMETER/2)*cos(side2_theta);
Side2_Y = (centerlineRadiusCurvature-CELL_DIAMETER/2)*sin(side2_theta);
offsetInitial_X = min([Side1_X(:);Side2_X(:)]);
offsetInitial_X = 0;
offsetInitial_Y = min([Side1_Y(:);Side2_Y(:)]);

num_initialSide1 = length(Side1_X);
num_initialSide2 = length(Side2_X);

% display the first cell as all green
figure(gcf);
clf;
hold on;
if isDisplayRedGreenCircles
plot(centerLineX-offsetInitial_X,centerLineY-offsetInitial_Y+OFFSET_Y,'kx:');
else
plot(centerLineX-offsetInitial_X,centerLineY-offsetInitial_Y+OFFSET_Y,'b:');
end
plot(EncapA_X-offsetInitial_X,EncapA_Y-offsetInitial_Y+OFFSET_Y,'k');
plot(EncapB_X-offsetInitial_X,EncapB_Y-offsetInitial_Y+OFFSET_Y,'k');
plot(Side1_X-offsetInitial_X,Side1_Y-offsetInitial_Y+OFFSET_Y,'k');
plot(Side2_X-offsetInitial_X,Side2_Y-offsetInitial_Y+OFFSET_Y,'k');
if isDisplayRedGreenCircles
    scatter(EncapA_X-offsetInitial_X,EncapA_Y-offsetInitial_Y+OFFSET_Y,'og');
    scatter(EncapB_X-offsetInitial_X,EncapB_Y-offsetInitial_Y+OFFSET_Y,'og');
    scatter(Side1_X-offsetInitial_X,Side1_Y-offsetInitial_Y+OFFSET_Y,'og');
    scatter(Side2_X-offsetInitial_X,Side2_Y-offsetInitial_Y+OFFSET_Y,'og');
end
axis equal
% calculate the new cell as a bit longer

%
side1LengthFinal = (1+RELATIVE_PROPORTIONAL_GROWTH*TOTAL_GROWTH)*side1LengthIntial;
side2LengthFinal = (1+TOTAL_GROWTH)*side2LengthIntial;

arcLengthRatioAfterGrowth = side1LengthFinal/side2LengthFinal;

cellLengthAfterGrowth = (1+TOTAL_GROWTH)*CELL_LENGTH;


%
% Calculate centerline dot spacing
centerlineS = linspace(0,cellLengthAfterGrowth,cellLengthAfterGrowth*DOT_DENSITY);

% calculate centerline radius of curvature
centerlineRadiusCurvature = (CELL_DIAMETER/2+arcLengthRatioAfterGrowth*CELL_DIAMETER/2)./(arcLengthRatioAfterGrowth-1);

fprintf('Centerline curvature (new): %s\n',1/centerlineRadiusCurvature);
centerlineCurvatureNew = 1/centerlineRadiusCurvature;

% convert to angular space
centerLineTheta = centerlineS./(centerlineRadiusCurvature);
centerLineTheta = centerLineTheta-mean(centerLineTheta)+pi/2;
% calculate the centerline
centerLineX = centerlineRadiusCurvature*cos(centerLineTheta);
centerLineY = centerlineRadiusCurvature*sin(centerLineTheta);

% display new length
fprintf('Length (new): %s\n',cellLengthAfterGrowth+CELL_DIAMETER);


% poles have half a circumference on each side
poleHalfCircum = (pi*CELL_DIAMETER/2);

% orient the poles so that they come off the cell correctly
EndcapATheta = linspace(0,pi,poleHalfCircum*(DOT_DENSITY));
EndcapATheta = EndcapATheta + atan2(centerLineY(2)-centerLineY(1),centerLineX(2)-centerLineX(1))+pi/2;
EndcapBTheta = linspace(0,pi,poleHalfCircum*(DOT_DENSITY));
EndcapBTheta = EndcapBTheta + atan2(centerLineY(end)-centerLineY(end-1),centerLineX(end)-centerLineX(end-1))-pi/2;

% find the coordinates of the poles
EncapA_X = CELL_DIAMETER/2*cos(EndcapATheta)+centerLineX(1);
EncapA_Y = CELL_DIAMETER/2*sin(EndcapATheta)+centerLineY(1);

EncapB_X = CELL_DIAMETER/2*cos(EndcapBTheta)+centerLineX(end);
EncapB_Y = CELL_DIAMETER/2*sin(EndcapBTheta)+centerLineY(end);

% side walls are displaced from the cell body by half a cell diameter

% put the same density of points along these arcs
side1_theta = linspace(centerLineTheta(1),centerLineTheta(end),DOT_DENSITY*side1LengthFinal);
side2_theta = linspace(centerLineTheta(1),centerLineTheta(end),DOT_DENSITY*side2LengthFinal);
Side1_X = (centerlineRadiusCurvature+CELL_DIAMETER/2)*cos(side1_theta);
Side1_Y = (centerlineRadiusCurvature+CELL_DIAMETER/2)*sin(side1_theta);
Side2_X = (centerlineRadiusCurvature-CELL_DIAMETER/2)*cos(side2_theta);
Side2_Y = (centerlineRadiusCurvature-CELL_DIAMETER/2)*sin(side2_theta);
% Display the second cell as a mix of red and green

% randomly pick the same number of dots that we started with
plotAsGreen1 = randperm(length(Side1_X),num_initialSide1);
plotAsGreen2 = randperm(length(Side2_X),num_initialSide2);
% plot the remainder as red
plotAsRed1 = true(length(Side1_X),1);
plotAsRed1(plotAsGreen1) = false;
plotAsRed2 = true(length(Side2_X),1);
plotAsRed2(plotAsGreen2) = false;

offsetFinal_X = min([Side1_X(:);Side2_X(:)]);
offsetFinal_Y = min([Side1_Y(:);Side2_Y(:)]);
offsetFinal_X = 0;

if isDisplayRedGreenCircles
plot(centerLineX-offsetFinal_X,centerLineY-offsetFinal_Y,'kx:');
else
    plot(centerLineX-offsetFinal_X,centerLineY-offsetFinal_Y,'b:');

end

plot(EncapA_X-offsetFinal_X,EncapA_Y-offsetFinal_Y,'k');
plot(EncapB_X-offsetFinal_X,EncapB_Y-offsetFinal_Y,'k');
plot(Side1_X-offsetFinal_X,Side1_Y-offsetFinal_Y,'k');
plot(Side2_X-offsetFinal_X,Side2_Y-offsetFinal_Y,'k');

if isDisplayRedGreenCircles
    scatter(EncapA_X()-offsetFinal_X,EncapA_Y()-offsetFinal_Y,'og');
    scatter(EncapB_X()-offsetFinal_X,EncapB_Y()-offsetFinal_Y,'og');
    scatter(Side1_X(plotAsRed1)-offsetFinal_X,Side1_Y(plotAsRed1)-offsetFinal_Y,'or');
    scatter(Side2_X(plotAsRed2)-offsetFinal_X,Side2_Y(plotAsRed2)-offsetFinal_Y,'or');
    scatter(Side1_X(plotAsGreen1)-offsetFinal_X,Side1_Y(plotAsGreen1)-offsetFinal_Y,'og');
    scatter(Side2_X(plotAsGreen2)-offsetFinal_X,Side2_Y(plotAsGreen2)-offsetFinal_Y,'og');
end

%disp((nnz(plotAsRed1)/nnz(not(plotAsRed1)))/(nnz(plotAsRed2)/nnz(not(plotAsRed2))));
disp(['redOut/redIn: ',num2str(length(plotAsRed1)/length(plotAsRed2))]);


disp(['Green outer face: ',num2str(nnz(not(plotAsRed1)))]);
disp(['Red outer face: ',num2str(nnz((plotAsRed1)))]);

disp(['Green inner face: ',num2str(nnz(not(plotAsRed2)))]);
disp(['Red inner face: ',num2str(nnz((plotAsRed2)))]);
relGrowth = (nnz((plotAsRed1))/nnz(not(plotAsRed1))) ./...
    (nnz((plotAsRed2))/nnz(not(plotAsRed2)));
disp(['relative growth: ' num2str(relGrowth)]);


axis equal

xLimitsStart = xlim();
text((xLimitsStart(1) - 0.05*diff(xLimitsStart)), mean(Side1_Y)-offsetFinal_Y,['curvNew: ',num2str(centerlineCurvatureNew)]);
text((xLimitsStart(1) - 0.05*diff(xLimitsStart)), mean(Side2_Y)+offsetInitial_Y,['lengthOrig: ', num2str(CELL_LENGTH+CELL_DIAMETER)]);
text((xLimitsStart(1) - 0.05*diff(xLimitsStart)), mean(Side1_Y)+offsetInitial_Y,['curvOrig: ', num2str(centerlineCurvatureOriginal)]);
text((xLimitsStart(1) - 0.05*diff(xLimitsStart)), max(Side1_Y),['relGrowth: ',num2str(relGrowth)]);

xlim([xLimitsStart(1)-0.1*diff(xLimitsStart),xLimitsStart(2)]);
%%
saveas(gcf,[transcodeDate(now),'.svg']);