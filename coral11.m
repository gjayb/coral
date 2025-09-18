 function [areas,heights] = coral11(params)
%coral11 is a model of coral population dynamics
%   J is juvenile coral fraction
%   H is healthy adult coral fraction on your patch
%   U is unhealthy (non-reproductive) coral fraction
%   D is dead coral
%   S is substrate
%   U+H+D+S+J=constant=U0+H0+D0+S0+J0
%   dt=weeks
%   hX is the height for category X, and hS=0
%   rates are in area increase/decrease per week
%   e.g. r2, restoration by humans, increases H by r2 each week
%   so if the whole patch was dead/substrate, and refilled with baby corals
%   in 1 year of work, r2=1/52 (need to check this dynamic)
%   EXCEPT: b and r1 only occur 1x/year, on bleachweek and spawnweek
%   Note: bleached/diseased juveniles die imediately, do not enter U
%   m1, m2 are predation in area; g0 is exponential area growth of J
%   restrHuman is m^2/wk outplanted over substrate or dead coral (substrate
%   first)
reproduction = params.reproduction; %reproduction
spawnweek = params.spawnweek; %note: this is 1x/year! like an annual spawning
maturityYears = params.maturityYears;
restrHuman = params.restrHuman; %restoration by humans, area addressed per wk
%dr = params.dr; % juvenile area growth, m/wk
%linear extension rate for adults, and a shape parameter [0.1-5, mostly 1-2]
rH = params.rH; %adult linear growth rate
phiH = params.phi; %adult shape parameter, width/height
%%!!! fixed from sin to sind!!!
ghH=rH*sind(atand(2/(phiH))); % adult height growth, m/wk
%gaH = params.gaH; % adult area growth, m^2/wk
gslopeDegrees=params.gslopeDegrees; %growth sensitivity to excess temperature,degrees C from Tcritical to 0 growth
% note thermal stress sensitivity is stronger for branching than
% bouldering, so this value will be smaller for branching. Note in paper
% that this is getting around building an internal temperature vs ocean
% temperature function.
Tcritical=params.Tcritical; %max temperature before growth decreases, degrees C
Ik=params.Ik; %slope of growth-light curve at origin
waterdepth=params.waterdepth;%depth of the water in m
Kd=params.Kd;%light attenuation, per meter
disease = params.disease;%disease rate, fraction of H->U per wk
recovery = params.recovery;%recovery rate
minheight=params.minheight;%minimum coral height of H and U
mJ = params.mJ; % Juvenile linear mortality, expect 96-99% mortality in 4 months-1yr
mH = params.mH;%mortality of H via predation
mU = params.mU;%mortality of U
rD = abs(params.rD);%shrinking of D, m/wk, linear shrinking rate with shape factor
ghD=rD*sind(atand(2/(phiH))); %shrinking of D, m/wk, height
stormProb=params.stormProb; %probability of storm per year, roll for each year, assign week for each positive, timeseries
stormDestroy=params.stormDestroy; %fraction of area of standing coral that is removed per storm
gmaxJ1=params.gaJ;
gmaxJ2=params.gaJ;
years = params.years;%simulation length
dt=1; %week
timesteps=years*52/dt; %total number of timesteps

stormSeries=double(rand(timesteps+1,1)<=stormProb);

if length(waterdepth)==1 %waterdepth should either be constant or timesteps+1 long
    waterdepth=ones(1,timesteps+1)*waterdepth;
elseif length(waterdepth)<timesteps  %%% is this needed? should it just throw an error?
    disp('waterdepth extended at final value')
    hold1=waterdepth; 
    waterdepth(length(hold1):timesteps+1)=hold1(end);
end

%initialize output variables
areas.H=nan(1,timesteps+1); 
areas.J1=areas.H; 
areas.U=areas.H; 
areas.D=areas.H; 
areas.S=areas.H; 
areas.J2=areas.H;
heights.hJ1=areas.H; 
heights.hU=areas.H; 
heights.hD=areas.H; 
heights.hH=areas.H; 
heights.hJ2=areas.H;

%initialize areas
areas.H(1)=params.H0;
areas.U(1)=params.U0;
areas.D(1)=params.D0;
areas.S(1)=params.S0;
areas.J1(1)=params.J10;%on bottom
areas.J2(1)=params.J20;%on dead

