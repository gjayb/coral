function [params, times] = setparams(reefChoice, years)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
switch reefChoice
    case 1 %Presidio
        params.fU0 = 0; 
        params.fH0 = 1.8; 
        params.fD0 = 96.4; 
        params.fS0 = 0; 
        params.fJ20 = 1.8; 
        params.fJ10 = 0;% Presidio  %% 
        params.hJ20 = 1.5;%0.1; %1.5
        params.hJ10 = 0;
        params.hH0 = 1.5; 
        params.hU0 = 1.5; 
        params.hD0 = 1.5;%1.5m average reef "thickness"
        
        params.reproduction = 0.017;%Presidio 0.017 %avg 0.008
        params.recovery = 0.00048;
        params.phi = 3.93; %presidio 3.93 %shape factor phi = width/height %0.1-5
        params.rH = 0.000182885; %0.000183; %presidio %linear extension rate in m/yr - 0.000183
        params.mH = 0.00271; %Presidio 0.00271 % 0.000385-0.00385; avg 0.001346
        %params.dr = 0.0;%m/wk radius growth
        params.gaJ = 0.081; %0.02-0.1 frac/wk avg 0.06
        params.mJ = 0.0122; %0.0188;   % 0 - 0.0192 (0-100%) 80% mortality -> 0.0188, 
        params.mU = 0.011;
        params.waterdepth = 16.1;
        params.area = 720;
        params.Imean = 43; %43
        params.Iamp = 9; %9
        params.Ik = 75; %275
        params.Kd = 0.05;  % Usually 0.14-0.51 coastal


    case 2 %Pacheco
        params.fU0 = 0; 
        params.fH0 = 1.12; 
        params.fD0 = 97.2; 
        params.fS0 = 0;
        params.fJ20 = 1.68; 
        params.fJ10 = 0; 
        params.hJ20 = 1.5; %0.1; 
        params.hJ10 = 0; 
        params.hH0 = 1.5; 
        params.hU0 = 1.5; 
        params.hD0 = 1.5;%1.5m average reef "thickness"
        
        params.recovery = 0.00048;
        params.reproduction = 0.028;%Pacheco 0.028
        params.phi = 1.49; %shape factor phi = width/height %0.1-5
        params.rH = 0.000213654;%0.000213654; %0.0005; 
        params.gaJ = 0.063; %0.083;
        params.mH = 0.00361; %0.003613;
        %params.dr = 0.00000659;%m/wk radius growth
        params.mU = 0.011;
        params.mJ = 0.0185; %0.005;%0.018;%0.0191;   % 0 - 0.0192 (0-100%) 80% mortality -> 0.0188, 
       
        params.Imean = 43; 
        params.Iamp = 9; 
        params.Ik = 75; 
        params.waterdepth = 8.7;
        params.Kd = 0.05;  % Usually 0.14-0.51 coastal
        params.area = 1470;

    case 3 %Chatham
        params.fU0 = 0; 
        params.fH0 = 0.8125; 
        params.fD0 = 96.75;
        params.fS0 = 0;
        params.fJ20 = 2.4375;
        params.fJ10 = 0; 

        params.hJ20 = 1.5; %0.1;
        params.hJ10 = 0; 
        params.hH0 = 1.5; 
        params.hU0 = 1.5; 
        params.hD0 = 1.5;%1.5m average reef "thickness"

        params.recovery = 0.00048;
        params.reproduction = 0.01021;%0.008 %Chatham 0.01021
        params.phi = 3.07;  %shape factor phi = width/height %0.1-5
        params.rH = 0.000324808; %Chatham 0.000324808
        params.gaJ = 0.0685; %0.06
        params.mH = 0.001346; 
        %params.dr = 0.00000659;%m/wk radius growth
       
        params.mU = 0.011;
        params.mJ = 0.0153; %0.0165; %0.0191;   % 0 - 0.0192. 80% mortality -> 0.0188
        
        params.Imean = 43; %
        params.Iamp = 9; %
        params.Ik = 75; %
        params.waterdepth = 11;
        params.Kd = 0.05;  % Usually 0.14-0.51 coastal
        params.area = 800;

    case 4 %Rangiroa Atoll - Porites
        params.fU0 = 26.31; 
        params.fH0 = 29.98; 
        params.fD0 = 4.95287; 
        params.fS0 = 38.75;
        params.fJ20 = 0;
        params.fJ10 = 0;   
        params.hJ20 = 2.86;%0; 
        params.hJ10 = 0; 
        params.hH0 = 2.86; %2.860523044; %2.86; 
        params.hU0 = 2.86; %2.860523044; %2.86; 
        params.hD0 = 2.86; %2.860523044; %2.86;%2.86m derived from avg width and shape factor 
        
        params.recovery = 0.00048; %0.00048;
        params.reproduction = 0.0014; %0.0014;%0.02;%Porites 0.02
        params.phi = 0.95; % %shape factor phi = width/height %0.1-5
        params.rH = 0.000221154;
        params.gaJ = 0.0835; %0.06 avg;
        params.mH = 0.001346; % just the avg
        %params.dr = 0.00000659;%m/wk radius growth
        
        params.mU = 0.011; 
        params.mJ = 0.012; %0.0188;   % 0 - 0.0192. 80% mortality -> 0.0188
        
        params.Imean = 44.5; %44.5;%43; %
        params.Iamp = 7.5; %7.5;%9; %
        params.Ik = 75; %
        params.waterdepth = 8;
        params.Kd = 0.1; %0.1;%0.05;  % Usually 0.14-0.51 coastal
        params.area = 100000;

end

%NEW
params.rD = 0.0001; %0.0000038-0.001173mm/wk

params.restrHuman = 0;     % no human interference
params.disease = 0;              % no disease
params.spawnweek = 15; 
params.maturityYears = 3;  % 1-10 %3-4.5 is most common
params.minheight = 0.0001; % not sensitive
params.stormProb = 0;      % 0.01;
params.stormDestroy = 0;   % 0-0.3 %0.16 %destruction from storm
params.Tcritical = 40;     % set this high to avoid bleaching
params.gslopeDegrees = 2;  % 2 degrees of warming leads to full bleaching


params.U0 = (params.fU0./100) .* params.area;
params.H0 = (params.fH0./100) .* params.area; 
params.D0 = (params.fD0./100) .* params.area;
params.J10 = (params.fJ10./100) .* params.area;
params.S0 = (params.fS0./100) .* params.area; 
params.J20 = (params.fJ20./100) .* params.area;  


params.Ttrend = 0;
params.years=years;
times = 0:1/52:params.years;

end