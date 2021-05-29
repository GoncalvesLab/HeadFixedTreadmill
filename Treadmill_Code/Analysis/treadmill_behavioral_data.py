# -*- coding: utf-8 -*-
"""
Created on Mon Apr  5 14:08:21 2021
Analysis code for treadmill behavioral data analysis
by M. Agustina Frechou ( Gonçalves Lab -- www.goncalveslab.org )
@author: AgusF
"""

'''
Treadmill behavioral analysis
'''
import os
import glob
import numpy as np
from matplotlib import pyplot as plt
from itertools import groupby
import pandas as pd

'''
Functions
'''
def smooth(a,WSZ):
        # a: NumPy 1-D array containing the data to be smoothed
        # WSZ: smoothing window size needs, which must be odd number,
        # as in the original MATLAB implementation
        out0 = np.convolve(a,np.ones(WSZ,dtype=int),'valid')/WSZ    
        r = np.arange(1,WSZ-1,2)
        start = np.cumsum(a[:WSZ-1])[::2]/r
        stop = (np.cumsum(a[:-WSZ:-1])[::2]/r)[::-1]
        return np.concatenate((  start , out0, stop  ))

'''
Parameters
'''



#find files
file_path = glob.glob(r'Z:\Goncalves Lab\Jake\DREADDs_Treadmill_Cohort2\Spatial Training\Session 9\*')

