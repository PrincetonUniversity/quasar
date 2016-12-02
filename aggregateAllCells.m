%% folder to aggregate all the data from

% folderName = uigetdir();
%%
% preallocate an empty variable to hold the composite data set
% allAllCells = [];
% datasetList = dir([folderName,filesep,'*.mat']);
datasetList = uipickfiles();
%%
aggCells = [];

for iiDataSubset = 1:length(datasetList)
% for iiDataSubset = 1;
   
    [~,labelString] = fileparts(datasetList{iiDataSubset});
    underscoreIdx = strfind(labelString,'_');
    strainName = labelString(underscoreIdx(1)+1:underscoreIdx(2)-1);
    timeName =  labelString(underscoreIdx(2)+1:end-4);
    
    tempLoad = load(datasetList{iiDataSubset});
    allCells = tempLoad.allCells;
    [allCells.datasetIndex]=deal(iiDataSubset);
    [allCells.strLabel] = deal(labelString);
    [allCells.strainName] = deal(strainName);
    [allCells.timeName] = deal(timeName);

    
    % aggregate
    aggCells = cat(2,aggCells,allCells);
end

%%
maxOldPole = max([aggCells.poleAIntegratedGreen],[aggCells.poleBIntegratedGreen]);
minOldPole = min([aggCells.poleAIntegratedGreen],[aggCells.poleBIntegratedGreen]);
hist(maxOldPole./minOldPole,200);
set(gca,'YScale','log')

isDivided = (maxOldPole./minOldPole)>3.4483;

outsideIntegratedRatio=([aggCells.side1IntegratedRed]./[aggCells.side1IntegratedGreen]);
insideIntegratedRatio=([aggCells.side2IntegratedRed]./[aggCells.side2IntegratedGreen]);
curvatureMu = (1./[aggCells.radiusOfCurvature_perPix])/.13;

for ii = 1:length(aggCells)    
    isWT(ii) = strcmp(aggCells(ii).strainName,'WT');
%     is6Min(ii) = strcmp(aggCells(ii).timeName,'06');
%     is12Min(ii) = strcmp(aggCells(ii).timeName,'12');
%     is24Min(ii) = strcmp(aggCells(ii).timeName,'24');
end
%%
% one for everything
% one for each
% one for time point aggregates

xtot = curvatureMu(and(not(isDivided),isWT));
indx = [aggCells.datasetIndex];

x1 = curvatureMu(and(not(isDivided),indx==1));
x2 = curvatureMu(and(not(isDivided),indx==2));
x3 = curvatureMu(and(not(isDivided),indx==3));
x4 = curvatureMu(and(not(isDivided),indx==4));
x5 = curvatureMu(and(not(isDivided),indx==5));
x6 = curvatureMu(and(not(isDivided),indx==6));
x7 = curvatureMu(and(not(isDivided),indx==7));
x8 = curvatureMu(and(not(isDivided),indx==8));

% x1 = curvatureMu(indx==1);
% x2 = curvatureMu(indx==2);
% x3 = curvatureMu(indx==3);
% 
% x4 = curvatureMu(indx==4);
% x5 = curvatureMu(indx==5);
% x6 = curvatureMu(indx==6);

ytot = [aggCells.side1IntegratedRed]./[aggCells.side2IntegratedRed];
y1 = ytot(and(not(isDivided),indx==1));
y2 = ytot(and(not(isDivided),indx==2));
y3 = ytot(and(not(isDivided),indx==3));
y4 = ytot(and(not(isDivided),indx==4));
y5 = ytot(and(not(isDivided),indx==5));
y6 = ytot(and(not(isDivided),indx==6));
y7 = ytot(and(not(isDivided),indx==7));
y8 = ytot(and(not(isDivided),indx==8));

% y1 = ytot(indx==1);
% y2 = ytot(indx==2);
% y3 = ytot(indx==3);
% y4 = ytot(indx==4);
% y5 = ytot(indx==5);
% y6 = ytot(indx==6);


