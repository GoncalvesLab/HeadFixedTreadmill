
%reading the recorded data
[file,path] = uigetfile('*.bin');
fid2 = fopen([path file],'r');
% testData = fread(fid2,'double');
[data,count] = fread(fid2,[9,inf],'double');
fclose(fid2);

figure();
t = data(9,:);
ch = data(1:8,:);

temp = ch(1,:);
temp(temp<4)=0;
ch(1,:)=temp;

temp = ch(5,:);
temp(temp<4)=0;
ch(5,:)=temp;

startTime = 0;
finTime = 60;

% figure()
% plot(t(t>startTime & t<finTime), ch(:,t>startTime & t<finTime));
plot(data(2,:))
hold on
plot(data(3,:),'r')
plot(data(9,:),'k')