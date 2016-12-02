
%%
% +x integrated intensity (both color channels) along face 1, face 2, pole 1, pole 2
% +x length of face 1, face 2, pole 1, pole 2
% +x ratio of intensities along face 1, face 2, pole 1, pole 2
% +x total intensity of each color for entire cell
% + fraction of intensity in both colors on both faces
% + ratio of fraction of intensity on both colors
% +x a central/medial patch of 1 pix, 3 pix, 5 pix, 
% + insertion bias (G-R)/(G+R) and relative insertion bias from one face to
%       another face
% + full width at half max, relative position to pole position
% + which fraction of pole goes on inner face/outer face

fileList = uipickfiles('FilterSpec','*pill_MESH*');
%%
progressbar(0);

for iFile = 1:length(fileList)
        progressbar(iFile/length(fileList));

load(fileList{iFile})
    
isDisplay4 = false;

nCells = length(frame.object);
for iCell = 1:nCells
    % pull out the individual channels
    tempRed = frame.object(iCell).rawIntCont_red-frame.object(iCell).cellBack_red;
    tempGreen = frame.object(iCell).rawIntCont_green-frame.object(iCell).cellBack_green;
    
    totalRed = sum(tempRed);
    totalGreen = sum(tempGreen);
    
    tempGreen(end) = [];
    tempRed(end) = [];
    tempRed2 = tempRed./sum(tempRed);
    tempGreen2 = tempGreen./sum(tempGreen);
    % calculate the local asymetry and intensity ratio
    asymmetry = (tempRed2-tempGreen2)'./(tempRed2+tempGreen2)';
    ratio = tempRed2./tempGreen2;
    % store the data in the original object
    frame.object(iCell).ROverGRatio = ratio;
    frame.object(iCell).RMinusGAsym = asymmetry;
    frame.object(iCell).RedFraction = tempRed2;
    frame.object(iCell).GreenFraction = tempGreen2;
    frame.object(iCell).backSubtractedGreen = totalGreen;
    frame.object(iCell).backSubtractedRed = totalRed;

    
    % display some plots
    if isDisplay4
        subplot(1,2,1);
        scatter(frame.object(iCell).Xcont,frame.object(iCell).Ycont,45,frame.object(iCell).kappa_smooth);
