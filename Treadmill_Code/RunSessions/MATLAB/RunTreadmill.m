%Treadmill data acquisition routine
%Gonçalves Lab www.goncalveslab.org
%Parts of this code were adapted from Sjulson lab and 
%Ehsan Sabri (Batista-Brito Lab)

clear all
close all

%data recording Directory
baseDirectory = 'E:\Documents\MATLAB\Treadmill\'; %must end in \

% entering the mouse Numbers, session duration and the session number of the day 
prompt = {'Enter the mouse number:','Enter the Session Duration in Minutes','Enter the day session number:'};
titleBox = 'Input';
dims = [1 35];
dialogBoxInputs = inputdlg(prompt,titleBox,dims);
mouseNumber = dialogBoxInputs{1};
sessionDurInMin = str2num(dialogBoxInputs{2});
sessionNumber = dialogBoxInputs{3};

% data folder name
dataFolderName = [baseDirectory datestr(date,'yyyymmdd') '_Mouse' mouseNumber '_Session' sessionNumber];

%making the folder for saving the data
mkdir(dataFolderName);



niDevName = 'Dev1';
%Initialization of the required daq card sessions
daqreset;

%Analog Data Acquisition Object for background recording of the following signals:
signalsRecording = daq('ni');  

%Initialize Analog inputs
disp('Adding analog input channels ...')
addinput(signalsRecording,niDevName,'ai0','Voltage'); %Input from rpm counter
addinput(signalsRecording,niDevName,'ai1','Voltage'); %Copy of signal to Pumpy
 
%add digital input channels for RFID zones and lick sensor
disp('Adding channels for recording zone RFID tags and lick sensor...')
addinput(signalsRecording,niDevName,'port0/line2','Digital'); %RFID Zone 1
addinput(signalsRecording,niDevName,'port0/line3','Digital'); %RFID Zone 2
addinput(signalsRecording,niDevName,'port0/line4','Digital'); %RFID Zone 3
addinput(signalsRecording,niDevName,'port0/line5','Digital'); %RFID Zone 4
addinput(signalsRecording,niDevName,'port0/line6','Digital'); %RFID Reward
addinput(signalsRecording,niDevName,'port0/line7','Digital'); %Lick sensor

%Digital input session for listening to zone changes and adding rewards - foreground operation

foregroundDetection = daq('ni');
disp('Adding channels with copy of RFID signal for reward purposes...')
addinput(foregroundDetection,niDevName,'port1/line1','Digital'); %copy of RFID Zone 1
addinput(foregroundDetection,niDevName,'port1/line2','Digital'); %copy of RFID Zone 2
addinput(foregroundDetection,niDevName,'port1/line3','Digital'); %copy of RFID Zone 3
addinput(foregroundDetection,niDevName,'port1/line4','Digital'); %copy of RFID Zone 4
addinput(foregroundDetection,niDevName,'port1/line5','Digital'); %copy of RFID Reward zone

%Digital Output session for right reward control
addoutput(foregroundDetection,niDevName,'port0/line0','Digital'); %Digital reward port

%Digital Output session for reward cue buzzer
addoutput(foregroundDetection,niDevName,'port0/line1','Digital'); %Digital reward cue port

write(foregroundDetection, [0,0]);

% Reward Volume:
rewardVol = 100; %in microL
syringeVol = 5;

%Cue Duration and Frequency
cueDuration= 3; %number of repeats, needs to be integer
cueFrequency = 1000; %not currently used

%Digital input session for listening to zone changes

%Configuring the session for recording analog inputs
signalsRecording.Rate = 1000;
for chNo=1:2 % was size(signalsRecordingSession.Channels,2)
      signalsRecording.Channels(chNo).TerminalConfig = 'SingleEnded';
end

%recording data through the listener, we will also analyze the input data
%for detecting the licks by sending a copy of the lick sensor to a digital
%input
binFile = [dataFolderName '\synchedNI-CardInputs.bin'];
fid1 = fopen(binFile,'w');

signalsRecording.ScansAvailableFcnCount=500;
signalsRecording.ScansAvailableFcn = @(src,evt) readAndLogData (src,evt, fid1);

%start the recording of signals
start(signalsRecording,'Duration',sessionDurInMin * 60);
recStartTime=tic; %set timer for beginning of recording
disp('Start recording...')

tapCount = 0;
zoneTrack = [0 0 0 0 0];
loopTime = 0;

while(loopTime < (sessionDurInMin * 60))
    
    [zoneFlag, zoneNumber] = screenZoneSensorAcq(0.5,foregroundDetection); %time-out for detecting an event is given in seconds
    
    if zoneFlag ~= 0
        
       
        zoneDetected=find(zoneNumber==1);
        
        if sum(zoneNumber)>1
             disp('Multiple zones recorded, skipping iteration')
            continue;
        else
            zoneTrack(zoneDetected)=1;
%             disp(zoneTrack)  %for debugging purposes only
        end
        
            if (zoneDetected == 5 && previousZone == 4)
                
                playRewardCueAcq(cueDuration, cueFrequency,foregroundDetection); % cueDur isn't seconds, cueFreq isn't used
                deliverRewardAcq(rewardVol, syringeVol, foregroundDetection);
                zoneTrack = [0 0 0 0 0];
            end

        previousZone = zoneDetected;
    end
    
    loopTime = toc(recStartTime);
end


%Stop the recording
disp('Saving the session...')
pause(15) %To be sure that the whole session is recorded!
stop(signalsRecording);

fclose(fid1);

%Saving the variables of the session and the code file in the recording
%directory
save([dataFolderName '\workspaceVariables.mat']);


function readAndLogData(src, ~, fid)

    [data,timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    
    fwrite(fid,[timestamps,data]','double');

end


