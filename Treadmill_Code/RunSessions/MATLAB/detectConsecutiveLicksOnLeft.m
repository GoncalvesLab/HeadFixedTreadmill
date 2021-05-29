function [lickTrainDetectionFlag relTrainTime] = detectConsecutiveLicksOnLeft (lickSenseDuration, niCardSession, noConsecutiveLicks)


%This function detects the consecutive licks on the left spout by monitoring two spouts through the output of the Janelia lick
%sensor board that is connected to a "Static"** ni-card digital inputs. 
%INPUTS. lickSenseDuration: period during which the lick sensor is checked.
%niCardSession: the NI-card session that is created bofore the function
%noConsecutiveLicks: the number of consecutive licks to be detected
%call and indicate the NI-card channel that the sensor is connected to.
%OUTPUTS. lickTrainDetectionFlag: 1 if a train of noCosecutiveLicks are detected on the right spout during lickSenseDuration, 0 if not  

%**Static digital input chnnel means that the channel can't be monitored continously
%through the background and forground commands and should be monitored with
%SingleScan commands.


startFlag = 0;
lickTrainDetectionFlag = 0;
lickCounter = 0;
lickFlag = 0; %flag that the sensor is touched

while (1)
    
    digitalInput = inputSingleScan(niCardSession);
    inputTime = GetSecs();
    port1 = digitalInput(1);
    port2 = digitalInput(2);
    
    
    if ~startFlag
        startTime = inputTime;
        startFlag = 1;
    end
    
    if (inputTime>(startTime+lickSenseDuration))
        break;
    end
    
    if port1 | port2
        
        if port2
            lickFlag = 1;    
        else
            lickCounter = 0;
        end
        
    elseif ~port2
        if lickFlag
            lickCounter = lickCounter + 1;
            if lickCounter == noConsecutiveLicks
                lickTrainDetectionFlag = 1;
                relTrainTime = inputTime - startTime;
                return
            end
            lickFlag = 0;
        end
    end

end
relTrainTime = inputTime - startTime;

end
