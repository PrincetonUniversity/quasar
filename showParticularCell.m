%%
% listOfXor = find(xor(sidesSwapped_default2arcLength,sidesSwapped_default2centerlinePointing));
listOfXor = find(sidesSwapped_default2centerlinePointing);
%%
ii = 5148;
% display contour and centerlines for a specific cell;
figure(gcf);
clf;
centerLineTemp = aggCells((ii)).centerline;
clear r0 x0 y0 resnorm
for jj = 1:1
    [r0(jj,1),x0(jj,1),y0(jj,1),resnorm(jj,1)] = bestFitCircle(centerLineTemp(:,1),centerLineTemp(:,2));
end
%
[resnorm,minJJ] = min(resnorm);
x0 = x0(minJJ);
y0 = y0(minJJ);
r0 = r0(minJJ);
contourTempX = aggCells((ii)).Xcont;
contourTempY = aggCells((ii)).Ycont;
path1 = aggCells((ii)).path1;
path2 = aggCells((ii)).path2;

distPath1ToCenter = sqrt(mean((contourTempX(path1)-x0).^2+(contourTempY(path1)-y0).^2))
distPath2ToCenter = sqrt(mean((contourTempX(path2)-x0).^2+(contourTempY(path2)-y0).^2))

hold on;
scatter(contourTempX(path1),contourTempY(path1),'rx');
scatter(contourTempX(path2),contourTempY(path2),'rs');
scatter(centerLineTemp(:,1),centerLineTemp(:,2),'b*');

axis equal

xlimits = xlim();
extraSpace = 15;
xlimits(1) = xlimits(1)-extraSpace;
xlimits(2) = xlimits(2)+extraSpace;

ylimits = ylim();
ylimits(1) = ylimits(1)-extraSpace;
ylimits(2) = ylimits(2)+extraSpace;

x2 = linspace(xlimits(1),xlimits(2),50);
y2a = sqrt(r0^2-(x2-x0).^2)+y0;
y2b = -sqrt(r0^2-(x2-x0).^2)+y0;

plot(x2,y2a,'g-');
plot(x2,y2b,'g-');
xlim(xlimits);
ylim(ylimits);
figure(gcf);
title(['squares inner : cell #', num2str(ii),...
    ' : arcLength swap? ',num2str(double(sidesSwapped_default2arcLength(ii))),...
    ' : centerOfCircle swap? ',num2str(double(sidesSwapped_default2centerlinePointing(ii))),...
    ' : radius (pix) ',num2str(r0)]);
