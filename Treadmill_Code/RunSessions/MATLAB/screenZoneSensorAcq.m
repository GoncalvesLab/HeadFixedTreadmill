function [zoneFlag,zoneNumber] = screenZoneSensor (zoneSenseDuration, niCardDevice)

%This function detects zone RFID "taps" by monitoring the output of the
%RFID arduino that is connected to "Static"** ni-card digital inputs (1 input per zone). 
%INPUTS. zoneSenseDuration: period during which the zone sensor is checked.
%niCardSession: the NI-card session that is created bofore the function
%call and indicate the NI-card channel that the sensor is connected to.
%OUTPUTS. zoneFlag: 1 if a zone "tap" is sensed and 0 if no zone change is sensed.
%zoneTime: time of the sensed zone change if zoneFlag = 1, time of the last sensor
%check relative to the "startTime" if zoneFlag = 0 

%**Static digital input chnnel means that the channel can't be monitored continously
%through the background and foreground commands and should be monitored with
%SingleScan commands.




counter = 0;

while (1)
    
    digitalInput = read(niCardDevice, 'OutputFormat', 'Matrix');
    inputTime = tic;
    
    if ~counter
        startTime = inputTime;
    end
    
    if sum(digitalInput>0)
        zoneFlag = 1;
        zoneNumber = digitalInput;
        %disp(zoneNumber); %for debugging purposes only
        return 

    end
    
    if (toc(startTime)>zoneSenseDuration)
        break;
    end
    
    counter = counter + 1;
end

zoneFlag = 0;
zoneNumber=[];
end