%initialize heights, but set them to 0 if the associated area is 0
heights.hH(1)=params.hH0*double(params.H0>0); 
heights.hU(1)=params.hU0*double(params.U0>0); 
heights.hD(1)=params.hD0*double(params.D0>0); 
heights.hJ1(1)=params.hJ10*double(params.J10>0); %bottom
heights.hJ2(1)=params.hD0*double(params.J20>0); %on dead

totalArea=params.H0+params.U0+params.J10+params.J20+params.D0+params.S0;
if totalArea<=0
    disp('incorrect initial conditions, area>0 required')
end

%new juvenile count
njuv1=areas.J1(1)./0.000003;%assume average juvenile size 3mm2 (range 1-5mm2)
njuv2=areas.J2(1)./0.000003;

%T, temperature, and I, light
%%% Ttrend is degrees/week
times=0:1/52:years;
Isurf=params.Imean+params.Iamp*sin((times+1/52)*2*pi);
%%% note: 2 options for setting temperatures
   %Tsurf=params.Tmean+params.Tamp*sin((times-6/52)*2*pi)+params.Ttrend*times;
    Tsurf=params.Tsurf;
     if length(Tsurf)<timesteps
         disp('Tsurf extended at final value')
         hold1=Tsurf; 
         Tsurf(length(hold1):timesteps+1)=hold1(end);
     end


firstHgone=false;
firstJgone=false;