%         set(gca,'clim',[-0.2,0.2]);
        axis equal
        colormap parula
        colorbar
        subplot(1,2,2);
        scatter(frame.object(iCell).Xcont,frame.object(iCell).Ycont,30,ratio,'.');
        set(gca,'clim',[0,5]);
        axis equal
        colormap jet
        figure(gcf);
    end
    
    % identify the pole of the cells
    Xcont = frame.object(iCell).Xcont;
    Ycont = frame.object(iCell).Ycont;
    centerline = frame.object(iCell).centerline;
    contourDist1 = sqrt((Xcont-centerline(1,1)).^2+(Ycont-centerline(1,2)).^2);
    [dist1, pole1Idx] = min(contourDist1);
    
    contourDist2 = sqrt((Xcont-centerline(end,1)).^2+(Ycont-centerline(end,2)).^2);
    [dist2, pole2Idx] = min(contourDist2);
    
    % find the indices of each path
    pathIdx = 1:length(Xcont);
    path1 = pathIdx(min(pole1Idx,pole2Idx):max(pole1Idx,pole2Idx));
    path2 = 1:min(pole1Idx,pole2Idx);
    path2 = [pathIdx(max(pole1Idx,pole2Idx):end),path2];
    
    % swap the two paths if "in" and "out" were wrong as defined by the
    % curvature at the middle point of each contour
    if mean(frame.object(iCell).kappa_smooth(path1(round(end/2))))<mean(frame.object(iCell).kappa_smooth(path2(round(end/2))))
        path2temp = path2;
        path2 = path1;
        path1 = path2temp;
    end
    % find the cuvature at each pole
    pole1Curv = frame.object(iCell).kappa_smooth(path1(1));
    pole2Curv = frame.object(iCell).kappa_smooth(path1(end));
    pole1circumOver4 = (pi/pole1Curv)/2;
    %% figure out how far of an arc the cell outline makes at the pole to define an "encap"
    diffX1 = diff(Xcont(path1));
    diffY1 = diff(Ycont(path1));
    arcLength1 = sum((diffX1.^2+diffY1.^2));
    
    diffX2 = diff(Xcont(path2));
    diffY2 = diff(Ycont(path2));
    arcLength2 = sum((diffX2.^2+diffY2.^2));
    
    % Store arc lengths
    frame.object(iCell).arcLength1 = arcLength1;
    frame.object(iCell).arcLength2 = arcLength2;
    
    %% define poles as end points +/- 3 pixels
    POLE_RADIUS_PIX = 2;
    
    poleAPix = [path2(end-POLE_RADIUS_PIX:end-1),path1(1:(POLE_RADIUS_PIX+1))];
    poleBPix = [path1(end-POLE_RADIUS_PIX:end-1),path2(1:(POLE_RADIUS_PIX+1))];

    diffXA = diff(Xcont(poleAPix));
    diffYA = diff(Ycont(poleAPix));
    arcLengthA = sum((diffXA.^2+diffYA.^2));
    
    diffXB = diff(Xcont(poleBPix));
    diffYB = diff(Ycont(poleBPix));
    arcLengthB = sum((diffXB.^2+diffYB.^2));
    
    % Store arc lengths
    frame.object(iCell).arcLengthA = arcLengthA;
    frame.object(iCell).arcLengthB = arcLengthB;
    
    
    %% store integrated intensity
    frame.object(iCell).poleAIntegratedGreen = sum(tempGreen2(poleAPix));
    frame.object(iCell).poleBIntegratedGreen = sum(tempGreen2(poleBPix));
    frame.object(iCell).side1WithPoleIntegratedGreen = sum(tempGreen2(path1))-0.5*tempGreen2(path1(1))-0.5*tempGreen2(path1(end));
    frame.object(iCell).side2WithPoleIntegratedGreen = sum(tempGreen2(path2))-0.5*tempGreen2(path2(1))-0.5*tempGreen2(path1(end));
    
    frame.object(iCell).poleAIntegratedRed = sum(tempRed2(poleAPix));
    frame.object(iCell).poleBIntegratedRed = sum(tempRed2(poleBPix));
    frame.object(iCell).side1WithPoleIntegratedRed = sum(tempRed2(path1))-0.5*tempRed2(path1(1))-0.5*tempRed2(path1(end));
    frame.object(iCell).side2WithPoleIntegratedRed = sum(tempRed2(path2))-0.5*tempRed2(path1(1))-0.5*tempRed2(path1(end));
    
    
    
    
    path1nonPole = pathIdx;
    path1nonPole(path1) = -1;
    path1nonPole(poleAPix) = 0;
    path1nonPole(poleBPix) = 0;
    path1nonPole = path1nonPole==-1;

    path2nonPole = pathIdx;
    path2nonPole(path2) = -1;
    path2nonPole(poleAPix) = 0;
    path2nonPole(poleBPix) = 0;
    path2nonPole = path2nonPole==-1;
    
    frame.object(iCell).side1IntegratedGreen = sum(tempGreen2(path1nonPole));
    frame.object(iCell).side2IntegratedGreen = sum(tempGreen2(path2nonPole));
    frame.object(iCell).side1IntegratedRed = sum(tempRed2(path1nonPole));
    frame.object(iCell).side2IntegratedRed = sum(tempRed2(path2nonPole));

    
    frame.object(iCell).side1IntegratedGreen_arbUnits = totalGreen.* frame.object(iCell).side1IntegratedGreen;
    frame.object(iCell).side2IntegratedGreen_arbUnits = totalGreen .* frame.object(iCell).side2IntegratedGreen;
    frame.object(iCell).side1IntegratedRed_arbUnits = totalRed .* frame.object(iCell).side2IntegratedRed;
    frame.object(iCell).side2IntegratedRed_arbUnits = totalRed .* frame.object(iCell).side2IntegratedRed;
    
    frame.object(iCell).poleAIntegratedRed_arbUnits = totalRed .*frame.object(iCell).poleAIntegratedRed ;
    frame.object(iCell).poleBIntegratedRed_arbUnits = totalRed .*frame.object(iCell).poleBIntegratedRed;
    frame.object(iCell).side1WithPoleIntegratedRed_arbUnits = totalRed .*   frame.object(iCell).side1WithPoleIntegratedRed ;
    frame.object(iCell).side2WithPoleIntegratedRed_arbUnits = totalRed .*   frame.object(iCell).side2WithPoleIntegratedRed;
    
    frame.object(iCell).poleAIntegratedGreen_arbUnits = totalGreen .*frame.object(iCell).poleAIntegratedGreen;
    frame.object(iCell).poleBIntegratedGreen_arbUnits = totalGreen .*frame.object(iCell).poleBIntegratedGreen;
    frame.object(iCell).side1WithPoleIntegratedGreen_arbUnits = totalGreen .*   frame.object(iCell).side1WithPoleIntegratedGreen ;
    frame.object(iCell).side2WithPoleIntegratedGreen_arbUnits = totalGreen .*   frame.object(iCell).side2WithPoleIntegratedGreen;
    
    
    frame.object(iCell).side1Medial1Green = sum(tempGreen2(path1(round(end/2))));
    frame.object(iCell).side1Medial3Green = sum(tempGreen2(path1(round(end/2)-1:(round(end/2)+1))));
    frame.object(iCell).side1Medial5Green = sum(tempGreen2(path1(round(end/2)-2:(round(end/2)+2))));

    frame.object(iCell).side1Medial1Red = sum(tempRed2(path1(round(end/2))));
    frame.object(iCell).side1Medial3Red = sum(tempRed2(path1(round(end/2)-1:(round(end/2)+1))));
    frame.object(iCell).side1Medial5Red = sum(tempRed2(path1(round(end/2)-2:(round(end/2)+2))));

    frame.object(iCell).side2Medial1Green = sum(tempGreen2(path2(round(end/2))));
    frame.object(iCell).side2Medial3Green = sum(tempGreen2(path2(round(end/2)-1:(round(end/2)+1))));
    frame.object(iCell).side2Medial5Green = sum(tempGreen2(path2(round(end/2)-2:(round(end/2)+2))));

    frame.object(iCell).side2Medial1Red = sum(tempRed2(path2(round(end/2))));
    frame.object(iCell).side2Medial3Red = sum(tempRed2(path2(round(end/2)-1:(round(end/2)+1))));
    frame.object(iCell).side2Medial5Red = sum(tempRed2(path2(round(end/2)-2:(round(end/2)+2))));

    %% define lengths of "insertion region"
    try
        frame.object(iCell).arcLength2_Fwhm_Red = bpbFWHM(1:length(path2),tempRed2(path2));
    frame.object(iCell).arcLength1_Fwhm_Red = bpbFWHM(1:length(path1),tempRed2(path1));
    frame.object(iCell).arcLength2_Fwhm_RedOverGreen = bpbFWHM(1:length(path2),tempRed2(path2)./tempGreen2(path2));
    frame.object(iCell).arcLength1_Fwhm_RedOverGreen = bpbFWHM(1:length(path1),tempRed2(path1)./tempGreen2(path1));

    catch ME
    frame.object(iCell).arcLength2_Fwhm_Red = nan;
    frame.object(iCell).arcLength1_Fwhm_Red = nan;
    frame.object(iCell).arcLength2_Fwhm_RedOverGreen = nan;
    frame.object(iCell).arcLength1_Fwhm_RedOverGreen = nan;
    warning('morphometrics:calculateContourFluorMetrics:fwhmError',['Error calculating FWMH in object #',num2str(iCell)]);
    end
    
    %% store ratios of intensity
    frame.object(iCell).poleARatio = frame.object(iCell).poleAIntegratedGreen./frame.object(iCell).poleAIntegratedRed;
    frame.object(iCell).poleBRatio = frame.object(iCell).poleBIntegratedGreen./frame.object(iCell).poleBIntegratedRed;
    frame.object(iCell).side1Ratio = frame.object(iCell).side1IntegratedGreen./frame.object(iCell).side1IntegratedRed;
    frame.object(iCell).side2Ratio = frame.object(iCell).side2IntegratedGreen./frame.object(iCell).side2IntegratedRed;
    
    frame.object(iCell).side1medial1Ratio = frame.object(iCell).side1Medial1Green./frame.object(iCell).side1Medial1Red;
    frame.object(iCell).side1medial3Ratio = frame.object(iCell).side1Medial1Green./frame.object(iCell).side1Medial1Red;
    frame.object(iCell).side1medial5Ratio = frame.object(iCell).side1Medial1Green./frame.object(iCell).side1Medial1Red;

    frame.object(iCell).side2medial1Ratio = frame.object(iCell).side2Medial1Green./frame.object(iCell).side2Medial1Red;
    frame.object(iCell).side2medial3Ratio = frame.object(iCell).side2Medial1Green./frame.object(iCell).side2Medial1Red;
    frame.object(iCell).side2medial5Ratio = frame.object(iCell).side2Medial1Green./frame.object(iCell).side2Medial1Red;

    frame.object(iCell).side1to2medial1RatioOfRatio = frame.object(iCell).side1medial1Ratio./frame.object(iCell).side2medial1Ratio;
    frame.object(iCell).side1to2medial3RatioOfRatio = frame.object(iCell).side1medial3Ratio./frame.object(iCell).side2medial3Ratio;
    frame.object(iCell).side1to2medial5RatioOfRatio = frame.object(iCell).side1medial5Ratio./frame.object(iCell).side2medial5Ratio;

    %%
    frame.object(iCell).side1to2LengthRatio = arcLength1./arcLength2;
    
    %%
    frame.object(iCell).path1 = path1;
    frame.object(iCell).path2 = path2;
    frame.object(iCell).poleAPix = poleAPix;
    frame.object(iCell).poleBpix = poleBPix;
    frame.object(iCell).poleAIdx = pole1Idx;
    frame.object(iCell).poleBIdx = pole2Idx;
    

    %% curvature of centerline
    frame.object(iCell).radiusOfCurvature_perPix = bestFitCircle(centerline(:,1),centerline(:,2));
    %%
    if isDisplay4
        hold on;
        scatter(frame.object(iCell).Xcont(pole1Idx),frame.object(iCell).Ycont(pole1Idx),'ro');
        scatter(frame.object(iCell).Xcont(pole2Idx),frame.object(iCell).Ycont(pole2Idx),'rs');
        plot(frame.object(iCell).Xcont(path1),frame.object(iCell).Ycont(path1),'r');
        plot(frame.object(iCell).Xcont(path2),frame.object(iCell).Ycont(path2),'b');
        
        scatter(frame.object(iCell).Xcont(poleAPix),frame.object(iCell).Ycont(poleAPix),'m^');
        scatter(frame.object(iCell).Xcont(poleBPix),frame.object(iCell).Ycont(poleBPix),'m*');
 
        hold off;
        pause();

    end
