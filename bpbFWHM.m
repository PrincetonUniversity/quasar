function [fwhm,xPos] = bpbFWHM(x,y)
maxY = max(y);
minY = min(y);
cs1 = csaps(x,y-mean([minY,maxY]));
csZero = fnzeros(cs1);
fwhm = csZero(1,end)-csZero(1,1);
xPos = [csZero(1,1),csZero(1,end)];