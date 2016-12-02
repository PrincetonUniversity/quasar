function plotMetric_innerOuter(aggCellsReshaped,fieldNamesAgg);
%%

%%
CURVATURE_THRESH = 0.1;
ALPHA_VAL = 0.1; % 0.05 is 95% CI

timeLabels = [6,15,24,30];
clear results

%
listOfCases = {...
    'new material ratio with poles (isDivided)',...
    'old material ratio with poles (isDivided)',...
    'new material ratio (isDivided)',...
    'new material ratio (notDivided)',...
    'old material ratio (isDivided)',...
    'old material ratio (notDivided)',...
    'new material integrated (isDivided) (arb units)',...
    'new material integrated (notDivided) (arb units)',...
    'new material integrated with poles (isDivided) (arb units)',...
    'new material concentration (isDivided) (arb units um^-1)',...
    'new material concentration (notDivided) (arb units um^-1)',...
    'old material integrated (isDivided) (arb units)',...
    'old material integrated (notDivided) (arb units)',...
    'old material integrated with poles (isDivided) (arb units)',...
    'old material concentration (isDivided) (arb units um^-1)',...
    'old material concentration (notDivided) (arb units um^-1)',...
    'arc length (isDivided) (um)',...
    'arc length (notDivided) (um)',...
    'centerline curvature - microbeTrackerStyle (isDivided) (um^-1)',...
    'centerline curvature - microbeTrackerStyle (notDivided) (um^-1)',...
    'cell diameter (isDivided) (um)',...
    'cell diameter (notDivided) (um)',...
    'fraction of cells isDivided',...
    'number of cells isDivided',...
    'number of cells notDivided',...
    'ratio of (new/old) isDivided',...
    'ratio of (new/old) notDivided',...
    'ratio of (new/old) with poles isDivided',...
    'ratio of (new/old) poles (notDivided)',...
    'ratio of (new/old) poles splitByLowerNewOverOldRatio (isDivided)',...
    'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] isDivided',...
    'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] notDivided',...
    'old material concentration poles (notDivided) (arb units um^-1)',...
    'old material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)',...
    'old material integrated poles (notDivided) (arb units)',...
    'old material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)',...
    'new material concentration poles (notDivided) (arb units um^-1)',...
    'new material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)',...
    'new material integrated poles (notDivided) (arb units)',...
    'new material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)',...
    'log10 pvalue ttest --newness_out-- vs --newness_in-- notDivided',...
    'ratio of --newness_out--/--newness_in-- (notDivided)',...
    'scatter curvature vs --newness_out--/--newness_in (notDivided)',...
    'scatter curvature vs integrated ratio newOut/newIn (notDivided)',...
    };


[selectionIDX,ok] = listdlg('ListString',listOfCases,'ListSize',[400,300]);
caseLabel = listOfCases{selectionIDX};

centralTendency = questdlg('Typical or average?','','median','mean','median');
truncateStraight = questdlg('Truncate straight cells from WT population?','','removeStraight-WT','keepAll-WT','keepAll-WT');
samePlots = questdlg('Lump dCrvA and WT into one plot?','','two plots','one plot','two plots');




%
%
desiredField = 'poleAIntegratedGreen';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
oldPole1 = aggCellsReshaped(:,desiredFieldIDX);

desiredField = 'poleBIntegratedGreen';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
oldPole2 = aggCellsReshaped(:,desiredFieldIDX);

maxOldPole = max(oldPole1,oldPole2);
minOldPole = min(oldPole1,oldPole2);

isDivided = (maxOldPole(:)./minOldPole(:))'>3.4483;


desiredField = 'datasetIndex';
desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
dataSetIDX = aggCellsReshaped(:,desiredFieldIDX)';
%


%
figMain = figure();
switch samePlots
    case 'two plots'
        subplot(1,2,1);
        hold all;
        ylabel(caseLabel);
        xlabel('time (min)');
        
        subplot(1,2,2);
        hold all;
        ylabel(caseLabel);
        xlabel('time (min)');
    case 'one plot'
        subplot(1,1,1);
        hold all;
        ylabel(caseLabel);
        xlabel('time (min)');
        
end


