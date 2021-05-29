niDevName = 'Dev1';
%Initialization of the required daq card sessions

%Analog input session for recording the following signals:
signalsRecordingSession = daq.createSession('ni');  

%8- Trial tag TTL
%9- copy of the command to the pumpie 1
addAnalogInputChannel(signalsRecordingSession,niDevName,1,'Voltage');
addAnalogInputChannel(signalsRecordingSession,niDevName,2,'Voltage');



%Configuring the session for recording analog inputs
signalsRecordingSession.Rate = 10e3;
for chNo=1:size(signalsRecordingSession.Channels,2)
    signalsRecordingSession.Channels(1,chNo).TerminalConfig = 'SingleEnded';
end
signalsRecordingSession.IsNotifyWhenDataAvailableExceedsAuto = 0;
signalsRecordingSession.IsContinuous = true;
inputSavingDur = 1; %based on the warning, 0.05 seconds is the minimum saving time that is possible, (higher interval to less affect the timings in the code!)
signalsRecordingSession.NotifyWhenDataAvailableExceeds = signalsRecordingSession.Rate * inputSavingDur;

%recording data through the listener, we will also analyze the input data
%for detecting the licks by sending a copy of the lick sensor to a digital
%input
binFile = dataFolderAdd + '\' + 'synchedNI-CardInputs.bin';
fid1 = fopen(binFile,'w');
lh = signalsRecordingSession.addlistener('DataAvailable',@(src, event)logData(src, event, fid1));



%start the recording of signals
signalsRecordingSession.startBackground();
disp('Start recording...')


%Stop the recording
disp('Saving the session...')
pause(inputSavingDur) %To be sure that the whole session is recorded!
signalsRecordingSession.stop()


delete(lh);
fclose(fid1);



%reading the recorded data
fid2 = fopen(binFile,'r');
% testData = fread(fid2,'double');
[data,count] = fread(fid2,[9,inf],'double');
fclose(fid2);

figure();
t = data(1,:);
ch = data(2:9,:);

temp = ch(1,:);
temp(temp<4)=0;
ch(1,:)=temp;

temp = ch(5,:);
temp(temp<4)=0;
ch(5,:)=temp;

startTime = 500;
finTime = 800;

% figure()
plot(t(t>startTime & t<finTime), ch(:,t>startTime & t<finTime));