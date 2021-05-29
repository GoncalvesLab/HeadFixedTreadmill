function [lickFlag,lickTime] = screenLickSensor (lickSenseDuration, niCardSession)

%This function detects the first lick by monitoring the output of the Janelia lick
%sensor board that is connected to a "Static"** ni-card digital input. 
%INPUTS. lickSenseDuration: period during which the lick sensor is checked.
%niCardSession: the NI-card session that is created bofore the function
%call and indicate the NI-card channel that the sensor is connected to.
%OUTPUTS. lickFlag: 1 if a lick is sensed and 0 if no lick is sensed.
%lickTime: time of the sensed lick if lickFlag = 1, time of the last sensor
%check relative to the "startTime" if lickFlag = 0 

%**Static digital input chnnel means that the channel can't be monitored continously
%through the background and forground commands and should be monitored with
%SingleScan commands.


% global beforeFuncTime % this variable was used for the test with
% lickSensorTest.m

counter = 0;

while (1)
    
    digitalInput = inputSingleScan(niCardSession);
    inputTime = GetSecs();
    
    if ~counter
        startTime = inputTime;
    end
    
    if digitalInput
        lickFlag = 1;
        lickTime = inputTime - startTime;
        return 

    end
    
    if (inputTime>(startTime+lickSenseDuration))
        break;
    end
    
    counter = counter + 1;
end
% The following two lines were used for the test of the function with
% lickSensorTest.m
% disp(startTime - beforeFuncTime) %this is less than 1 ms
% disp(counter);
lickFlag = 0;
lickTime = inputTime - startTime;

end