switch caseLabel
    case {'scatter curvature vs --newness_out--/--newness_in (notDivided)',...
           'scatter curvature vs integrated ratio newOut/newIn (notDivided)',...
           }
        fig1 = figure();
        fig2 = figure();
end




for ii = 1:8
    switch caseLabel
                case   'scatter curvature vs integrated ratio newOut/newIn (notDivided)'
                    figure(fig1);
                    hold all;
                    desiredField = 'side1IntegratedRed';
                    desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
                    tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
                  
                    desiredField = 'side2IntegratedRed';
                    desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
                    tempData2 = aggCellsReshaped(:,desiredFieldIDX);
                    
                    tempData = tempData1./tempData2;
                    
            
            newnessRatio = tempData(and(dataSetIDX==ii, not(isDivided)));
            
            desiredField = 'radiusOfCurvature_perPix';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (1./tempData1)/.13;
            centerlineCurvature = tempData(and(dataSetIDX==ii, not(isDivided)));

            if and(ii>4,strcmp(truncateStraight,'removeStraight-WT'))
               newnessRatio( centerlineCurvature<CURVATURE_THRESH) = [];
               centerlineCurvature( centerlineCurvature<CURVATURE_THRESH) = [];

            end
            scatter(newnessRatio,centerlineCurvature);

            ft = fittype( 'poly1' );
