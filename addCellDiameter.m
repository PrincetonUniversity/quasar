for iiCell = 1:length(aggCells);
    aaa = aggCells(iiCell).pill_mesh;
    bbb = sqrt((aaa(:,1)-aaa(:,3)).^2+((aaa(:,2)-aaa(:,4)).^2));
    bbb(1:4) = [];
    bbb(end-3:end);
    aggCellsReshaped(iiCell,118) = mean(bbb)*0.13/2;
    aggCellsReshaped_longSide(iiCell,118) = mean(bbb)*0.13/2;
    aggCellsReshaped_containedInCenterlineCircCopyCopy(iiCell,118) = mean(bbb)*0.13/2;
    aggCellsReshaped_midArcCurvature(iiCell,118) = mean(bbb)*0.13/2;

end

fieldNamesAgg{118} = 'meanCellRadius_micron';