for ii=1:timesteps
    
    % XYflux is an area
    HUflux=disease*areas.H(ii); %disease, units [fraction of healthy falling ill]/time
    %%% no juvenile d, wrapped into mortality 
   
    J2Dflux=mJ*areas.J2(ii);
    J1Sflux=mJ*areas.J1(ii); %storms do not affect zero-height coral
    J2Sflux=stormDestroy*stormSeries(ii)*areas.J2(ii);

    USflux=stormDestroy*stormSeries(ii)*areas.U(ii);
    HSflux=stormDestroy*stormSeries(ii)*areas.H(ii);
   
    HDflux=min(mH*areas.H(ii),areas.H(ii)-HUflux); %predation is just
    % part of a total mortality, can be expanded in future work. 

    SHflux=min(restrHuman,areas.S(ii));%human restoration
    if SHflux<restrHuman
        DHflux=min(restrHuman-SHflux,areas.D(ii));%human restoration
    else
        DHflux=0;
        disp('restoring on dead')
    end


    UDflux=mU*areas.U(ii);%linear form now
    gaD=abs((((heights.hD(ii)*phiH/2)-rD*cos(atan(2/phiH)))^2/(heights.hD(ii)*phiH/2)^2) -1)*dt;
    DSflux=gaD*areas.D(ii)+stormDestroy*stormSeries(ii)*areas.D(ii);%dissolution/physical damage

    % growth and bleaching for H
    Inow=Isurf(ii)*exp(-(waterdepth(ii)-heights.hH(ii))*Kd);
    Inow1=Isurf(ii)*exp(-waterdepth(ii)*Kd);
    Inow2=Isurf(ii)*exp(-(waterdepth(ii)-heights.hJ2(ii))*Kd);

    gaH=((((heights.hH(ii)*phiH/2)+rH*cos(atan(2/phiH)))^2/(heights.hH(ii)*phiH/2)^2) -1)*dt; 

    if Tsurf(ii)>Tcritical %bleaching possible
        gHmaxNow=max(0,ghH*(1-(Tsurf(ii)-Tcritical)/gslopeDegrees)); %gslopeDegrees is thermal stress parameter, Tmax-Tcritical
        gAmaxNow=max(0,gaH*(1-(Tsurf(ii)-Tcritical)/gslopeDegrees));
        %%% no temperature stratification currently
        if gHmaxNow==0 || gAmaxNow==0
            Ieff=0; %how much of light available is used for growth
            ghHnow=0;
            gaHnow=0;
        else
            ghHnow=max(0,gHmaxNow*tanh(Inow/Ik));%must be non-negative
            gaHnow=max(0,gAmaxNow*tanh(Inow/Ik));%must be non-negative
            Ieff=Ik*atanh(ghHnow/ghH); %how much of light available is used for growth
        end
        if Inow>Ieff
            bH=1-exp(1-(Inow-Ieff)/Ik);
            if bH>0 
                %disp('bleach')
                HUflux=min(HUflux+bH*areas.H(ii),areas.H(ii));%can't move more than total amount
                UHflux=0;
            else
                UHflux=recovery*areas.U(ii);
                % under thermal stress, has excess light, but not
                % bleaching, so can recover
            end
        else
            UHflux=recovery*areas.U(ii);
            % under thermal stress, but no excess light, can recover
        end

        % growth for J
        gNowJ1=max(0,gmaxJ1*(1-(Tsurf(ii)-Tcritical)/gslopeDegrees));%no growth when bleaching temps
        gNowJ2=max(0,gmaxJ2*(1-(Tsurf(ii)-Tcritical)/gslopeDegrees));

        if gNowJ1==0
          %  Ieff1=0; Ieff2=0;
            gNowJ1=0; gNowJ2=0;
        else
            gNowJ1=max(0,gmaxJ1*tanh(Inow1/Ik));
            gNowJ2=max(0,gmaxJ2*tanh(Inow2/Ik));
           % Ieff1=Ik*atanh(gNowJ1/gaJ);
           % Ieff2=Ik*atanh(gNowJ2/gaJ);
        end
    else
        gNowJ1=max(0,gmaxJ1*tanh(Inow1/Ik));
        gNowJ2=max(0,gmaxJ2*tanh(Inow2/Ik));
        ghHnow=max(0,ghH*tanh(Inow/Ik));
        gaHnow=max(0,gaH*tanh(Inow/Ik));
        UHflux=recovery*areas.U(ii); %no thermal stress = can recover too
    end


    DHflux=min(DHflux+gaHnow*areas.H(ii)*(areas.D(ii)/(areas.D(ii)+areas.S(ii))),areas.D(ii));%added this term
    SHflux=min(SHflux+gaHnow*areas.H(ii)*(areas.S(ii)/(areas.D(ii)+areas.S(ii))),areas.S(ii));%area growth 
    
    SJ1flux=min(gNowJ1.*areas.J1(ii),areas.S(ii)-SHflux);%growth of juveniles on S 
    DJ2flux=min(gNowJ2.*areas.J2(ii),areas.D(ii)-DHflux);%growth of juveniles on D
    
    if mod(ii-spawnweek,52)==0 
        if areas.H(ii)>1e-10 %floating point limits
        DJ2flux=min(areas.D(ii)-DHflux,DJ2flux+reproduction*areas.H(ii)*areas.D(ii)/(areas.D(ii)+areas.S(ii)));
        SJ1flux=min(areas.S(ii)-SHflux,SJ1flux+reproduction*areas.H(ii)*areas.S(ii)/(areas.D(ii)+areas.S(ii)));
        end
        J1Hflux=areas.J1(ii)./maturityYears;%J to H
        J2Hflux=areas.J2(ii)./maturityYears;
       
        %update number of juveniles %assume 1mm2 size of newly settled juvenile
        njuv1=njuv1*(1-1/maturityYears)+reproduction*areas.H(ii)*(areas.S(ii)./(areas.S(ii)+areas.D(ii)))./0.000001;
        njuv2=njuv2*(1-1/maturityYears)+reproduction*areas.H(ii)*(areas.D(ii)./(areas.S(ii)+areas.D(ii)))./0.000001;
    else
        J1Hflux=0; J2Hflux=0;
    end
   
    %area changes, using the fluxes above
    areas.J1(ii+1)=areas.J1(ii)+(SJ1flux-J1Sflux-J1Hflux)*dt;
    areas.J2(ii+1)=areas.J2(ii)+(DJ2flux-J2Dflux-J2Hflux-J2Sflux)*dt;
    areas.H(ii+1)=areas.H(ii)+(J1Hflux+J2Hflux+UHflux+SHflux+DHflux...
        -HUflux-HDflux-HSflux)*dt;
    areas.U(ii+1)=areas.U(ii)+(HUflux-UDflux-UHflux-USflux)*dt;
    areas.D(ii+1)=areas.D(ii)+(UDflux+HDflux+J2Dflux-DSflux-DHflux-DJ2flux)*dt;
    areas.S(ii+1)=areas.S(ii)+(-SHflux+DSflux-SJ1flux+J1Sflux+USflux+HSflux+J2Sflux)*dt;
    if areas.H(ii+1)<1e-10 %floating point limits
        areas.U(ii+1)=areas.U(ii+1)+areas.H(ii+1);
        areas.H(ii+1)=0;
        if ~firstHgone
        disp(strcat(num2str(ii),', H gone'))
        firstHgone=true;
        end
    end
    if areas.J1(ii+1)<1e-10 %floating point limits
        areas.D(ii+1)=areas.D(ii+1)+areas.J1(ii+1);
        areas.J1(ii+1)=0;
        if ~firstJgone
        disp(strcat(num2str(ii),', J1 gone'))
        firstJgone=true;
        end
    end
    if areas.J2(ii+1)<1e-10 %floating point limits
        areas.D(ii+1)=areas.D(ii+1)+areas.J2(ii+1);
        areas.J2(ii+1)=0;
        if ~firstJgone
        disp(strcat(num2str(ii),', J2 gone'))
        firstJgone=true;
        end
    end
    if areas.S(ii+1)<0 %mistake
        areas.D(ii+1)=areas.D(ii+1)+areas.S(ii+1);
        areas.S(ii+1)=0;
    end
    if areas.U(ii+1)<0 %mistake
    areas.D(ii+1)=areas.D(ii+1)+areas.U(ii+1);
    areas.U(ii+1)=0;
    end


    %height changes, using the fluxes above
    heights.hJ1(ii+1)=0; %always zero
    if areas.J2(ii+1)>0  
        heights.hJ2(ii+1)=(heights.hJ2(ii)*areas.J2(ii)...
            +heights.hJ2(ii)*(-J2Dflux-J2Hflux)*dt+heights.hD(ii)*DJ2flux*dt)...
            /areas.J2(ii+1);
        heights.hJ2(ii+1)=min(heights.hJ2(ii+1),waterdepth(ii)); %max height allowed
    else
        heights.hJ2(ii+1)=0;%0 height for 0 area
        areas.J2(ii+1)=0;%no negative areas
    end
    if areas.H(ii+1)>0 
        heights.hH(ii+1)=((heights.hH(ii)+ghHnow*dt)*areas.H(ii)...
            +heights.hH(ii)*(-HUflux-HDflux+SHflux+DHflux)*dt+heights.hJ2(ii)*J2Hflux*dt+...
            heights.hU(ii)*UHflux*dt)/areas.H(ii+1);
        % double check ghHnow is per week, so don't need dt?
        % note height of J1 is 0, so J1Hflux doesn't appear.

        heights.hH(ii+1)=min(heights.hH(ii+1),waterdepth(ii)); %max height allowed
        if heights.hH(ii+1)<minheight
            heights.hH(ii+1)=minheight; %minimum height allowed
        end
    else
        heights.hH(ii+1)=0;%0 height for 0 area
        areas.H(ii+1)=0;%no negative areas
    end
    if areas.U(ii+1)>0
        heights.hU(ii+1)=(heights.hU(ii)*areas.U(ii)+heights.hU(ii)*(-UDflux-UHflux)*dt...
            +heights.hH(ii)*HUflux*dt)/areas.U(ii+1);
        heights.hU(ii+1)=min(heights.hU(ii+1),waterdepth(ii)); %max height allowed
        if heights.hU(ii+1)<minheight
            heights.hU(ii+1)=minheight; %minimum height allowed
        end
    else
        heights.hU(ii+1)=0;
        areas.U(ii+1)=0;
    end
    if areas.D(ii+1)>0
        heights.hD(ii+1)=((heights.hD(ii)-ghD*dt)*areas.D(ii)+...
            heights.hD(ii)*(-DSflux-DHflux-DJ2flux)*dt+...
            heights.hU(ii)*UDflux*dt+heights.hH(ii)*HDflux*dt+...
            heights.hJ2(ii)*J2Dflux*dt)/areas.D(ii+1);
         %took out -minheight*DSflux
       heights.hD(ii+1)=min(heights.hD(ii+1),waterdepth(ii)); %max height allowed
       if heights.hD(ii+1)<0
          heights.hD(ii+1)=0; %minimum height allowed
       end
    else
        heights.hD(ii+1)=0;
        areas.D(ii+1)=0;
    end
 end




end
