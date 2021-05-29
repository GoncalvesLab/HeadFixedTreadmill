function  runsBack= checkBackwardRunning (zoneNow, zoneBefore)
%this function checks if the mouse is running backwards, if animal briefly runs
%backward and forward, and same zone detected, this is NOT considered
%backward running. Animal needs to go back to previous RFID tag in order
%for runsBack to be true


    if (zoneNow == 5 && zoneBefore==1)
    
        runsBack=true;
        return
    
    elseif (zoneNow == 1 && zoneBefore ==5)
        
        runsBack=false;
        return
        
    elseif (zoneNow-zoneBefore < 0)
        
        runsBack=true;
        return
 
    end
    
    runsBack=false;
    
end
    