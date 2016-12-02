
ind3 = []; % starts as 2 -> 1
ind4 = []; % starts as 1 -> 2
ind5 = []; % replace with nans
for iiField = 1:length(fieldNamesAgg)
    tempName = fieldNamesAgg{iiField};
    if not(strcmp(strrep(tempName,'side1','side2'),tempName));
        ind1 = iiField;
        ind2 = find(strcmp(fieldNamesAgg,strrep(tempName,'side1','side2')));
        
        if not(isempty(ind2))
            ind3 = cat(1,ind3,ind1,ind2);
            ind4 = cat(1,ind4,ind2,ind1);
            
        else
            ind5 = cat(1,ind5,ind1);
        end
    elseif strcmp(tempName,'arcLength1');
        ind1 = iiField;
        ind2 = find(strcmp(fieldNamesAgg,strrep(tempName,'ength1','ength2')));
        ind3 = cat(1,ind3,ind1,ind2);
        ind4 = cat(1,ind4,ind2,ind1);
    end
    
    
end
%%
%
% isSwapSides = zeros(size(aggCellsReshaped,1),1);
% isSwapSides(1) = 1;
%
desiredField = 'arcLength1';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'arcLength2';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength2 = aggCellsReshaped(:,desiredFieldIDX);


%% determine if outer side is longer and swap
sidesSwapped = false(size(aggCellsReshaped,1),1);
for iiCell = 1:size(aggCellsReshaped,1)
    if arcLength1(iiCell)<arcLength2(iiCell);
        aggCellsReshaped(iiCell,ind4) = aggCellsReshaped(iiCell,ind3);
       aggCellsReshaped(iiCell,ind5) = nan;
       sidesSwapped(iiCell) = true;
    end
end
nnz(sidesSwapped)


%% determine if outer side has a higher amount of red (newer material)
sidesSwapped = false(size(aggCellsReshaped,1),1);

desiredField = 'arcLength1';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'arcLength2';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength2 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'side1IntegratedRed';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
redIntensity1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'side2IntegratedRed';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
redIntensity2 = aggCellsReshaped(:,desiredFieldIDX);


for iiCell = 1:size(aggCellsReshaped,1)
    if redIntensity1(iiCell) < redIntensity2(iiCell);
        aggCellsReshaped(iiCell,ind4) = aggCellsReshaped(iiCell,ind3);
       aggCellsReshaped(iiCell,ind5) = nan;
       sidesSwapped(iiCell) = true;
    end
end
nnz(sidesSwapped)

%%
%% determine if outer side has a higher amount of red (newer material)
sidesSwapped = false(size(aggCellsReshaped,1),1);

desiredField = 'arcLength1';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'arcLength2';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
arcLength2 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'side1IntegratedRed';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
redIntensity1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'side2IntegratedRed';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
redIntensity2 = aggCellsReshaped(:,desiredFieldIDX);


for iiCell = 1:size(aggCellsReshaped,1)
    if redIntensity1(iiCell)./arcLength1(iiCell) < redIntensity2(iiCell)./arcLength2(iiCell);
        aggCellsReshaped(iiCell,ind4) = aggCellsReshaped(iiCell,ind3);
       aggCellsReshaped(iiCell,ind5) = nan;
       sidesSwapped(iiCell) = true;
    end
end
nnz(sidesSwapped)

%% determine if sides should be swapped somewhere else 
for iiCell = 1:size(aggCellsReshaped,1)
    if sidesSwapped(iiCell);
        aggCellsReshaped(iiCell,ind4) = aggCellsReshaped(iiCell,ind3);
        aggCellsReshaped(iiCell,ind5) = nan;
    end
end
nnz(sidesSwapped)


%% apply side swap

aggCells2 = aggCells;


for iCell = 1:length(aggCells)
    if sidesSwapped(iCell)
%     if aggCells(iCell).side1IntegratedRed<aggCells(iCell).side2IntegratedRed;
        aggCells2(iCell).arcLength1 = aggCells(iCell).arcLength2;
      aggCells2(iCell).arcLength2 = aggCells(iCell).arcLength1;
      aggCells2(iCell).side1IntegratedGreen = aggCells(iCell).side2IntegratedGreen;
      aggCells2(iCell).side2IntegratedGreen = aggCells(iCell).side1IntegratedGreen;
      aggCells2(iCell).side1IntegratedRed = aggCells(iCell).side2IntegratedRed;
      aggCells2(iCell).side2IntegratedRed = aggCells(iCell).side1IntegratedRed;      
   else
      aggCells2(iCell).arcLength2 = aggCells(iCell).arcLength2;
      aggCells2(iCell).arcLength1 = aggCells(iCell).arcLength1;
      aggCells2(iCell).side2IntegratedGreen = aggCells(iCell).side2IntegratedGreen;
      aggCells2(iCell).side1IntegratedGreen = aggCells(iCell).side1IntegratedGreen;
      aggCells2(iCell).side2IntegratedRed = aggCells(iCell).side2IntegratedRed;
      aggCells2(iCell).side1IntegratedRed = aggCells(iCell).side1IntegratedRed;      
   
   end
    
end