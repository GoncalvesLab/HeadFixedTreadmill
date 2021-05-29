%Digital Output session for right reward control
rewardStepMotorCtl1 = daq.createSession('ni');
rewardPortLine1 = 'port0/line0';

%Digital Output session for right reward cue buzzer
rewardCueBuzzer = daq.createSession('ni');
rewardCueLine1 = 'port0/line1';

%1 - output to step motor to control the reward
rewardStepMotorCtl1.addDigitalChannel(niDevName,rewardPortLine1,'OutputOnly');
rewardCueBuzzer.addDigitalChannel(niDevName, rewardCueLine1, 'OutputOnly');

for n = 1:20
    pause(round(rand()*30));
    playRewardCue(cueDuration, cueFrequency,rewardCueBuzzer); % cueDur isn't seconds, cueFreq isn't use
    deliverReward(rewardVol, syringeVol, rewardStepMotorCtl1);
    
end