for file_name in file_path:
    
    #load data
    file = os.path.join(file_name, 'synchedNI-CardInputs.bin')
    data = [np.fromfile(file)[i::9] for i in range(9)]
    
    #define data variables 
    pump = data[1]
    movement = data[2]
    textureone = data[3]
    texturetwo = data[4]
    texturethree = data[5]
    texturefour = data[6]
    reward = data[7]
    licks = data[8]
    
    sessionDurSec = (len(movement)/1000) # session duration in seconds
    sessionDurMin = sessionDurSec/60 # session duration in minutes
    
    #reward   
    rewards = np.diff(reward)       
    count_rewards = np.count_nonzero(rewards == 1) # number of rewards the mouse got
    reward_locations = np.argwhere(np.diff(reward) == 1)
    reward_rate = count_rewards/sessionDurMin
    
    #running behavior
    movement = smooth(movement,5);
    
    #clean movement (deltaM/M)
    movement_cleaned = []
    for index in range(0, len(movement), 10000):
        x = movement[index:index+10000]
        percentile = np.percentile(x, 20)
        delta = (movement[index:index+10000] - percentile)/percentile
        movement_cleaned.extend(delta)
    
    movement = movement_cleaned
    
    forwardMove = np.argwhere(np.array(movement) > 0.009) #filtering noise to get forward movement
    backwardMove = np.argwhere(np.array(movement) < -0.009) #filtering noise to get backward movement
    forwardMoveTime = (len(forwardMove)/1000) # Time spent running foward in seconds
    backwardMoveTime = (len(backwardMove)/1000) # Time spent running backward in seconds
    percentTimeRunning = (forwardMoveTime/sessionDurSec) * 100 # Percent of time running forward
    
    totalAverageVelocity = np.mean(movement) # mean velocity throughout session regardless of whether mouse is running
    averageRunVelocity = np.mean(np.array(movement)[forwardMove])
    
    # Lick behavior
    lickDiff = np.diff(licks)                             #get edges of licks
    endLick = np.argwhere(np.diff(licks) == -1)           #get times the lick pulse ends
    lickDiff[endLick] = 0                                 #set the end of lick pulses to zero; now lick Diff can be added to get total number of licks
    lickTimes = np.argwhere(np.diff(licks) == 1)          #get time for each lick
    lickCount = len(np.argwhere(np.diff(licks) == 1))     #count licks for whole session
    lickRate = lickCount/sessionDurSec                    #lick rate over whole session
    
    # Behavior by position on track
    transitionsOne = np.argwhere(np.diff(textureone) == 1)      #gives timestamp for each scan of tag 1
    transitionsOne = transitionsOne.tolist()
    transition_one_flat = [item for sublist in transitionsOne for item in sublist]
    zone_one = np.zeros(len(transitionsOne))+1
    zone_one = zone_one.tolist()
    one = list(zip(transition_one_flat,zone_one))
    
    transitionsTwo = np.argwhere(np.diff(texturetwo) == 1)      #gives timestamp for each scan of tag 2
    transitionsTwo = transitionsTwo.tolist()
    transition_two_flat = [item for sublist in transitionsTwo for item in sublist]
    zone_one = np.zeros(len(transitionsTwo))+2
    zone_one = zone_one.tolist()
    two = list(zip(transition_two_flat,zone_one))
    
    transitionsThree = np.argwhere(np.diff(texturethree) == 1)  #gives timestamp for each scan of tag 3
    transitionsThree = transitionsThree.tolist()
    transition_three_flat = [item for sublist in transitionsThree for item in sublist]
    zone_one = np.zeros(len(transitionsThree))+3
    zone_one = zone_one.tolist()
    three = list(zip(transition_three_flat,zone_one))
    
    transitionsFour = np.argwhere(np.diff(texturefour) == 1)    #gives timestamp for each scan of tag 4
    transitionsFour = transitionsFour.tolist()
    transition_four_flat = [item for sublist in transitionsFour for item in sublist]
    zone_one = np.zeros(len(transitionsFour))+4
    zone_one = zone_one.tolist()
    four = list(zip(transition_four_flat,zone_one))
    
    transitions = one+two+three+four
    transitions.sort()
    
    #remove duplicates
    transitions = [i[0] for i in groupby(transitions)]
    
    u = textureone+texturetwo+texturethree+texturefour
    #l = np.concatenate((transitionsOne,transitionsTwo,transitionsThree,transitionsFour))
    y = np.argwhere(np.diff(u) == 1) # all timestamps
    zone = np.concatenate((np.zeros(len(transitionsOne))+1,np.zeros(len(transitionsTwo))+2,np.zeros(len(transitionsThree))+3,np.zeros(len(transitionsFour))+4))
    
    nzones = len(y)-1 # number of completed zones
    nlaps = nzones//4 # number of laps
    reminder = nzones % 4 #reminder zones
    
    #Count number of times that mouse travels through each of 4 textures
    unique, counts = np.unique(zone, return_counts=True)
    dict(zip(unique, counts))

    #licks in each completed texture
    licks_all = []
    licks_all.append(0)
    for i in range(len(transitions)-1):
        x = np.sum(lickDiff[transitions[i][0]:transitions[i+1][0]])
        licks_all.append(x)
        
    #movement in each completed texture
    movement_all = []
    movement_all.append(0)
    for i in range(len(transitions)-1):
        x = np.sum(movement[transitions[i][0]:transitions[i+1][0]])
        movement_all.append(x)
    
    #distance traveled in each completed texture
    df = pd.DataFrame(transitions, columns = ['transition', 'zone'])
    df['licks'] = licks_all
    df['distance'] = df['transition'].diff()
    df['time'] = df['distance']/1000
    df['lick_rate_per_texture'] = df['licks']/df['time']
    lick_rate_by_texture = df[['zone', 'lick_rate_per_texture']]  
    lick_rate_by_texture = lick_rate_by_texture.iloc[1:]
    lick_rate_by_texture = lick_rate_by_texture.sort_values('zone')
    df['movement'] = movement_all
    
    
    
    by_zone = df.groupby(['zone']).sum() #total distance by zon in frames
    sum_licks_all = by_zone['licks'].sum() #total licks per zone
    by_zone['lick_frac_zone'] = by_zone['licks']/sum_licks_all #lick fraction by zone
    by_zone['time'] = by_zone['distance']/1000 #time spent in each zone
    by_zone['lick_rate_zone'] = by_zone['licks']/by_zone['time'] #lick rate per zone
    movement_by_zone = df.groupby(['zone']).mean()
    by_zone['Av_speed_zone'] = movement_by_zone['movement']
    
    data = {'rewards': [count_rewards], 'laps': [nlaps], 'Avg_speed': [totalAverageVelocity]}
    results = pd.DataFrame(data)
    
    # plot running (red), licks (black) and pump (blue) to inspect session
    fig = plt.figure()
    plt.plot(pump)
    plt.plot(movement,'r')
    plt.plot(licks,'k') 
    
    
    fig.savefig(os.path.join(file_name, 'plot_mouse.png'), dpi=150)
    results.to_csv(os.path.join(file_name, 'results.csv'))
    by_zone.to_csv(os.path.join(file_name, 'results_by_zone.csv'))
    lick_rate_by_texture.to_csv(os.path.join(file_name, 'lick_rate_by_texture.csv'))

    print(file)
    print(results)
    print(by_zone)
    print(lick_rate_by_texture)
    

    



