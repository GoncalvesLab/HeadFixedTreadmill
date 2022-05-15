function [xposfireone, xposfiretwo, xposfirethree, xposfirefour] = placeFiring(nZones, transitionList, distanceX, activeindices)
    
    activepts=zeros(nZones,1);
    activeindices=logical(activeindices); %indices of active points for all zones
    
    for zone=1:nZones
        
        activepts(zone,1)=sum(activeindices(transitionList(zone):transitionList(zone+1))); % number of active (firing) data points for each trip through each texture
    end
    
    %number of active points in each zone
    
    activeptsone= activepts(1:4:end,:); %number of active data points (i.e. time) in texture one
    activeptstwo = activepts(2:4:end,:); %number of active data points (i.e. time) in texture two
    activeptsthree = activepts(3:4:end,:); %number of active data points (i.e. time) in texture three
    activeptsfour = activepts(4:4:end,:); %number of active data points (i.e. time) in texture four
    
    % Now get x-position of each active point
    
    xposfire{nZones,1}=[]; %initialize cell array
    
    activeindicesz{nZones,1}=[];
    
    for zone=1:nZones
        
        activeindicesz{zone}=activeindices(transitionList(zone):transitionList(zone+1)); %integrate distance for each trip through each texture
    end
    
    
    
    for zone=1:nZones
        
        xposfire{zone}=distanceX{zone}(activeindicesz{zone}); % x positions of active (firing) data points for each trip through each texture
    end
    
    %and organize this firing by zones and laps
    
    xposfireone=cell(size(activeptsone));
    newzone=0;
    for zone=1:4:nZones
        newzone=newzone+1;
        xposfireone{newzone}= xposfire{zone}; % x positions of active data points in texture one
    end
    
    xposfiretwo=cell(size(activeptstwo));
    newzone=0;
    for zone=2:4:nZones
        newzone=newzone+1;
        xposfiretwo{newzone}= xposfire{zone}; % x positions of active data points in texture two
    end
    
    xposfirethree=cell(size(activeptsthree));
    newzone=0;
    for zone=3:4:nZones
        newzone=newzone+1;
        xposfirethree{newzone}= xposfire{zone}; % x positions of active data points in texture three
    end
    
    xposfirefour=cell(size(activeptsfour));
    newzone=0;
    for zone=4:4:nZones
        newzone=newzone+1;
        xposfirefour{newzone}= xposfire{zone}; % x positions of active data points in texture four
    end
    
end

    

    
    
   


