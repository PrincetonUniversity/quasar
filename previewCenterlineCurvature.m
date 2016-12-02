figure(gcf);
clf; hold on;
ii = randperm(3964,1);
PIX_SIZE = 0.13;
[r,x0,y0] = bestFitCircle(aggCells(ii).centerline(:,1)*PIX_SIZE,aggCells(ii).centerline(:,2)*PIX_SIZE);
% scatter(aggCells(ii).Xcent_cont*PIX_SIZE,aggCells(ii).Ycent_cont*PIX_SIZE);
scatter(aggCells(ii).centerline(:,1)*PIX_SIZE,aggCells(ii).centerline(:,2)*PIX_SIZE,70,(1./(aggCells(ii).cent_kappa))*PIX_SIZE);
scatter(aggCells(ii).Xcont*PIX_SIZE,aggCells(ii).Ycont*PIX_SIZE,'bo');
axis equal;
xlimits = xlim();
ylimits = ylim();
x2 = linspace(xlimits(1),xlimits(2),50);
kap1 = aggCells(ii).cent_kappa;
kap1(1:3) = [];
kap1(end-2:end) = [];

title([num2str(aggCells(ii).radiusOfCurvature_perPix*PIX_SIZE),...
    '  ',num2str(sqrt(mean((1./kap1).^2))*PIX_SIZE)]);



y2a = sqrt(r^2-(x2-x0).^2)+y0;
y2b = -sqrt(r^2-(x2-x0).^2)+y0;


plot(x2,y2a,'g-');
plot(x2,y2b,'g-');
xlim(xlimits);
ylim(ylimits);