function [r,x0,y0,resnorm] = bestFitCircle(X,Y,opts1);

%%

if nargin<3
opts1=  optimset('display','off',...
    'TolX',1e-6,'TolFun',1e-8,...
    'Algorithm','levenberg-marquardt');
else
    opts1 = opts1;
end

func1 = @(z) sqrt((X-z(1)).^2+(Y-z(2)).^2)-z(3);
%%

%%
 startWith3 = randperm(length(X),3);
    [startR,x0,y0] = circleFrom3Pts(X(startWith3),Y(startWith3));
    x0 = mean(X);
    y0 = mean(Y);
    
for ii = 1:6;
   startX = x0+2*startR*cos(ii*pi/3);
   startY = y0+2*startR*sin(ii*pi/3);
    
[results(ii,1:3),resnorm(ii,:)] = lsqnonlin(func1,[startX,startY,startR],[],[],opts1);
results(ii,4:6) = [startX,startY,startR];
end

[resnorm,minII] = min(resnorm);
results = results(minII,1:3);

    


 %%
%  xLimits = xlim();
%  x2 = xLimits(1):xLimits(2);
%  y2 = -sqrt(results(3).^2-(x2-results(1)).^2)+results(2);
%  scatter(x2,y2,'k*')
 r = results(3);
 x0 = results(1);
 y0 = results(2);