% Simple example of running the coral model and plotting results
%   requires setparams and coral11

%1=Presidio 2=Pacheco 3=Chatham 4=Rangiroa atoll
reefChoice = 1;
years=15;
[params,times]=setparams(reefChoice,years);
params.Tmean=25;
params.Tamp=3;
params.Tsurf=params.Tmean+params.Tamp.*sin((times-6/52)*2*pi)+params.Ttrend*times;
[areas,heights] = coral11(params);

%% plot
FinalH_area=(areas.H./params.area).*100;
FinalU_area=(areas.U./params.area).*100;
FinalD_area=(areas.D./params.area).*100;
FinalS_area=(areas.S./params.area).*100;
FinalJ1_area=areas.J1./params.area.*100;
FinalJ2_area=areas.J2./params.area.*100;
FinalJ_area=FinalJ1_area+FinalJ2_area;
totalArea = FinalH_area+FinalJ_area+FinalU_area+FinalD_area+FinalS_area;
totalCoralArea=FinalH_area+FinalU_area+FinalJ_area+FinalD_area; 

figure; plot(times, FinalH_area, 'g', ...
             times, FinalJ_area, 'cyan', ...
             times, FinalU_area, ...
             times, FinalD_area, 'r', ...
             times, FinalS_area, 'k', ...
             times, totalCoralArea, 'k--', ...
             times, totalArea, 'k:')
legend('H','J','U','D','S','Total coral area','Total area')
ylabel('Area (%)')
xlabel('Time (years)') %~0.5 H, 0.4 D, 0.1S
xlim([0, params.years])
ylim([0, 105])

totalCoralHeight=(heights.hH.*FinalH_area+heights.hJ1.*FinalJ1_area+heights.hJ2.*FinalJ2_area+heights.hU.*FinalU_area+heights.hD.*FinalD_area)./totalCoralArea;
totalHeight=(heights.hH.*FinalH_area+heights.hJ1.*((areas.J1./params.area).*100)+heights.hJ2.*((areas.J2./params.area).*100)+heights.hU.*FinalU_area+heights.hD.*FinalD_area)./totalArea;
totalJHeight=(heights.hJ1.*FinalJ1_area+heights.hJ2.*FinalJ2_area)./(areas.J1+areas.J2);

figure; 
plot(times, heights.hH, 'g', ...
     times, totalJHeight, 'cyan', ...
     times, heights.hU, ...
     times, heights.hD, 'r', ...
     times, totalHeight, 'k--')
legend('H','J','U','D','Overall height')
ylabel('Coral height (m)')
xlabel('Time (years)') %
xlim([0, params.years])
ylim([0, 5])