end

save(fileList{iFile},'frame','-append');

end
%%
%% Merge all the cells
allCells = [];
% loop over all the files
for iiFile = 1:length(fileList)
    tempLoad = load(fileList{iiFile});
    allCells = cat(2,allCells,tempLoad.frame.object);
    
end

%% Histogram pole intensities
% brighter Red Pole
brighterRedPole = max([allCells.poleAIntegratedRed],[allCells.poleBIntegratedRed]);
dimmerRedPole = min([allCells.poleAIntegratedRed],[allCells.poleBIntegratedRed]);
% subplot(2,1,1);
% hist(brighterRedPole./dimmerRedPole);
% xlabel ('ratio of new material (polar)');
% ylabel ('number of cells');

% brighter Green Pole
brighterGreenPole = max([allCells.poleAIntegratedGreen],[allCells.poleBIntegratedGreen]);
dimmerGreenPole = min([allCells.poleAIntegratedGreen],[allCells.poleBIntegratedGreen]);
% subplot(2,1,2);
% hist(brighterGreenPole./dimmerGreenPole);
% xlabel ('ratio of old material (polar)');
% ylabel ('number of cells');
polarAsymmetry = sqrt(((brighterGreenPole./dimmerGreenPole)-1).^2+...
    ((brighterRedPole./dimmerRedPole)-1).^2);

