%Treadmill behavioral analysis
%Jake Jordan / Gonçalves Lab www.goncalveslab.org
%May 26, 2021

clear all 

% open treadmill behavior file (.bin)
[file,path] = uigetfile('*.bin');
fid2 = fopen([path file],'r');
[data,count] = fread(fid2,[9,inf],'double');
fclose(fid2);

% plot running (red), licks (black) and pump (blue) to inspect session
plot(data(2,:))
hold on
plot(data(3,:),'r')
plot(data(9,:),'k')

%data from each input into the National Instruments hardware
pump = data(2,:);
movement = data(3,:);
textureone = data(4,:);
texturetwo = data(5,:);
texturethree = data(6,:);
texturefour = data(7,:);
reward = data(8,:);
licks = data(9,:);

sessionDurSec = (length(data(2,:))/1000); % session duration in seconds
sessionDurMin = sessionDurSec/60; % session duration in minutes

% Running behavior
movement = movement - 1.37824684461941; %zeroing encoder trace - the wrong way
movement = smooth(movement);
forwardMove = find(movement > 0.009); %filtering noise to get forward movement
backwardMove = find(movement < -0.009); %filtering noise to get backward movement
forwardMoveTime = (length(forwardMove)/1000); % Time spent running foward in seconds
backwardMoveTime = (length(backwardMove)/1000); % Time spent running backward in seconds
percentTimeRunning = (forwardMoveTime/sessionDurSec) * 100; % Percent of time running forward

totalAverageVelocity = mean(movement); % mean velocity throughout session regardless of whether mouse is walking
averageRunVelocity = mean(movement(forwardMove)); % mean velocity when mouse is walking

% Lick behavior
lickDiff = diff(licks);                       %get edges of licks
endLick = find(diff(licks) == -1);            %get times the lick pulse ends
lickDiff(endLick) = 0;                        %set the end of lick pulses to zero; now lick Diff can be added to get total number of licks
lickTimes = find(diff(licks) == 1);           %get time for each lick
lickCount = length(find(diff(licks) == 1));   %count licks for whole session
lickRate = lickCount/sessionDurSec;           %lick rate over whole session

% Reward
smoothPump = smooth(pump,5000);
threshPump = smoothPump < 0.01255;
rewardLocations = find(diff(threshPump) == 1);
rewardCount = length(rewardLocations);
rewardRate = rewardCount/sessionDurMin;

% Behavior by position on track
transitionsOne = find(diff(textureone) == 1);      %gives timestamp for each scan of tag 1
transitionsTwo = find(diff(texturetwo) == 1);      %gives timestamp for each scan of tag 2
transitionsThree = find(diff(texturethree) == 1);  %gives timestamp for each scan of tag 3
transitionsFour = find(diff(texturefour) == 1);    %gives timestamp for each scan of tag 4

%Order scanning of each tag throughout session with the time of scanning.
%The first tag scanned will appear in the second row in the first column
%and the frame number will be in the first row in the same column.
transitionsOne = [transitionsOne; (zeros(1,length(transitionsOne))+1)];
transitionsTwo = [transitionsTwo; (zeros(1,length(transitionsTwo))+2)];
transitionsThree = [transitionsThree; (zeros(1,length(transitionsThree))+3)];
transitionsFour = [transitionsFour; (zeros(1,length(transitionsFour))+4)];
transitionsAll = [transitionsOne, transitionsTwo, transitionsThree, transitionsFour];
transitions = transitionsAll.';
transitions = sortrows(transitions,1);
transitions = transitions.';

i = find(diff(transitions(2,:))); 
n = [i numel(transitions(2,:))] - [0 i];
c = arrayfun(@(X) X-1:-1:0, n , 'un',0);
y = cat(2,c{:});
repeats = find(y >= 1) + 1;
transitions(:,repeats) = []; % delete repeated transitions; Sometimes an RFID tag will be scanned twice very quickly. This removes those repeated scans.

nzones = size(transitions,2) - 1; %Number of zones traveled through
distmeasure = zeros(nzones,1); %Initialize distance variable
lapLicks = zeros(nzones,1); %Initialize lick by lap
nlaps = fix(nzones/4); %Number of laps made on treadmill
remzones = rem(nzones,4); %remainder (i.e. final partial lap)
    
