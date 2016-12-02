function extractFluorContour
%% pick files to process
fileList = uipickfiles('FilterSpec','*pill_MESH*');
%% loop over each file and pull out intensities
% offsetX_red = 2.25;
% offsetY_red = 1.5;
% 
% offsetX_green = 2.25;
% offsetY_green = 1.5;

% these settings worked on dCrvA (2015/12/16)
offsetX_red = 0.5;
offsetY_red = 0.5;

offsetX_green = 0.5;
offsetY_green = 0.5;

% these settings worked on WT (2015/12/16)
% offsetX_red = 2.25;
% offsetY_red = 1.5;
% 
% offsetX_green = 2.25;
% offsetY_green = 1.5;

% display contours to check for overlap between green/red channel and phase
% contrast contours
isDisplay1 = false; % c=1
isDisplay2 = false; % c=2


% display curvatures along contours and centerline and which is "inner",
% 'outer'
isDisplay3 = true;

% save merged images
isSaveMergedImage = true;
DILATE_FOR_MERGE  = 6; % number of times to run "dilate" on a region before cutting it out


% software version
softwareTifTag = 'extractFluorContour_0.02';
progressbar(0);
for iFile = 1:length(fileList)
    
    
    
    progressbar(iFile/length(fileList))
    % find the name of the file
    fullMeshFileName = fileList{iFile};
    
    % load in all the contours
    tempLoad = load(fullMeshFileName);
    
    % check to see if there are some offsets stored from the GUI
    if isfield(tempLoad,'spatialOffsets')
        offsetX_red = tempLoad.spatialOffsets.red_X;
        offsetY_red = tempLoad.spatialOffsets.red_Y;
        offsetX_green = tempLoad.spatialOffsets.green_X;
        offsetY_green = tempLoad.spatialOffsets.green_Y;

    end

    frame = tempLoad.frame;
    
    % find the name of the original tif
    tifFileStem = strrep(fullMeshFileName,'CONTOURS_pill_MESH.mat','');
    tifFileStem(end-12:end) = [];
    
    % channel c=0 is phase
    % channel c=1 is green
    % channel c=2 is red
    [parentName,tifFileName] = fileparts(tifFileStem);
    tifFileNd2 = strfind(tifFileName,'.nd2');
    tifFileName(tifFileNd2:end+4) = [];
    tifFileName = [tifFileName,'.nd2.tif'];
    tifFileName(1:3) = [];
    redImage = double(imread([parentName,filesep,tifFileName],1));
    greenImage = double(imread([parentName,filesep,tifFileName],2));
    phaseImage = double(imread([parentName,filesep,'C1-',tifFileName]));

        
    % display some contours
    if isDisplay1

    figure();
    imshow(greenImage,[quantile(greenImage(:),0.01),quantile(greenImage(:),0.995)],'i','f');
    for iCell = 1:length(frame.object)
       hold on;
       plot(frame.object(iCell).Xcont+offsetX_green,frame.object(iCell).Ycont+offsetY_green,'g');
    end
    pause();
    end
    
    % display some contours
    if isDisplay2

    figure();
    imshow(redImage,[quantile(redImage(:),0.01),quantile(redImage(:),0.995)],'i','f');
    for iCell = 1:length(frame.object)
       hold on;
       plot(frame.object(iCell).Xcont+offsetX_red,frame.object(iCell).Ycont+offsetY_red,'r');
    end
    pause();
    end
    
    % for each of the contours, extract the intensity for each pixel on the
    % contour
    
    % build a grid for testing if pixels are "inside" the cell or not
    xGrid = 1:size(greenImage,2);
    yGrid = 1:size(greenImage,1);
    [xGrid,yGrid] = meshgrid(xGrid,yGrid);
    
    %  loop over each cell and draw a mask for pixels that are inside the
    %  cell
    
    % background intensity
    background_red = quantile(redImage(:),0.001);
    background_green = quantile(greenImage(:),0.001);
    
    % gridded interpolant for processing images
    redInterp = griddedInterpolant(yGrid,xGrid,redImage,'cubic');
    greenInterp = griddedInterpolant(yGrid,xGrid,greenImage,'cubic');

    
     for iCell = 1:length(frame.object)
        tempXCont = frame.object(iCell).Xcont;
        tempYCont = frame.object(iCell).Ycont;
        % closed contour
        tempXCont = [tempXCont;tempXCont(1)];
        tempYCont = [tempYCont;tempYCont(1)];

        % centerline
        tempXCent = frame.object(iCell).centerline(:,1);
        tempYCent = frame.object(iCell).centerline(:,2);
        
        % mask those inside
        mask1_red = inpolygon(xGrid,yGrid,tempXCont+offsetX_red,tempYCont+offsetY_red);
        mask1_green = inpolygon(xGrid,yGrid,tempXCont+offsetX_green,tempYCont+offsetY_green);
        mask1_phase = inpolygon(xGrid,yGrid,tempXCont,tempYCont);
        
        
        % dilate slightly to catch pixels that might have been missed.
        mask1_red = bwmorph(mask1_red,'dilate',1);
        mask1_green = bwmorph(mask1_green,'dilate',1);
        mask1_phase = bwmorph(mask1_phase,'dilate',1);

        
        % in cell background
        cellBack_red = quantile(redImage(mask1_red(:)),0.005);
        cellBack_green = quantile(greenImage(mask1_green(:)),0.005);
        
        % in cell maximum
        cellMax_red = max(redImage(mask1_red(:)));
        cellMax_green = max(greenImage(mask1_green(:)));
        
        % raw intensity contour
        rawIntCont_red = redInterp(tempYCont+offsetY_red,tempXCont+offsetX_red);
        rawIntCont_green = greenInterp(tempYCont+offsetY_green,tempXCont+offsetX_green);

        % raw intensity centerline
        rawIntCent_red = redInterp(tempYCent+offsetY_red,tempXCent+offsetX_red);
        rawIntCent_green = greenInterp(tempYCent+offsetY_green,tempXCent+offsetX_green);

        % raw intensity sum
        rawIntSum_red = sum(redImage(:).*mask1_red(:));
        rawIntSum_green = sum(greenImage(:).*mask1_green(:));

        % store the data
        % on a per cell basis, find the min/max values (not really min max,
        % but close to it)
       frame.object(iCell).cellBack_green = cellBack_green;
       frame.object(iCell).cellBack_red = cellBack_red;
       frame.object(iCell).cellMax_green = cellMax_green;
       frame.object(iCell).cellMax_red = cellMax_red;
       
       % find the baseline background in the whole frame
       frame.object(iCell).background_green = background_green;
       frame.object(iCell).background_red = background_red;

       % intensities along the contour and integrated over the entire
       % masked area
       frame.object(iCell).rawIntCont_green = rawIntCont_green;
       frame.object(iCell).rawIntCont_red = rawIntCont_red;
       frame.object(iCell).rawIntCent_green = rawIntCent_green;
       frame.object(iCell).rawIntCent_red = rawIntCent_red;
       frame.object(iCell).rawIntSum_green = rawIntSum_green;
       frame.object(iCell).rawIntSum_red = rawIntSum_red;

        % cut out regions around each and save a merged image
        if isSaveMergedImage
            % find the boundaries of the bounding box
            boundingBoxGreen = regionprops(bwmorph(mask1_green,'dilate',DILATE_FOR_MERGE),'BoundingBox');
            boundingBoxRed = regionprops(bwmorph(mask1_red,'dilate',DILATE_FOR_MERGE),'BoundingBox');
            boundingBoxPhase = regionprops(bwmorph(mask1_phase,'dilate',DILATE_FOR_MERGE),'BoundingBox');
            
            
            % pull out just the field of interest
            boundingBoxGreen = round( boundingBoxGreen.BoundingBox);
            boundingBoxRed = round(boundingBoxRed.BoundingBox);
            boundingBoxPhase = round(boundingBoxPhase.BoundingBox);

            
            % extract the region
            try
            tempGreen = greenImage(boundingBoxGreen(2):boundingBoxGreen(2)+boundingBoxGreen(4),...
                boundingBoxGreen(1):boundingBoxGreen(1)+boundingBoxGreen(3));
            tempRed = redImage(boundingBoxRed(2):boundingBoxRed(2)+boundingBoxRed(4),...
                boundingBoxRed(1):boundingBoxRed(1)+boundingBoxRed(3));
            tempPhase = phaseImage(boundingBoxPhase(2):boundingBoxPhase(2)+boundingBoxPhase(4),...
                boundingBoxPhase(1):boundingBoxPhase(1)+boundingBoxPhase(3));
            
            
            
            % normalize the to [0,255]
            tempRed = tempRed - background_red;
            tempRed = tempRed./cellMax_red;
            tempRed = uint8(round(255*tempRed));
            
            tempGreen = tempGreen - background_green;
            tempGreen = tempGreen./cellMax_green;
            tempGreen = uint8(round(255*tempGreen));
            
            tempPhase = tempPhase - min(tempPhase(:));
            tempPhase = tempPhase ./ max(tempPhase(:));
            tempPhase = uint8(round(255*tempPhase));
            
            % create an rgb image
            tempMerge = cat(3,tempRed,tempGreen, zeros(size(tempGreen)));
            
            % new file name includes unique id
            mergeFluorFile =  [tifFileStem,'object=',num2str(iCell,'%03g'),'fluor.tif'];
            mergePhaseFile =  [tifFileStem,'object=',num2str(iCell,'%03g'),'phase.tif'];
            
            imwrite(tempMerge,mergeFluorFile,'compression','none');
            imwrite(tempPhase,mergePhaseFile,'compression','none');
            catch ME
            end
        end
     end
     save(fullMeshFileName,'frame','-append');
