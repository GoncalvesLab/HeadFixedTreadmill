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

i=0;
loopTime=0;
binFile='TestLog.bin';
fid1 = fopen(binFile,'a');


recDuration = 20;
signalsRecording.Rate=1000;
signalsRecording.ScansAvailableFcnCount=500;
signalsRecording.ScansAvailableFcn = @(src,evt) readAndLogData (src,evt, fid1);



start(signalsRecording,'Duration',recDuration);
recStartTime=tic; %set timer for beginning of recording
disp('Start recording...')

 while (signalsRecording.IsRunning)
    i=i+1;
    loopTime = toc(recStartTime);
 end

pause(5);

%voltageData=read(signalsRecording,"all");

fclose(fid1);

function readAndLogData(src, ~, fid)

    [data,timestamps, ~] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");
    
    fwrite(fid,data,'double');

end