%Count number of times that mouse travels through each of 4 textures
    if remzones>=1
        textureone=zeros(nlaps+1,1);
    else
        textureone=zeros(nlaps,1);
    end
    
    if remzones>=2
        texturetwo=zeros(nlaps+1,1);
    else
        texturetwo=zeros(nlaps,1);
    end
    
    if remzones>=3
        texturethree=zeros(nlaps+1,1);
    else
        texturethree=zeros(nlaps,1);
    end
    
    texturefour=zeros(nlaps,1);
    
    %Find distance for each trip through each texture
    for zone = 1:nzones
        
        distmeasure(zone) = sum(movement(transitions(1,zone):transitions(1,zone+1))); %Find distance for each trip through each texture
        zoneLicks(zone) = sum(lickDiff(transitions(1,zone):transitions(1,zone+1))); %Find  for each trip through each texture
    end
    
    zoneOneTransition = find(transitions(2,:) == 1);
    zoneTwoTransition = find(transitions(2,:) == 2);
    zoneThreeTransition = find(transitions(2,:) == 3);
    zoneFourTransition = find(transitions(2,:) == 4);
    
    zoneLicks = zoneLicks.';
    textureone = distmeasure(zoneOneTransition(1,1):4:end,:); %distance traveled in texture one
    texturetwo = distmeasure(zoneTwoTransition(1,1):4:end,:); %distance traveled in texture two
    texturethree = distmeasure(zoneThreeTransition(1,1):4:end,:); %distance traveled in texture three
    texturefour = distmeasure(zoneFourTransition(1,1):4:end,:);%distance traveled in texture four
    
    lickOne = zoneLicks(zoneOneTransition(1,1):4:end,:); %licks in texture one
    lickTwo = zoneLicks(zoneTwoTransition(1,1):4:end,:); %licks in texture two
    lickThree = zoneLicks(zoneThreeTransition(1,1):4:end,:); %licks in texture three
    lickFour = zoneLicks(zoneFourTransition(1,1):4:end,:); %licks in texture four
    
    lickRewardFraction = (sum(lickFour))/((sum(lickOne)) + (sum(lickTwo)) + (sum(lickThree)) + (sum(lickFour))); %Gives the fraction of all licks that occurs within the rewarded quadrant
    
    %Find number of data points for each zone
    
    zonesize=zeros(nzones,1); %initialize variable
    
    for zone=1:nzones
        
        zonesize(zone,1)=transitions(1,zone+1)-transitions(1,zone); % number of data points for each trip through each texture
    end
    
    zonesizeone = zonesize(zoneOneTransition(1,1):4:end,:); %number of data points traveled in texture one
    zonesizetwo = zonesize(zoneTwoTransition(1,1):4:end,:); %number of data points traveled in texture two
    zonesizethree = zonesize(zoneThreeTransition(1,1):4:end,:); %number of data points traveled in texture three
    zonesizefour = zonesize(zoneFourTransition(1,1):4:end,:);%number of data points traveled in texture four
    
    timeOne = zonesizeone / 1000; %time for each pass through first texture in seconds
    timeTwo = zonesizetwo / 1000; %time for each pass through second texture in seconds
    timeThree = zonesizethree / 1000; %time for each pass through third texture in seconds
    timeFour = zonesizefour / 1000; %time for each pass through fourth texture in seconds
    
    timeByZone = [sum(timeOne) sum(timeTwo) sum(timeThree) sum(timeFour)];
    zoneTimeFirstLap = [timeOne(1,1), timeTwo(1,1), timeThree(1,1), timeFour(1,1)];
    
    totalLickRateOne = sum(lickOne)/sum(timeOne);
    totalLickRateTwo = sum(lickTwo)/sum(timeTwo);
    totalLickRateThree = sum(lickThree)/sum(timeThree);
    totalLickRateFour = sum(lickFour)/sum(timeFour);
    
    lickRateByZone = [totalLickRateOne, totalLickRateTwo, totalLickRateThree, totalLickRateFour];
    
    lickRateOne = zeros(nlaps,1); %initialize variable
    lickRateTwo = zeros(nlaps,1); %initialize variable
    lickRateThree = zeros(nlaps,1); %initialize variable
    lickRateFour = zeros(nlaps,1); %initialize variable
    
    for j = 1:nlaps
         lickRateOne(j,1) = lickOne(j,1) / timeOne(j,1); %lick rate for each trip through first texture
         lickRateTwo(j,1) = lickTwo(j,1) / timeTwo(j,1); %lick rate for each trip through second texture
         lickRateThree(j,1) = lickThree(j,1) / timeThree(j,1); %lick rate for each trip through third texture
         lickRateFour(j,1) = lickFour(j,1) / timeFour(j,1); %lick rate for each trip through fourth texture
         
    end
    
    lickRateFirstLap = [lickRateOne(1,1), lickRateTwo(1,1), lickRateThree(1,1), lickRateFour(1,1)];
    
    %Find cumulative distance along each zone, this needs to be a cell array
    %as each zone is a different size
    
    distancex{nzones,1}=[]; %initialize cell array
    
    %Create x (distance) for each zone crossing
    
    for zone=1:nzones
        distancex{zone} = cumsum(movement(transitions(1,zone):transitions(1,zone+1))); %integrate distance for each trip through each texture
    end
    
    %and organize this data by zones and laps
    
    xone=cell(size(textureone));
    newzone=0;
    for zone=zoneOneTransition(1,1):4:nzones
        newzone=newzone+1;
        xone{newzone}= distancex{zone}; % x positions of data points in texture one
    end
    
    xtwo=cell(size(texturetwo));
    newzone=0;
    for zone=zoneTwoTransition(1,1):4:nzones
        newzone=newzone+1;
        xtwo{newzone}= distancex{zone}; % x positions of data points in texture two
    end
    
    xthree=cell(size(texturethree));
    newzone=0;
    for zone=zoneThreeTransition(1,1):4:nzones
        newzone=newzone+1;
        xthree{newzone}= distancex{zone}; % x positions of data points in texture three
    end
    
    xfour=cell(size(texturefour));
    newzone=0;
    for zone=zoneFourTransition(1,1):4:nzones
        newzone=newzone+1;
        xfour{newzone}= distancex{zone}; % x positions of data points in texture four
    end

