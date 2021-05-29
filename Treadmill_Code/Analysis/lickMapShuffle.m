function  lickMapTuning = lickMapShuffle(nz, trans, distx, trace, MaxItr, edg1, htime1, edg2, htime2, edg3, htime3, edg4, htime4, pangle)

%initialize surrogate tuning distribution

rng('shuffle'); %random number generator will be based on time, i.e. always different

lickMapTuning = zeros(1,MaxItr);


for itr = 1:1:MaxItr
    
    ItrReSamp = circshift(trace,randi(size(trace,2)),2);
    
    [ItrXPosFireOne, ItrXPosFireTwo, ItrXPosFireThree, ItrXPosFireFour] = placeFiring(nz, trans, distx, ItrReSamp);
    
    %then create histogram
    [ItrHistOne,~]=histcounts(cell2mat(ItrXPosFireOne),edg1);
    [ItrHistTwo,~]=histcounts(cell2mat(ItrXPosFireTwo),edg2);
    [ItrHistThree,~]=histcounts(cell2mat(ItrXPosFireThree),edg3);
    [ItrHistFour,~]=histcounts(cell2mat(ItrXPosFireFour),edg4);
    
    ItrNorHistOne=ItrHistOne./htime1;
    ItrNorHistTwo=ItrHistTwo./htime2;
    ItrNorHistThree=ItrHistThree./htime3;
    ItrNorHistFour=ItrHistFour./htime4;
    
    ItrNorHistAll=[ItrNorHistOne, ItrNorHistTwo, ItrNorHistThree, ItrNorHistFour];
    ItrNorHistAll=ItrNorHistAll/sum(ItrNorHistAll);
    
    %add all components to calculate putative tuning phasor
    
    ItrTuningPhasor=0;
    for i = 1:size(ItrNorHistAll,2)
        
        ItrTuningPhasor=ItrTuningPhasor + (ItrNorHistAll(i)*exp(1i*pangle(i)));
        
    end
    
    lickMapTuning(itr) = abs(ItrTuningPhasor);
    
end
