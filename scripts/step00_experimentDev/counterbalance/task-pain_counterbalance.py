#!/usr/bin/env python
# encoding: utf-8
import os
import random
import pandas as pd
import numpy as np
from itertools import groupby
from sklearn.utils import shuffle

def noConsecutiveShuffle(list_key, list_dict, consec_num):
    # resource... https://discourse.psychopy.org/t/force-trial-order-reshuffle-until-a-constraint-is-met/2101
    random.shuffle(list_key)
    orderTest=False

    while orderTest == False:
        for i in list(range(len(list_key))):
            # if ''.join(list_key).count('same'* consec_num) > 0 or ''.join(list_key).count('diff' * consec_num) >0:
            if ''.join(list_key).count('c1'* consec_num) > 0 or \
            ''.join(list_key).count('c2' * consec_num) >0 or \
            ''.join(list_key).count('c3' * consec_num) >0 or \
            ''.join(list_key).count('c4' * consec_num) >0 or \
            ''.join(list_key).count('c5' * consec_num) >0 or \
            ''.join(list_key).count('c6' * consec_num) >0:
                random.shuffle(list_key)
                break
            else:
                orderTest = True
    trialList=[]

    for thisKey in list_key:
        trialList.append(list_dict[thisKey].pop())

    return trialList

def generateListKey(trial_per_cond):
    list_stim1 = list(range(1,trial_per_cond+1) )  # e.g. range(1,8)
    list_stim2 = list(range(trial_per_cond+1,trial_per_cond*2+1)) # e.g. range(8,15)
    list_stim3 = list(range(trial_per_cond*2+1, trial_per_cond*3+1 ))# e.g. range(1,8)
    list_stim4 = list(range(trial_per_cond*3+1, trial_per_cond*4+1 ))# e.g. range(8,15)
    list_stim5 = list(range(trial_per_cond*4+1, trial_per_cond*5+1 ))# e.g. range(8,15)
    list_stim6 = list(range(trial_per_cond*5+1, trial_per_cond*6+1 ))# e.g. range(8,15)
    list_dict = {'c1':list_stim1, 'c2':list_stim2, 'c3':list_stim3, 'c4':list_stim4, 'c5':list_stim5, 'c6':list_stim6}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    random.shuffle(list_stim3)
    random.shuffle(list_stim4)
    random.shuffle(list_stim5)
    random.shuffle(list_stim6)
    x = ['c1','c2', 'c3', 'c4', 'c5', 'c6']
    list_key  = [item for item in x for i in list(range(trial_per_cond))]
    return list_key, list_dict

def shuffleDataFrame(df_subset, consec_num):
    list_key, list_dict = generateListKey(trial_per_cond)
    list_order = noConsecutiveShuffle(list_key, list_dict, consec_num)
    # 7) sort based on shuffled sequence
    list_order[:] =  [x - 1 for x in list_order]
    cB = df_subset.reindex(list_order)
    cB.reset_index(drop = True, inplace = True)
    return cB

# parameters ___________________________________________________________________
total_block = 2  # how many repeated blocks of this "cognitive" task
cond_type = 6 # how many conditions are nested under the task
trial_per_cond = 6 # how many trials under one condition
administer_items = [48, 49, 50] # what rotation degree are we using
counterbalance_freq = 6 # how many counterbalance versions do you want
consec_num = 4
saveDir = '/Users/h/Documents/projects_local/social_influence/design'
taskname = 'pain'
cue_high_dir = '/Users/h/Documents/projects_local/social_influence/stimuli/cue/task-' + taskname + '/sch'
cue_low_dir = '/Users/h/Documents/projects_local/social_influence/stimuli/cue/task-' + taskname + '/scl'
df = pd.DataFrame()
# ______________________________________________________________________________
#for index, df in enumerate([df1, df2]):
df1 = pd.DataFrame()
df2 = pd.DataFrame()
df = pd.DataFrame()

for index, df in enumerate([df1, df2]):
    high_cue_list = [file for file in os.listdir(cue_high_dir) if file.endswith('.png')]
    # split high into 2 bins - we will use each bin for one block of high cues
    high_sample = random.sample(high_cue_list, cond_type*trial_per_cond)
    random.shuffle(high_sample)
    hCue1 = high_sample[:int(len(high_sample)/2)]
    hCue2 = high_sample[int(len(high_sample)/2):]
    high_cue = [hCue1, hCue2]

    low_cue_list = [file for file in os.listdir(cue_low_dir) if file.endswith('.png')]
    # split high into 2 bins - we will use each bin for one block of high cues
    low_sample = random.sample(low_cue_list, cond_type*trial_per_cond)
    random.shuffle(low_sample)
    lCue1 = low_sample[:int(len(low_sample)/2)]
    lCue2 = low_sample[int(len(low_sample)/2):]
    low_cue = [lCue1, lCue2]


# 1. create administer administer_items list ________________________________________________________
    df['administer'] = np.repeat(administer_items,cond_type*trial_per_cond/len(administer_items)) # add column 50/100


# 2. created cue list __________________________________________________________
    df['cue_type'] = np.tile(['high', 'low'], 18)  # np.resize(['high', 'low'], )
    df.loc[::2,'cue_image']  = high_cue[index]
    df.loc[1::2,'cue_image'] = low_cue[index]
    df['random_order'] = list(range(len(df)))
    df_reset = df.reset_index()


# 3. calculated trial type _____________________________________________________
    df['cond_type'] = ((df.cue_type == 'low') & (df.administer == administer_items[0])).astype(int) * 1 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[0])).astype(int) * 2 + \
        ((df.cue_type == 'low') & (df.administer == administer_items[1])).astype(int) * 3 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[1])).astype(int) * 4 + \
        ((df.cue_type == 'low') & (df.administer == administer_items[2])).astype(int) * 5 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[2])).astype(int) * 6
    # 4. save main dataframe file - not counterbalanced ____________________________
    # task-cognitive_mainDesign_notCounterbalanced.csv
    mainFileName = saveDir + os.sep + 'task-' + taskname + '_mainDesign_notCounterbalanced.csv'
    df.to_csv(mainFileName)


    # 5. split dataframes into two blocks and counterbalance _______________________
    for cB_ver in list(range(1,counterbalance_freq)):

        # 1) split dataframes
        # 2) shuffle each bin with the function  ___________________________________
        for index in list(range(2)):
            cB = shuffleDataFrame(df, consec_num)
            cB['condition_name'] = np.repeat([taskname], len(cB))
            cB['condition_num_filled_in_during_exper'] = 99
            cB['block_num'] = int(index+1)
            cB['cB_version'] = cB_ver # assign from for loop number
                # b) save counterbalanced versions ____________________________________________
                # filename example: task-cognitive_counterbalance_ver-06_block-01.csv
            cBverFileName = saveDir + os.sep + \
            'task-' + taskname + '_counterbalance_ver-' + str('%02d' % cB_ver)+ \
             '_block-' +str('%02d' % int(index+1)) +'.csv'
            cB.to_csv(cBverFileName)
