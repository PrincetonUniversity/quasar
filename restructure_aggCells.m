function [aggCellsReshaped,fieldNamesAgg] = restructure_aggCells(aggCells);
%%
fieldNamesAgg = fieldnames(aggCells);
aggCellsReshaped = nan(length(aggCells),length(fieldNamesAgg));

for iField = 1:length(fieldNamesAgg);
    if length(aggCells(1).(fieldNamesAgg{iField})) ~= 1
        continue
    end
    
    for jCell = 1:length(aggCells)
       aggCellsReshaped(jCell,iField) = aggCells(jCell).(fieldNamesAgg{iField}); 
    end
    
end





