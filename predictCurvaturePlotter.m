% plot centerline curvature prediction
d = 0.6;

% 19.5 min
r0_WT = 1/((0.3046+.3503)/2);
r0_crvA = 1/((0.06605+.06294)/2);
t0 = 19.5;


% 30 min
r0_WT = 1/((0.3936));
r0_crvA = 1/0.058;
t0 = 30;


% 6 min
r0_WT = 1/((0.286));
r0_crvA = 1/0.06;
t0 = 6;


t = linspace(1,35,100);

% ratio of arc lengths
Y_0_WT = (r0_WT+d/2)/(r0_WT-d/2);
Y_0_crvA = (r0_crvA+d/2)/(r0_crvA-d/2);

% time constants for wt
wt_insertion_out_min = 23.3;
wt_insertion_in_min = 25.3;
% wt_degradation_out_min = 18.4043;
% wt_degradation_out_min = 0.1;

wt_degradation_in_min = 1;
wt_degradation_out_min = 1;

% wt_degradation_in_min = 21.1049;
% wt_degradation_in_min = 0.1;

dcrva_insertion_out_min = 33.7;
dcrva_insertion_in_min = 33.5 ;
% dcrva_degradation_out_min = 22.0999;
% dcrva_degradation_in_min = 24.1591;
dcrva_degradation_in_min = 1;
dcrva_degradation_out_min = 1;
  
wtDiffAlpha = (1/wt_insertion_out_min - 1/wt_insertion_in_min)+...
    (-1/wt_degradation_out_min + 1/wt_degradation_in_min);
%
dcrvaDiffAlpha = (1/dcrva_insertion_out_min - 1/dcrva_insertion_in_min)+...
    (-1/dcrva_degradation_out_min + 1/dcrva_degradation_in_min);


zScore = -1.6; % 1.3 for 80% 1.6 for 90% 2 for 95%
wtDiffAlpha = wtDiffAlpha + zScore*0.0011;
dcrvaDiffAlpha = dcrvaDiffAlpha + zScore*6.6e-4;


% wtDiffAlpha = (1/11.7155)-(1/12.3868);
% R_T_crvA = (d/2).*(Y_0_crvA*exp((+1/14.8643-1/14.9505).*(t-t0))+1)./((Y_0_crvA*exp((+1/14.8643-1/14.9505).*(t-t0))-1));
R_T_crvA = (d/2).*(Y_0_crvA*exp(dcrvaDiffAlpha.*(t-t0))+1)./(Y_0_crvA*exp(dcrvaDiffAlpha.*(t-t0))-1);
R_T_WT = (d/2).*(Y_0_WT*exp(wtDiffAlpha.*(t-t0))+1)./(Y_0_WT*exp(wtDiffAlpha.*(t-t0))-1);

%clf;
plot(t,1./R_T_crvA,'g');
hold on;
plot(t,1./R_T_WT,'y');

%ylim([0.05,0.55]);
%xlim([1,35]);