% isDivided = polarAsymmetry>quantile(polarAsymmetry,0.9);
isDivided = (brighterRedPole./dimmerRedPole)>3.443;
clf;
listOfDivided = find(isDivided);
listOfNotDivided = find(not(isDivided));

listOfDivided = listOfDivided(randperm(length(listOfDivided)));
listOfNotDivided = listOfNotDivided(randperm(length(listOfNotDivided)));

for ii=1:10
    subplot(5,5,ii);
    cla;
    hold on;
    iCell = listOfDivided(ii);
    
    path1 = allCells(iCell).path1;
    path2 = allCells(iCell).path2;
    poleAPix = allCells(iCell).poleAPix;
    poleBPix = allCells(iCell).poleBpix;
    pole1Idx = allCells(iCell).poleAIdx;
    pole2Idx = allCells(iCell).poleBIdx;
    
    scatter(allCells(iCell).Xcont,allCells(iCell).Ycont,allCells(iCell).ROverGRatio*2,'k*');
    scatter(allCells(iCell).Xcont(pole1Idx),allCells(iCell).Ycont(pole1Idx),'ko');
    scatter(allCells(iCell).Xcont(pole2Idx),allCells(iCell).Ycont(pole2Idx),'ks');
    plot(allCells(iCell).Xcont(path1),allCells(iCell).Ycont(path1),'r');
    plot(allCells(iCell).Xcont(path2),allCells(iCell).Ycont(path2),'b');
    plot(allCells(iCell).centerline(:,1),allCells(iCell).centerline(:,2),'kx');
