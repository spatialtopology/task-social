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
            if ''.join(list_key).count('same'* consec_num) > 0 or ''.join(list_key).count('diff' * consec_num) >0:
                random.shuffle(list_key)
                break
            else:
                orderTest = True
    trialList=[]

    for thisKey in list_key:
        trialList.append(list_dict[thisKey].pop())

    return trialList

def generateListKey(trial_freq):
    list_stim1 = range(1,trial_freq+1) # e.g. range(1,8)
    list_stim2 = range(trial_freq+1,trial_freq*2+1) # e.g. range(8,15)
    list_dict = {'same':list_stim1, 'diff':list_stim2}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    x = ['same','diff']
    list_key  = [item for item in x for i in range(trial_freq)]
    return list_key, list_dict

def shuffleDataFrame(df_subset):
    list_key, list_dict = generateListKey(trial_freq)
    list_order = noConsecutiveShuffle(list_key, list_dict, 4)
    # 7) sort based on shuffled sequence
    list_order[:] =  [x - 1 for x in list_order]
    cB = df_subset.reindex(list_order)
    cB.reset_index(drop = True, inplace = True)
    return cB

# parameters ___________________________________________________________________
version_total = 4
condition_block = 2
trial_freq = 7
degree = [50, 100]
counterbalance_freq = 6 # how many counterbalance versions do you want
saveDir = '/Users/h/Dropbox/Projects/socialPain/design'
# ______________________________________________________________________________


# 1. choose 14 numbers out of 48 and create stimuli columns ____________________
num_select = []
num_select = random.sample(range(1,49),  14)
num_sort = sorted(num_select)
list_random = random.sample(num_sort, len(num_sort))
list1 = list_random[:7]
list2 = list_random[7:]
list_newShuffle = list1*2 + list2*2
df = pd.DataFrame(list_newShuffle)
df.columns = ['stimuli_num']

# 2. create degree list ________________________________________________________
df['degree'] = np.repeat([50, 100],14) # add column 50/100

# 3. create same different column ______________________________________________
df['match'] = np.repeat(['same', 'different', 'same', 'different'], 7) # add column same/different

# 4. created cue list __________________________________________________________
df['cue_type'] = np.resize(['high', 'low'], 28)
df['random_order'] = range(len(df))
df_reset = df.reset_index()

# 5. calculated trial type _____________________________________________________
df['trial_type'] = ((df.cue_type == 'low') & (df.degree == 50)).astype(int) * 1 + \
    ((df.cue_type == 'high') & (df.degree == 50)).astype(int) * 2 + \
    ((df.cue_type == 'low') & (df.degree == 100)).astype(int) * 3 + \
    ((df.cue_type == 'high') & (df.degree == 100)).astype(int) * 4

# 6. save main dataframe file - not counterbalanced ____________________________
# task-cognitive_mainDesign_notCounterbalanced.csv
mainFileName = saveDir + os.sep + 'task-cognitive_mainDesign_notCounterbalanced.csv'
df.to_csv(mainFileName)

# 7. split dataframes into two blocks and counterbalance _______________________
for cB_ver in range(1,counterbalance_freq):
    df_subset1 = pd.DataFrame()
    df_subset2 = pd.DataFrame()
    # 1) split dataframes
    random_select1 = random.sample(range(14), 7)
    random_select2 = random.sample(range(14,27), 7)
    random_total = random_select1 + random_select2
    random_total.sort()
    df_subset1 = df.loc[random_total]
    df_subset1.reset_index(drop = True, inplace = True)
    random_other = np.setdiff1d(range(28),random_total)
    df_subset2 = df.loc[random_other]
    df_subset2.reset_index(drop = True, inplace = True)
    # 2) shuffle each bin with the function  ___________________________________
    for index, df_subset in enumerate([df_subset1, df_subset2]):
        cB = shuffleDataFrame(df_subset)
        cB['condition_name'] = np.repeat(['cognitive'], len(cB))
        cB['condition_num_filled_in_during_exper'] = 99
        cB['block_num'] = int(index+1)
        cB['cB_version'] = cB_ver # assign from for loop number
        for ind_img, row in cB.iterrows():
            if cB.loc[ind_img,'match'] == "different":
                image_filepath = str(cB.loc[ind_img,'stimuli_num']) + '_' + str(cB.loc[ind_img,'degree']) + '_R.jpg'
                cB.loc[ind_img,'image_filename'] = image_filepath
                    # row.imageFileName = imageFilePath
            elif cB.loc[ind_img,'match'] == "same":
                image_filepath = str(cB.loc[ind_img,'stimuli_num']) + '_' + str(cB.loc[ind_img,'degree']) + '.jpg'
                cB.loc[ind_img,'image_filename'] = image_filepath
        # b) save counterbalanced versions ____________________________________________
        # filename example: task-cognitive_counterbalance_ver-06_block-01.csv
        cBverFileName = saveDir + os.sep + \
        'task-cognitive_counterbalance_ver-' + str('%02d' % cB_ver)+ \
         '_block-' +str('%02d' % int(index+1)) +'.csv'
        cB.to_csv(cBverFileName)