nBins = 30;
binsX{1} = linspace(0,1,nBins);
binsX{2} = linspace(0,3,nBins);

[image7] = histcn([x7',y7'],binsX{1},binsX{2});
image7 = image7./sum(image7(:));
image7(nBins+1,nBins+1) = nan;

[image8] = histcn([x8',y8'],binsX{1},binsX{2});
image8 = image8./sum(image8(:));
image8(nBins+1,nBins+1) = nan;

[image6] = histcn([x6',y6'],binsX{1},binsX{2});
image6 = image6./sum(image6(:));
image6(nBins+1,nBins+1) = nan;

[image5] = histcn([x5',y5'],binsX{1},binsX{2});
image5 = image5./sum(image5(:));
image5(nBins+1,nBins+1) = nan;

[image4] = histcn([x4',y4'],binsX{1},binsX{2});
image4 = image4./sum(image4(:));
image4(nBins+1,nBins+1) = nan;

[image3] = histcn([x3',y3'],binsX{1},binsX{2});
image3 = image3./sum(image3(:));
image3(nBins+1,nBins+1) = nan;

[image2] = histcn([x2',y2'],binsX{1},binsX{2});
image2 = image2./sum(image2(:));
image2(nBins+1,nBins+1) = nan;

[image1] = histcn([x1',y1'],binsX{1},binsX{2});
image1 = image1./sum(image1(:));
image1(nBins+1,nBins+1) = nan;

%%
% 
% for ii = 1:length(datasetList)
%     [a,b] = fileparts(datasetList{ii});
%     datasetList2{ii} = b;
% end
%%
figure()

subplot(2,4,1)
imshow((image1),[],'i','f');
title(datasetList2{1},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
axis on;
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);

subplot(2,4,2)
imshow((image2),[],'i','f');
title(datasetList2{2},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(2,4,3)
imshow((image3),[],'i','f');
title(datasetList2{3},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(2,4,4)
imshow((image4),[],'i','f');
title(datasetList2{4},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;


subplot(2,4,5)
imshow((image5),[],'i','f');
title(datasetList2{5},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(2,4,6)
imshow((image6),[],'i','f');
title(datasetList2{6},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(2,4,7)
imshow((image7),[],'i','f');
title(datasetList2{7},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(2,4,8)
imshow((image8),[],'i','f');
title(datasetList2{8},'Interpreter','None');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

%%
figure();

timePoint1 = zeros(nBins+1,nBins+1,3);
timePoint1(:,:,1)= round(10000*image1);
timePoint1(:,:,2)= round(10000*image5);

timePoint2 = zeros(nBins+1,nBins+1,3);
timePoint2(:,:,1)= (round(10000*image2));
timePoint2(:,:,2)= (round(10000*image6));

timePoint3 = zeros(nBins+1,nBins+1,3);
timePoint3(:,:,1)= (round(10000*image3));
timePoint3(:,:,2)= (round(10000*image7));

timePoint4 = zeros(nBins+1,nBins+1,3);
timePoint4(:,:,1)= (round(10000*image4));
timePoint4(:,:,2)= (round(10000*image8));

subplot(1,4,1)
imshow(uint8(timePoint1),[],'i','f');
title('1st time point');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);

subplot(1,4,2)
imshow(uint8(timePoint2),[],'i','f');
title('2nd time point');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

subplot(1,4,3)
imshow(uint8(timePoint3),[],'i','f');
title('3rd time point');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);

subplot(1,4,4)
imshow(uint8(timePoint4),[],'i','f');
title('4th time point');
xlabel('curvature');ylabel('outInNewIntegral');
view(-90,90);

set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;
set(gca,'XTickLabels',binsX{1}(get(gca,'XTick')));
set(gca,'YTickLabels',binsX{2}(get(gca,'YTick')));
set(gca,'YTickLabelRotation',90);
axis on;

