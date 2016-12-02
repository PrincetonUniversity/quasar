function [radius,xCent,yCent] = circleFrom3Pts(X,Y)

if or(length(X)~=3,length(Y)~=3)
   error('circleFrom3pts:lengthsNot3','Inputs ''X'' and ''Y'' should be of length 3'); 
end

% guess a circle from 3 pts

% find the centerpoint of one chord
chordA1Midpoint = [X(1)+X(2),Y(1)+Y(2)]/2;
chordB1Midpoint = [X(3)+X(2),Y(3)+Y(2)]/2;

chordA1Slope = (Y(2)-Y(1))./(X(2)-X(1));
chordB1Slope = (Y(2)-Y(3))./(X(2)-X(3));

chordA1Slope = -1./chordA1Slope;
chordB1Slope = -1./chordB1Slope;

chordA1Intercept = -chordA1Slope*chordA1Midpoint(1)+chordA1Midpoint(2);
chordB1Intercept = -chordB1Slope*chordB1Midpoint(1)+chordB1Midpoint(2);

xCent = (chordB1Intercept-chordA1Intercept)/(chordA1Slope-chordB1Slope);
yCent = chordA1Slope*xCent+chordA1Intercept;

radius = sqrt((X(1)-xCent).^2+(Y(1)-yCent).^2);

% display the points, their chords, intersections and final circle
% clf;
% scatter(X,Y,65,'kx');
% axis equal
% hold on;
% plot(X(randIndx(1:2)),Y(randIndx(1:2)),'r');
% plot(X(randIndx(2:3)),Y(randIndx(2:3)),'b');
% scatter(chordA1Midpoint(1),chordA1Midpoint(2),'rx');
% scatter(chordB1Midpoint(1),chordB1Midpoint(2),'bx');
% scatter(xCent,yCent,65,'mx');
% 
% xlimits = xlim;
% xVals = linspace(xlimits(1),xlimits(2),100);
% yVals1 = yCent + sqrt(radius^2-(xVals-xCent).^2);
% yVals2 = yCent - sqrt(radius^2-(xVals-xCent).^2);
% 
% plot(xlimits,chordA1Intercept+chordA1Slope*xlimits,'r:');
% plot(xlimits,chordB1Intercept+chordB1Slope*xlimits,'b:');
% plot(xVals,yVals1,'m--');
% plot(xVals,yVals2,'m--');
% 
% 
% figure(gcf);

