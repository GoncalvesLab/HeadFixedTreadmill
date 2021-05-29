function [totalSteps,exactRewardValue] = deliverReward (volume_uL, syringeSize_mL, niCardDev)

% We will use this function to deliver the reward by controling the step motor via the NI-card
% volume_uL: amount of reward to be delivered in micro liters,
% syringeSize_mL: size of the syringe in mili liters, niCardSession: the
% handle to the ni-card session with one digital output that is created
% before calling this function (creating session each time in the function
% would take a variable time which is not desirable). 
% totalSteps: number of steps to deliver the volume_uL that is depend on
% the syringeSize_mL. exactRewardValue: the exact theoretical value of
% reward based on the total number of steps that should be very close to
% the volume_uL
% This function was rewrited based on the written function by Danniella for Arduino! the
% timing parts of that function are ignored (the timing would depend on the
% velocity of the motor which we don't have any reliable way to measure and since it happens at the end of each trial, we decided that we don't need the exact end time of reward)
% 

if (syringeSize_mL == 5) 
    diameter_mm = 12.06; %in mm
elseif (syringeSize_mL == 10)
    diameter_mm = 14.5; %in mm
else
    print("didn't recognize a valid syringe size. available sizes '5' or '10.'"); 
    return; 
end

% // determine vol per revolution, area of small cylinder with h=0.8mm
%   // 0.8mm length per thread. 1thread=1cycle. 1 like=1prayer.

volPerRevolution_uL = 0.8 * ( diameter_mm/2 )*( diameter_mm/2 ) * pi ; 

% // determine how many revolutions needed for the desired volume
howManyRevolutions = volume_uL / volPerRevolution_uL ;

%   // determine total steps needed to reach desired revolutions, @200
%   steps/revolution (step motor specification)
%   // use *4 as a multiplier because it's operating at 1/4 microstep mode (MS1=0,MS2=1,MS3=0).
%   // round to nearest int because totalSteps is unsigned long
totalSteps = round(200 * howManyRevolutions);

exactRewardValue = totalSteps*volPerRevolution_uL/800;

%   // determine shortest delivery duration, total steps * 2 ms per step.
%   (where does 1 ms come from?)
%   // minimum 1 ms in high, 1 ms in low for the shortest possible step function.
% minimumDeliveryDuration_ms = totalSteps*2; 

%   // make sure delivery duration the user wants is long enough
% if (local_deliveryDuration_ms < minimumDeliveryDuration_ms)
%     print("duration too low. duration needs to be >");
%     print(minimumDeliveryDuration_ms); 
%     print("with that diameter and reward volume.");
%     return;
% end

%   // determine duration of each step for the timer oscillate function
% stepDuration_ms = local_deliveryDuration_ms / totalSteps;

write(niCardDev, [0,0]);


for loop=1:totalSteps
    
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [0,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [1,0]);
    write(niCardDev, [0,0]);
    
end


end