%The following code builds a map of lick distributions with a resolution of 3 cm on a 180 cm belt    
    
    %We build histograms of the time spent at each position
    %first define bin edges

    binSize = 15; %will be used to divide each pass through a texture into 15 segments, which for a 180cm treadmill will equal 3cm per bin
   
    %then build histograms of time spent
    [histtimeone,~]=histcounts(cell2mat(xone),binSize);
    [histtimetwo,~]=histcounts(cell2mat(xtwo),binSize);
    [histtimethree,~]=histcounts(cell2mat(xthree),binSize);
    [histtimefour,~]=histcounts(cell2mat(xfour),binSize);
    
    lickMap{1,7} = [];
    
    [lickPos1st, lickPos2nd, lickPos3rd, lickPos4th] = placeFiring(nzones, transitions(1,:), distancex, licks);
    
    %Pack lick rates for each zone into a single cell array
    lickPosAll{1,1} = lickPos1st; 
    lickPosAll{1,2} = lickPos2nd;
    lickPosAll{1,3} = lickPos3rd;
    lickPosAll{1,4} = lickPos4th;
    
    %Re-align licks to appropriate zones
    lickPosOne = lickPosAll(1,zoneOneTransition(1,1));
    lickPosTwo = lickPosAll(1,zoneTwoTransition(1,1));
    lickPosThree = lickPosAll(1,zoneThreeTransition(1,1));
    lickPosFour = lickPosAll(1,zoneFourTransition(1,1));
    
    %Unpack licks for histogram analysis
    lickPosOne = lickPosOne{1,1};
    lickPosTwo = lickPosTwo{1,1};
    lickPosThree = lickPosThree{1,1};
    lickPosFour = lickPosFour{1,1};
        
        %create histogram of firing positions
        [histone,~]=histcounts(cell2mat(lickPosOne),binSize);
        [histtwo,~]=histcounts(cell2mat(lickPosTwo),binSize);
        [histthree,~]=histcounts(cell2mat(lickPosThree),binSize);
        [histfour,~]=histcounts(cell2mat(lickPosFour),binSize);
        
        %and normalize by the time spent in each position from the histogram
        %calculated above
        
        norhistone=histone./histtimeone;
        norhisttwo=histtwo./histtimetwo;
        norhistthree=histthree./histtimethree;
        norhistfour=histfour./histtimefour;
        
        norhistall=[norhistone, norhisttwo, norhistthree, norhistfour];
        norhistall=norhistall/sum(norhistall);
        
        %Create lookup table for the center of histogram bins from 0 to 2pi (i.e.
        %commonly referred at theta, whereas norhistall is rho)
        
        polangle=linspace(0,2*pi, size(norhistall,2));
        zoneborders=[size(norhistone,2), size(norhistone,2)+size(norhisttwo,2), size(norhistone,2)+size(norhisttwo,2)+size(norhistthree,2)];
        
        tuningphasor=0;
        for i = 1:size(norhistall,2)
            
            tuningphasor=tuningphasor + (norhistall(i)*exp(1i*polangle(i)));
            
        end
        
        lickPrecision = abs(tuningphasor);
        
        %now find if this is significant by bootstraping to create null
        %distribution
        
        MaxIterations = 1000;
        
        randTuningDist = lickMapShuffle(nzones, transitions(1,:), distancex, licks, MaxIterations, binSize, histtimeone, binSize, histtimetwo, binSize, histtimethree, binSize, histtimefour,polangle);
        
        SigThreshold=prctile(randTuningDist,95);
        SortedItrTuning=sort(randTuningDist);
        IndicesHigher=find(SortedItrTuning > lickPrecision);
        if numel(IndicesHigher)~=0
    
            PVal=(MaxIterations-IndicesHigher(1))/MaxIterations;
        else
            PVal=1/MaxIterations;
        end
        
        %Save information of each cell: the firing histogram (rho),the
        %angles (theta), the tuning index and the alpha value for 95th percentile
        
        lickMap{1,1}=norhistall;
        lickMap{1,2}=polangle;
        lickMap{1,3}=lickPrecision;
        lickMap{1,4}=SigThreshold; %threshold for alpha=0.05
        lickMap{1,5}=zoneborders; %borders between zones (angles)
        lickMap{1,6}=PVal; %p-value of tuningidx
        lickMap{1,7}=randTuningDist; %save null distribution
        
        figure;
        polarplot(polangle,norhistall)