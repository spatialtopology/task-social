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
        for i in range(len(list_key)):
            # if ''.join(list_key).count('same'* consec_num) > 0 or ''.join(list_key).count('diff' * consec_num) >0:
            if ''.join(list_key).count('c1'* consec_num) > 0 or ''.join(list_key).count('c2' * consec_num) >0 or ''.join(list_key).count('c3' * consec_num) >0 or ''.join(list_key).count('c4' * consec_num) >0 :
                random.shuffle(list_key)
                break
            else:
                orderTest = True
    trialList=[]

    for thisKey in list_key:
        trialList.append(list_dict[thisKey].pop())

    return trialList

def generateListKey(trial_per_cond):
    list_stim1 = range(1,trial_per_cond+1)   # e.g. range(1,8)
    list_stim2 = range(trial_per_cond+1,trial_per_cond*2+1) # e.g. range(8,15)
    list_stim3 = range(trial_per_cond*2+1, trial_per_cond*3+1 )# e.g. range(1,8)
    list_stim4 = range(trial_per_cond*3+1, trial_per_cond*4+1 )# e.g. range(8,15)
    list_dict = {'c1':list_stim1, 'c2':list_stim2, 'c3':list_stim3, 'c4':list_stim4}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    random.shuffle(list_stim3)
    random.shuffle(list_stim4)
    x = ['c1','c2', 'c3', 'c4']
    list_key  = [item for item in x for i in range(trial_per_cond)]
    return list_key, list_dict

def shuffleDataFrame(df_subset):
    list_key, list_dict = generateListKey(trial_per_cond)
    list_order = noConsecutiveShuffle(list_key, list_dict, 4)
    # 7) sort based on shuffled sequence
    list_order[:] =  [x - 1 for x in list_order]
    cB = df_subset.reindex(list_order)
    cB.reset_index(drop = True, inplace = True)
    return cB

# parameters ___________________________________________________________________
total_block = 2  # how many repeated blocks of this "cognitive" task
cond_type = 4 # how many conditions are nested under the task
trial_per_cond = 7 # how many trials under one condition
administer_items = [48, 49] # what rotation degree are we using
counterbalance_freq = 6 # how many counterbalance versions do you want
saveDir = '/Users/h/Dropbox/Projects/socialPain/design'
taskname = 'pain'
df = pd.DataFrame()
# ______________________________________________________________________________


# 1. create administer administer_items list ________________________________________________________
df['administer'] = np.repeat([48, 49],14) # add column 50/100


# 2. created cue list __________________________________________________________
df['cue_type'] = np.repeat(['low', 'high', 'low', 'high'], 7)  # np.resize(['high', 'low'], 28)
df['random_order'] = range(len(df))
df_reset = df.reset_index()


# 3. calculated trial type _____________________________________________________
df['trial_type'] = ((df.cue_type == 'low') & (df.administer == administer_items[0])).astype(int) * 1 + \
    ((df.cue_type == 'high') & (df.administer == administer_items[0])).astype(int) * 2 + \
    ((df.cue_type == 'low') & (df.administer == administer_items[1])).astype(int) * 3 + \
    ((df.cue_type == 'high') & (df.administer == administer_items[1])).astype(int) * 4


# 4. save main dataframe file - not counterbalanced ____________________________
# task-cognitive_mainDesign_notCounterbalanced.csv
mainFileName = saveDir + os.sep + 'task-' + taskname + '_mainDesign_notCounterbalanced.csv'
df.to_csv(mainFileName)


# 5. split dataframes into two blocks and counterbalance _______________________
for cB_ver in range(1,counterbalance_freq):

    # 1) split dataframes
    # 2) shuffle each bin with the function  ___________________________________
    for index in range(2):
        cB = shuffleDataFrame(df)
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
