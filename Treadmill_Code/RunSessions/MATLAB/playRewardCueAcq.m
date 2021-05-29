function [] = playRewardCue (buzz_dur, buzz_freq, niCardDev)


% Length of play will be buzz_dur but not callibrated to seconds

buzz_freq=0; %this variable currently not used


write(niCardDev, [0,0]);


for loop=1:buzz_dur
    
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,0]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,1]);
    write(niCardDev, [0,0]);
    
    end


end