%     scatter(allCells(iCell).Xcont(poleAPix),allCells(iCell).Ycont(poleAPix),'g^');
%     scatter(allCells(iCell).Xcont(poleBPix),allCells(iCell).Ycont(poleBPix),'g*');
    
        axis equal;
subplot(5,5,ii+15);
cla;
iCell = listOfNotDivided(ii);
path1 = allCells(iCell).path1;
path2 = allCells(iCell).path2;
poleAPix = allCells(iCell).poleAPix;
poleBPix = allCells(iCell).poleBpix;
pole1Idx = allCells(iCell).poleAIdx;
pole2Idx = allCells(iCell).poleBIdx;

        scatter(allCells(iCell).Xcont(pole1Idx),allCells(iCell).Ycont(pole1Idx),'ko');
       hold on;
       scatter(allCells(iCell).Xcont,allCells(iCell).Ycont,allCells(iCell).ROverGRatio*2,'k*');
        scatter(allCells(iCell).Xcont(pole2Idx),allCells(iCell).Ycont(pole2Idx),'ks');
        plot(allCells(iCell).Xcont(path1),allCells(iCell).Ycont(path1),'r');
        plot(allCells(iCell).Xcont(path2),allCells(iCell).Ycont(path2),'b');
        plot(allCells(iCell).centerline(:,1),allCells(iCell).centerline(:,2),'kx');
%         scatter(allCells(iCell).Xcont(poleAPix),allCells(iCell).Ycont(poleAPix),'g^');
%         scatter(allCells(iCell).Xcont(poleBPix),allCells(iCell).Ycont(poleBPix),'g*');
 axis equal;
end


    