opts_dataFit = fitoptions( 'Method', 'LinearLeastSquares' );
[fitresult_dataFit, gof_dataFit] = fit(newnessRatio, centerlineCurvature, ft, opts_dataFit );

  dataFit_params = confint(fitresult_dataFit,1-ALPHA_VAL);
    disp(['Slope for  ',num2str(ii), ': ', num2str(dataFit_params(:,1)')]);
    disp(['Best slope: ',num2str(fitresult_dataFit.p1)]);
    
    plot(xlim,fitresult_dataFit(xlim));
    aa= corrcoef(newnessRatio,centerlineCurvature);
    disp(['Correlation coefficient: ',num2str(aa(2))]);
    xlabel('ratio of integrated_new_out / integrated_newn_in');
    ylabel('centerline curvature um^-1');

figure(figMain);
tempData = nan;

        case   'scatter curvature vs --newness_out--/--newness_in (notDivided)'
figure(fig1);
hold all;
desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessOut = tempData1.*tempData2./(tempData3.*tempData4);
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessIn = tempData1.*tempData2./(tempData3.*tempData4);
            
            tempData = newnessOut./newnessIn;
            newnessRatio = tempData(and(dataSetIDX==ii, not(isDivided)));
            
            desiredField = 'radiusOfCurvature_perPix';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (1./tempData1)/.13;
            centerlineCurvature = tempData(and(dataSetIDX==ii, not(isDivided)));

            if and(ii>4,strcmp(truncateStraight,'removeStraight-WT'))
               newnessRatio( centerlineCurvature<CURVATURE_THRESH) = [];
               centerlineCurvature( centerlineCurvature<CURVATURE_THRESH) = [];

            end
            scatter(newnessRatio,centerlineCurvature);
             xlabel('--ratio of newness_out-- / --newness_in--');
                          ylabel('centerline curvature um^-1');

figure(figMain);
tempData = nan;
        case 'ratio of (new/old) poles splitByLowerNewOverOldRatio (isDivided)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            
            % set up a holder for the concentration values in the older
            % pole
            poleNewness = min(poleANewness,poleBNewness);
  
            tempData = poleNewness(and(dataSetIDX==ii, (isDivided)));
          
        case 'ratio of (new/old) poles (notDivided)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleNewness = ((tempData1+tempData3).*tempData2)./((tempData6+tempData8).*tempData7);
            tempData = poleNewness(and(dataSetIDX==ii, not(isDivided)));
            
        case 'old material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationOld = tempData6.*tempData7;
            poleBConcentrationOld = tempData8.*tempData7;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationOld));
            poleConcentration(poleANewness<poleBNewness) = poleAConcentrationOld(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleBConcentrationOld(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case     'new material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)',...
                desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationNew = tempData1.*tempData2;
            poleBConcentrationNew = tempData3.*tempData2;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationNew));
            poleConcentration(poleANewness<poleBNewness) = poleAConcentrationNew(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleBConcentrationNew(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'new material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationNew = tempData1.*tempData2./tempData4;
            poleBConcentrationNew = tempData3.*tempData2./tempData5;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationNew));
            poleConcentration(poleANewness<poleBNewness) = poleAConcentrationNew(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleBConcentrationNew(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'old material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationOld = tempData6.*tempData7./tempData4;
            poleBConcentrationOld = tempData8.*tempData7./tempData5;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationOld));
            poleConcentration(poleANewness<poleBNewness) = poleAConcentrationOld(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleBConcentrationOld(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of --newness_out--/--newness_in-- (notDivided)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessOut = tempData1.*tempData2./(tempData3.*tempData4);
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessIn = tempData1.*tempData2./(tempData3.*tempData4);
            
            tempData = newnessOut./newnessIn;
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case  'log10 pvalue ttest --newness_out-- vs --newness_in-- notDivided',...
                desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessOut = tempData1.*tempData2./(tempData3.*tempData4);
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            newnessIn = tempData1.*tempData2./(tempData3.*tempData4);
            
            [~,tempData] = ttest(newnessIn(and(dataSetIDX==ii, not(isDivided))),...
                newnessOut(and(dataSetIDX==ii, not(isDivided))));
            
            tempData =log10(tempData);
            tempData = repmat(tempData,nnz(and(dataSetIDX==ii, not(isDivided))),1)+...
                10*eps*randn(nnz(and(dataSetIDX==ii, not(isDivided))),1);
        case     'new material integrated poles (notDivided) (arb units)',...
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (tempData1+tempData3).*tempData2;
            
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'old material integrated poles (notDivided) (arb units)'
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (tempData1+tempData3).*tempData2;
            
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'old material concentration poles (notDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (tempData1+tempData3).*tempData2./(tempData4+tempData5);
            
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'new material concentration poles (notDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            tempData = (tempData1+tempData3).*tempData2./(tempData4+tempData5);
            
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] notDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            concentrationOut = tempData1.*tempData2./tempData3;
            
            
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            concentrationIn = tempData1.*tempData2./tempData3;
            [~,tempData] = ttest(concentrationIn(and(dataSetIDX==ii, not(isDivided))),...
                concentrationOut(and(dataSetIDX==ii, not(isDivided))));
            
            tempData =log10(tempData);
            tempData = repmat(tempData,nnz(and(dataSetIDX==ii, not(isDivided))),1)+...
                10*eps*randn(nnz(and(dataSetIDX==ii, not(isDivided))),1);
        case 'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] isDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            concentrationOut = tempData1.*tempData2./tempData3;
            
            
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            concentrationIn = tempData1.*tempData2./tempData3;
            [~,tempData] = ttest(concentrationIn(and(dataSetIDX==ii, (isDivided))),...
                concentrationOut(and(dataSetIDX==ii, (isDivided))));
            
            tempData =log10(tempData);
            tempData = repmat(tempData,nnz(and(dataSetIDX==ii, (isDivided))),1)+...
                10*eps*randn(nnz(and(dataSetIDX==ii, (isDivided))),1);
            
        case 'ratio of (new frac / old frac) isDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new frac / old frac) notDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'ratio of (new frac / old frac) with poles isDivided'
            desiredField = 'side1WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
        case 'ratio of (new/old) isDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new/old) notDivided'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'ratio of (new/old) with poles isDivided'
            desiredField = 'side1WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side1WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'number of cells isDivided'
            tempData1 = nnz(and(dataSetIDX==ii, (isDivided)));
            tempData2 = nnz(and(dataSetIDX==ii, not(isDivided)));
            tempData = tempData1;
            tempData = repmat(tempData,tempData2,1)+10*eps*randn(tempData2,1);
            disp(tempData(1));
            if strcmp( truncateStraight,'removeStraight-WT')
                warning('plotMetric_innerOuter:fractionOfCells:noRemoval','Fraction of cells is based on counting cells and does not support removing straight cells at this point.');
                truncateStraight = 'keepAll-WT';
                
            end
        case 'number of cells notDivided'
            tempData1 = nnz(and(dataSetIDX==ii, (isDivided)));
            tempData2 = nnz(and(dataSetIDX==ii, not(isDivided)));
            tempData = tempData2;
            tempData = repmat(tempData,tempData2,1)+10*eps*randn(tempData2,1);
            disp(tempData(1));
            if strcmp( truncateStraight,'removeStraight-WT')
                warning('plotMetric_innerOuter:fractionOfCells:noRemoval','Fraction of cells is based on counting cells and does not support removing straight cells at this point.');
                truncateStraight = 'keepAll-WT';
                
            end
        case 'fraction of cells isDivided'
            tempData1 = nnz(and(dataSetIDX==ii, (isDivided)));
            tempData2 = nnz(and(dataSetIDX==ii, not(isDivided)));
            tempData = tempData1./(tempData1+tempData2);
            tempData = repmat(tempData,tempData2,1)+10*eps*randn(tempData2,1);
            disp(tempData(1));
            if strcmp( truncateStraight,'removeStraight-WT')
                warning('plotMetric_innerOuter:fractionOfCells:noRemoval','Fraction of cells is based on counting cells and does not support removing straight cells at this point.');
                truncateStraight = 'keepAll-WT';
                
            end
        case     'cell diameter (isDivided) (um)'
            desiredField = 'meanCellRadius_micron';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case     'cell diameter (notDivided) (um)'
            desiredField = 'meanCellRadius_micron';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'centerline curvature - microbeTrackerStyle (notDivided) (um^-1)'
            
            desiredField = 'radiusOfCurvature_perPix';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = (1./tempData1)/.13;
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
        case 'centerline curvature - microbeTrackerStyle (isDivided) (um^-1)'
            
            desiredField = 'radiusOfCurvature_perPix';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = (1./tempData1)/.13;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'arc length (isDivided) (um)'
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData1.*0.13;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
            
        case 'arc length (notDivided) (um)'
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData1.*0.13;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
            
        case 'new material integrated (isDivided) (arb units)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'new material integrated with poles (isDivided) (arb units)'
            desiredField = 'side1WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
        case 'old material integrated with poles (isDivided) (arb units)'
            desiredField = 'side1WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
            
        case 'new material ratio with poles (isDivided)'
            desiredField = 'side1WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
        case 'old material ratio with poles (notDivided)'
            desiredField = 'side1WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
        case 'old material ratio with poles (isDivided)'
            desiredField = 'side1WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
        case 'new material ratio (isDivided)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
        case 'new material ratio (notDivided)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
        case 'old material ratio (isDivided)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
        case 'old material ratio (notDivided)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
            
        case 'new material integrated (notDivided) (arb units)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
        case 'new material concentration (notDivided) (arb units um^-1)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX).*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'new material concentration (isDivided) (arb units um^-1)'
            desiredField = 'side1IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX).*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
        case 'old material integrated (notDivided) (arb units)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'old material concentration (notDivided) (arb units um^-1)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'old material integrated (isDivided) (arb units)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'old material concentration (isDivided) (arb units um^-1)'
            desiredField = 'side1IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength1';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
            
    end
    
    if numel(tempData)<10;
        tempData = nan;
    end
    
    try
        switch truncateStraight
            case 'removeStraight-WT'
                
                desiredField = 'radiusOfCurvature_perPix';
                desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
                tempData1 = aggCellsReshaped(:,desiredFieldIDX)';
                curvature_perMicron = (1./tempData1)/.13;
                
                if ~isempty(strfind(caseLabel,'isDivided'))
                    curvature_perMicron = curvature_perMicron(and(dataSetIDX==ii,(isDivided)));
                elseif ~isempty(strfind(caseLabel,'notDivided'))
                    curvature_perMicron = curvature_perMicron(and(dataSetIDX==ii,(~isDivided)));
                    
                end
                
                if ii>4
                    tempData(curvature_perMicron<CURVATURE_THRESH) = [];
                end
        end
        
        switch centralTendency
            case 'median'
                results(ii,1) = nanmedian((tempData(:)'));
                aa = bootci(2000,{@nanmedian,(tempData(:)')},'alpha',ALPHA_VAL);
                
                results(ii,2:3) = aa(:);
            case 'mean'
                results(ii,1) = nanmean((tempData(:)'));
                aa = bootci(2000,{@nanmean,(tempData(:)')},'alpha',ALPHA_VAL);
                
                results(ii,2:3) = aa(:);
        end
        
    catch ME
        results(ii,1:3) = nan;
        
    end
    
    switch caseLabel
        case 'arc length (notDivided) (um)'
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData1.*0.13;
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'arc length (isDivided) (um)'
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            
            tempData = tempData1.*0.13;
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
            
        case {'new material ratio (isDivided)',...
                'new material ratio (notDivided)',...
                'old material ratio (isDivided)',...
                'old material ratio (notDivided)',...
                'new material ratio with poles (isDivided)',...
                'old material ratio with poles (isDivided)',...
                'old material ratio with poles (notDivided)',...
                'centerline curvature - microbeTrackerStyle (notDivided) (um^-1)',...
                'centerline curvature - microbeTrackerStyle (isDivided) (um^-1)',...
                'cell diameter (isDivided) (um)',...
                'cell diameter (notDivided) (um)',...
                'fraction of cells isDivided',...
                'number of cells notDivided',...
                'number of cells isDivided',...
                'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] isDivided',...
                'log10 pvalue ttest [newMaterial_out] vs [newMaterial_in] notDivided',...
                'old material concentration poles (notDivided) (arb units um^-1)',...
                'old material integrated poles (notDivided) (arb units)',...
                'log10 pvalue ttest --newness_out-- vs --newness_in-- notDivided',...
                'ratio of --newness_out--/--newness_in-- (notDivided)',...
                 'new material integrated poles (notDivided) (arb units)',...
                 'ratio of (new/old) poles (notDivided)',...
                 'scatter curvature vs --newness_out--/--newness_in (notDivided)',...
                 'scatter curvature vs integrated ratio newOut/newIn (notDivided)',...
                 };
            tempData = nan;
            case 'ratio of (new/old) poles splitByLowerNewOverOldRatio (isDivided)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            
            % set up a holder for the concentration values in the older
            % pole
            poleNewness = max(poleANewness,poleBNewness);
  
            tempData = poleNewness(and(dataSetIDX==ii, (isDivided)));
          
         case 'new material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationNew = tempData1.*tempData2./tempData4;
            poleBConcentrationNew = tempData3.*tempData2./tempData5;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationNew));
            poleConcentration(poleANewness<poleBNewness) = poleBConcentrationNew(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleAConcentrationNew(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'old material concentration poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationOld = tempData6.*tempData7./tempData4;
            poleBConcentrationOld = tempData8.*tempData7./tempData5;

            % set up a holder for the concentration values in the newer
            % pole
            poleConcentration = nan(size(poleAConcentrationOld));
            poleConcentration(poleANewness<poleBNewness) = poleBConcentrationOld(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleAConcentrationOld(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            case 'new material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationNew = tempData1.*tempData2;
            poleBConcentrationNew = tempData3.*tempData2;

            % set up a holder for the concentration values in the older
            % pole
            poleConcentration = nan(size(poleAConcentrationNew));
            poleConcentration(poleANewness<poleBNewness) = poleBConcentrationNew(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleAConcentrationNew(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'old material integrated poles splitByLowerNewOverOldRatio (isDivided) (arb units um^-1)'
            desiredField = 'poleAIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthA';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLengthB';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData5 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleAIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData6 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData7 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'poleBIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData8 = aggCellsReshaped(:,desiredFieldIDX);
            
            poleANewness = tempData1./tempData6;
            poleBNewness = tempData3./tempData8;
            
            poleAConcentrationOld = tempData6.*tempData7;
            poleBConcentrationOld = tempData8.*tempData7;

            % set up a holder for the concentration values in the newer
            % pole
            poleConcentration = nan(size(poleAConcentrationOld));
            poleConcentration(poleANewness<poleBNewness) = poleBConcentrationOld(poleANewness<poleBNewness);
            poleConcentration(poleANewness>poleBNewness) = poleAConcentrationOld(poleANewness>poleBNewness);

            tempData = poleConcentration(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new frac / old frac) isDivided'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new frac / old frac) notDivided'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'ratio of (new frac / old frac) with poles isDivided'
            desiredField = 'side2WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1./(tempData3);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new/old) isDivided'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'ratio of (new/old) notDivided'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, not(isDivided)));
            
        case 'ratio of (new/old) with poles isDivided'
            desiredField = 'side2WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'side2WithPoleIntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData4 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2./(tempData3.*tempData4);
            tempData = tempData(and(dataSetIDX==ii, (isDivided)));
            
        case 'new material integrated (notDivided) (arb units)'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
            
        case 'new material integrated (isDivided) (arb units)'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'old material integrated with poles (isDivided) (arb units)'
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'new material integrated with poles (isDivided) (arb units)'
            desiredField = 'side2WithPoleIntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'new material concentration (notDivided) (arb units um^-1)'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'new material concentration (isDivided) (arb units um^-1)'
            desiredField = 'side2IntegratedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedRed';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'old material integrated (notDivided) (arb units)'
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'old material concentration (notDivided) (arb units um^-1)'
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,not(isDivided)));
        case 'old material integrated (isDivided) (arb units)'
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            tempData = tempData1.*tempData2;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
        case 'old material concentration (isDivided) (arb units um^-1)'
            desiredField = 'side2IntegratedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData1 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'backSubtractedGreen';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData2 = aggCellsReshaped(:,desiredFieldIDX);
            
            desiredField = 'arcLength2';
            desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
            tempData3 = aggCellsReshaped(:,desiredFieldIDX)*0.13;
            
            tempData = tempData1.*tempData2./tempData3;
            tempData = tempData(and(dataSetIDX==ii,(isDivided)));
            
    end
    
    if numel(tempData)<10;
        tempData = nan;
    end
    try
        switch truncateStraight
            case 'removeStraight-WT'
                
                desiredField = 'radiusOfCurvature_perPix';
                desiredFieldIDX = strcmp(desiredField,fieldNamesAgg);
                tempData1 = aggCellsReshaped(:,desiredFieldIDX)';
                curvature_perMicron = (1./tempData1)/.13;
                
                if ~isempty(strfind(caseLabel,'isDivided'))
                    curvature_perMicron = curvature_perMicron(and(dataSetIDX==ii,(isDivided)));
                elseif ~isempty(strfind(caseLabel,'notDivided'))
                    curvature_perMicron = curvature_perMicron(and(dataSetIDX==ii,(~isDivided)));
                    
                end
                
                if ii>4
                    tempData(curvature_perMicron<CURVATURE_THRESH) = [];
                end
        end
        
        switch centralTendency
            case 'median'
                results(ii,4) = nanmedian((tempData(:)'));
                aa = bootci(2000,{@nanmedian,(tempData(:)')},'alpha',ALPHA_VAL);
                
                results(ii,5:6) = aa(:);
            case 'mean'
                results(ii,4) = nanmean((tempData(:)'));
                aa = bootci(2000,{@nanmean,(tempData(:)')},'alpha',ALPHA_VAL);
                
                results(ii,5:6) = aa(:);
        end
        
    catch
        results(ii,4:6) = nan;
        
    end
end


switch samePlots
    case 'two plots'
        subplot(1,2,1);
end

% start with offsetting the outer face metrics by half a minute to the left

errorbar(timeLabels,results(1:4,1),...
    results(1:4,2)-results(1:4,1),...
    results(1:4,3)-results(1:4,1),'rx','displayName','dCrvA-out');

switch samePlots
    case 'two plots'
        
        subplot(1,2,2);
end
errorbar(timeLabels,results(5:8,1),...
    results(5:8,2)-results(5:8,1),...
    results(5:8,3)-results(5:8,1),'bx','displayName','WT-out');
switch samePlots
    case 'two plots'
        
        subplot(1,2,1);
end
errorbar(timeLabels,results(1:4,4),...
    results(1:4,5)-results(1:4,4),...
    results(1:4,6)-results(1:4,4),'rs','displayName','dCrvA-in');
switch samePlots
    case 'two plots'
        
        subplot(1,2,2);
end
errorbar(timeLabels,results(5:8,4),...
    results(5:8,5)-results(5:8,4),...
    results(5:8,6)-results(5:8,4),'bs','displayName','WT-in');

% fit the data to a line
[xData_dCrvA_out, yData_dCrvA_out, weights_dCrvA_out] = prepareCurveData( timeLabels', results(1:4,1), 1./diff(results(1:4,2:3),1,2)/2);
[xData_dCrvA_in, yData_dCrvA_in, weights_dCrvA_in] = prepareCurveData( timeLabels', results(1:4,4), 1./diff(results(1:4,5:6),1,2)/2);
[xData_WT_out, yData_WT_out, weights_WT_out] = prepareCurveData( timeLabels', results(5:8,1), 1./diff(results(5:8,2:3),1,2)/2);
[xData_WT_in, yData_WT_in, weights_WT_in] = prepareCurveData( timeLabels', results(5:8,4), 1./diff(results(5:8,5:6),1,2)/2);
% Set up fittype and options.
try
    ft = fittype( 'poly1' );
    opts_dCrvA_out = fitoptions( 'Method', 'LinearLeastSquares' );
    opts_dCrvA_out.Weights = weights_dCrvA_out;
    
    opts_dCrvA_in = fitoptions( 'Method', 'LinearLeastSquares' );
    opts_dCrvA_in.Weights = weights_dCrvA_in;
    
    opts_WT_out = fitoptions( 'Method', 'LinearLeastSquares' );
    opts_WT_out.Weights = weights_WT_out;
    
    opts_WT_in = fitoptions( 'Method', 'LinearLeastSquares' );
    opts_WT_in.Weights = weights_WT_in;
    
    
    
    
    % Fit model to data.
    [fitresult_dCrvA_out, gof_dCrvA_out] = fit(xData_dCrvA_out, yData_dCrvA_out, ft, opts_dCrvA_out );
    [fitresult_WT_out, gof_WT_out] = fit( xData_WT_out, yData_WT_out, ft, opts_WT_out );
    
    dCrvA_out_params = confint(fitresult_dCrvA_out,1-ALPHA_VAL);
    disp(['Slope for dCrvA_out: ', num2str(dCrvA_out_params(:,1)')]);
    disp(['Best slope: ',num2str(fitresult_dCrvA_out.p1)]);
    switch samePlots
        case 'two plots'
            
            subplot(1,2,1);
    end
    plot(xlim,fitresult_dCrvA_out(xlim),'r','DisplayName','dCrvA-out');
    
    
catch ME
end
try
    [fitresult_dCrvA_in,  gof_dCrvA_in] = fit( xData_dCrvA_in, yData_dCrvA_in, ft, opts_dCrvA_in );
    [fitresult_WT_in,  gof_WT_in] = fit( xData_WT_in, yData_WT_in, ft, opts_WT_in );
    dCrvA_in_params = confint(fitresult_dCrvA_in,1-ALPHA_VAL);
    disp(['Slope for dCrvA_in: ', num2str(dCrvA_in_params(:,1)')]);
    disp(['Best slope: ',num2str(fitresult_dCrvA_in.p1)]);
    
    plot(xlim,fitresult_dCrvA_in(xlim),'r:','DisplayName','dCrvA-in');
    
catch ME
    fitresult_WT_in = [];
    fitresult_dCrvA_in = [];
end
try
    
    
    WT_out_params = confint(fitresult_WT_out,1-ALPHA_VAL);
    disp(['Slope for WT_out: ', num2str(WT_out_params(:,1)')]);
    disp(['Best slope: ',num2str(fitresult_WT_out.p1)]);
    switch samePlots
        case 'two plots'
            
            subplot(1,2,2);
    end
    plot(xlim,fitresult_WT_out(xlim),'b','DisplayName','WT-out');
    
    WT_in_params = confint(fitresult_WT_in,1-ALPHA_VAL);
    disp(['Slope for WT_in: ', num2str(WT_in_params(:,1)')]);
    disp(['Best slope: ',num2str(fitresult_WT_in.p1)]);
    
    plot(xlim,fitresult_WT_in(xlim),'b:','DisplayName','WT-in');
catch ME
end
switch samePlots
    case 'two plots'
        
        subplot(1,2,1);
end
title(['deltaCrvA : ',centralTendency]);
switch samePlots
    case 'two plots'
        subplot(1,2,2);
end
title(['WT  : ',centralTendency,' : ', truncateStraight]);