end

%%
for iFile = 1:length(fileList)
    % find the name of the file
    fullMeshFileName = fileList{iFile};
    
    % load in all the contours
    tempLoad = load(fullMeshFileName);
    frame = tempLoad.frame;
   
    
    for iCell = 1:length(frame.object);
   
        % 
        if isDisplay3
        % find inside and outside contour
        clf;
        hold on;
        pole1 = frame.object(iCell).pole1;
        pole2 = frame.object(iCell).pole2;
        scatter(frame.object(iCell).Xcont(pole1:pole2-1),frame.object(iCell).Ycont(pole1:pole2-1),35,frame.object(iCell).kappa_smooth(pole1:pole2-1),'x');
        scatter(frame.object(iCell).Xcont(pole2:end),frame.object(iCell).Ycont(pole2:end),35,frame.object(iCell).kappa_smooth(pole2:end),'o');

        axis equal;
        scatter(frame.object(iCell).centerline(:,1),frame.object(iCell).centerline(:,2),'kx');
        pause();
        end
    end
    
end
%%
% + integrated intensity (both color channels) along face 1, face 2, pole 1, pole 2
% + length of face 1, face 2, pole 1, pole 2
% + ratio of intensities along face 1, face 2, pole 1, pole 2
% + total intensity of each color for entire cell
% + fraction of intensity in both colors on both faces
% + ratio of fraction of intensity on both colors
% + a central/medial patch of 1 pix, 3 pix, 5 pix, 
% + insertion bias (G-R)/(G+R) and relative insertion bias from one face to
%       another face
% + full width at half max, relative position to pole position
% + which fraction of pole goes on inner face/outer face


