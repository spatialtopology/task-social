#!/usr/bin/env python
# encoding: utf-8
import os
import random
import pandas as pd
import numpy as np
from itertools import groupby
from sklearn.utils import shuffle
import glob
from collections import ChainMap
import re
import itertools
from itertools import chain
# check consecutive trial types:

# functions _______________________________________________________________________
def noConsecutiveShuffle(list_key, list_dict, consec_num):
    # resource... https://discourse.psychopy.org/t/force-trial-order-reshuffle-until-a-constraint-is-met/2101
    random.shuffle(list_key)
    orderTest=False

    while orderTest == False:
        for i in list(range(len(list_key))):
            # if ''.join(list_key).count('same'* consec_num) > 0 or ''.join(list_key).count('diff' * consec_num) >0:
            if ''.join(list_key).count('low_stim'* consec_num) > 0 or \
            ''.join(list_key).count('med_stim' * consec_num) >0 or \
            ''.join(list_key).count('high_stim' * consec_num) >0:# or \
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
    list_dict = {'low_stim':list_stim1, 'med_stim':list_stim2, 'high_stim':list_stim3}#, 'c4':list_stim4, 'c5':list_stim5, 'c6':list_stim6}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    random.shuffle(list_stim3)

    x = ['low_stim','med_stim', 'high_stim']#, 'c4', 'c5', 'c6']
    list_key  = [item for item in x for i in list(range(trial_per_cond))]
    return list_key, list_dict

def shuffleDataFrame(df_subset, consec_num):
    # https://stackoverflow.com/questions/1624883/alternative-way-to-split-a-list-into-groups-of-n
    list_key, list_dict = generateListKey(stim_per_run)
    list_order = noConsecutiveShuffle(list_key, list_dict, consec_num)
    # 7) sort based on shuffled sequence
    list_order[:] =  [x - 1 for x in list_order]
    cB = df_subset.reindex(list_order)
    cB.reset_index(drop = True, inplace = True)
    return cB

def grouper(n, iterable, fillvalue=None):
    "grouper(3, 'ABCDEFG', 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * n
    return itertools.zip_longest(*args, fillvalue=fillvalue)

def flatten_columns(df, cols):
    """Flattens multiple columns in a data frame, cannot specify all columns!"""
    flattened_cols = {}
    for col in cols:
        flattened_cols[col] = pd.DataFrame([(index, value) for (index, values) in df[col].iteritems() for values in values],
                                           columns=['index', col]).set_index('index')
    flattened_df = df.drop(cols, axis=1)
    for col in cols:
        flattened_df = flattened_df.join(flattened_col[col])
    return flattened_df

# parameters _________________________________________________________________________
cond_type = 6
block = 2
trial_per_cond = 2
stim_per_run = 4
counterbalance_freq = 6 # how many counterbalance versions do you want
ses = [1,3,4]
taskname = 'cognitive'
dir_main = '/Users/h/Documents/projects_local/social_influence'
dir_s02 = os.path.join(dir_main, 'design', 's02_updatejitter')
dir_save = os.path.join(dir_main, 'design','s03_counterbalance')
dir_video = os.path.join(dir_main,'stimuli','task-vicarious_videofps-024_dur-4s','selected')
dir_cue_high = os.path.join(dir_main,'stimuli','cue','task-' + taskname,'sch')
dir_cue_low = os.path.join(dir_main,'stimuli','cue','task-' + taskname,'scl')
# ______________________________________________________________________________
# if files exist in s03, delete
fileList = glob.glob(os.path.join(dir_save,'task-' + taskname + '_counterbalance*.csv'))
# Iterate over the list of filepaths & remove each file.
for filePath in fileList:
    try:
        os.remove(filePath)
    except OSError:
        print("Error while deleting file")

if not os.path.exists(dir_save):
    os.makedirs(dir_save)
# load pandas ____________________________________________
# load 6 counterbalance versions
# 1. [x] concatenate x
# 2. [x] preserve index
# 3. [x] sort based on CUE and STIM
# 4. [x] split 48 stim into 4 groups
# 5. [x] append same diff
# 5. [x] random shuffle cog images
# 6. [ ] resort based on #2

 # 1. concatenate [x]____________________________________________
# from dir_s02
# load all files
# social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-001
# social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-006
# 1 - 6
for grp in range(4):
    # load counterbalance files and concat
    df = pd.DataFrame(); stim_df= pd.DataFrame(); dfs_dict = {}
    li = []
    for ind in range(6):
        cb_ind = 5*ind + (grp+1)
        cb_filename = os.path.join(dir_s02,'social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-' + str('%03d' % cb_ind)+'.csv')
        db_df = pd.read_csv(cb_filename, index_col=None, header=0)
        db_df['block'] = ind + 1
        li.append(db_df)
    df = pd.concat(li, axis=0, ignore_index=True)

    # 2. preserve index ____________________________________________
    df.reset_index(drop=False, inplace = True)

    # 3. sort based on CUE and stim
        # TRIALTYPES ________________________________________________________________________________________
    low_cue = [1,2,3]; high_cue = [4,5,6]
    d_cue = ChainMap(dict.fromkeys(low_cue, 'low_cue'), dict.fromkeys(high_cue, 'high_cue'))
    df['cue'] = df['Trial type'].map(d_cue.get)
    low_stim = [1,4]; med_stim = [2,5]; high_stim = [3,6]
    d_stim = ChainMap(dict.fromkeys(low_stim, 'low_stim'), dict.fromkeys(med_stim, 'med_stim'), dict.fromkeys(high_stim, 'high_stim'))
    df['stimulus_intensity'] = df['Trial type'].map(d_stim.get)
    cb_df = df.sort_values(['cue', 'stimulus_intensity'], ascending=[True, True]).copy()
    cb_df.reset_index(drop = True, inplace = True)

    # 4. # 4. [x] split 48 stim into 4 groups ________________________________________________________________________________________
    # each participant will experience 12 stimuli
    stim_list = list(range(1,49))
    random.shuffle(stim_list)
    groups = list(grouper(int(cond_type* trial_per_cond) , stim_list ))

    # 5. [ ] append same diff ________________________________________________________________________________________
    # build a dataframe
    list_stim_num = np.tile(list(groups[grp]),6) # total blocks
    list_same_diff = np.tile(['same', 'diff'], int(6)) # half block * stimuli per block
    list_diff_same = np.tile(['diff', 'same'], int(6))
    list_cue = np.repeat(['high_cue', 'low_cue'], 12*3)
    list_stim = np.tile(np.repeat(['high_stim', 'low_stim','med_stim'], 12),2)
    # shuffle each block (12) ,     # append,
    sfl1 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_same_diff }); sfl1 = sfl1.sample(frac=1).reset_index(drop=True)
    sfl2 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_same_diff }); sfl2 = sfl2.sample(frac=1).reset_index(drop=True)
    sfl3 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_same_diff }); sfl3 = sfl3.sample(frac=1).reset_index(drop=True)
    sfl4 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_diff_same }); sfl4 = sfl4.sample(frac=1).reset_index(drop=True)
    sfl5 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_diff_same }); sfl5 = sfl5.sample(frac=1).reset_index(drop=True)
    sfl6 = pd.DataFrame({'stim_num':list(groups[grp]).copy(), 'same_diff': list_diff_same }); sfl6 = sfl6.sample(frac=1).reset_index(drop=True)
    cue_stim = pd.DataFrame({'cue':list_cue, 'stimulus_intensity': list_stim })
    a = pd.concat([sfl1,sfl2,sfl3,sfl4,sfl5,sfl6],axis = 0).reset_index(drop = True)#, inplace = True)
    stim_df =pd.concat( [a, cue_stim], axis = 1)

    # 6. merge dataframes ____________________________________________
    # pd.merge doesn't work !!!!!!!
    merged = pd.concat([cb_df, stim_df], axis = 1)
    merged_df = merged.sort_values(['index'], ascending=[True]).copy()
    merged_df = merged_df.iloc[:, :-2]

    # NOTE CUE: shuffle and layer ________________________________________________________________________________________
    high_cue_list = [file for file in os.listdir(dir_cue_high) if file.endswith('.png')]
            # split high into 2 bins - we will use each bin for one block of high cues
    high_sample = random.sample(high_cue_list, int(cond_type*trial_per_cond*3)) # 6 x 2
    random.shuffle(high_sample)

    low_cue_list = [file for file in os.listdir(dir_cue_low) if file.endswith('.png')]
            # split high into 2 bins - we will use each bin for one block of high cues
    low_sample = random.sample(low_cue_list, int(cond_type*trial_per_cond*3)) # 36
    random.shuffle(low_sample)

    h_ind = merged_df.index[merged_df['cue'] == 'high_cue'].tolist()
    l_ind = merged_df.index[merged_df['cue'] == 'low_cue'].tolist()

    merged_df.loc[h_ind, 'cue_image'] = high_sample
    merged_df.loc[l_ind, 'cue_image'] = low_sample

    # reindex and split into 6 chunks ________________________________________________________________________________________
    column_names = ['index', 'block', 'Trial type', 'cue', 'stimulus_intensity',
                'ISI1', 'ISI2', 'ISI3', 'ITI', 'Event1Dur', 'Event2Dur', 'Event3Dur', 'Event4Dur',
                'cue_image', 'stim_num', 'same_diff']

    df = merged_df.reindex(columns=column_names)
    dfs_dict = {j: df[df['block'] == j] for j in df['block'].unique()}
    name_dict = {1: [1, 1],     2: [1, 2],     3: [3, 1],    4: [3, 2],    5: [4, 1],     6: [4, 2]}
    for k, v in dfs_dict.items():
        filename = os.path.join(dir_save,'task-' + taskname + '_counterbalance_ver-' + str('%02d' % int(grp+1))+ '_ses-' + str('%02d' % name_dict[k][0])+'_block-' + str('%02d' % name_dict[k][1]) + '.csv')
        v.to_csv(filename)
# sorted_df.merge(stim_df, on=['cue', 'stimulus_intensity'])
# sorted_df.merge(stim_df, on=['cue', 'stimulus_intensity'], how='left')
# pd.merge(sorted_df, stim_df, left_on=['cue','stimulus_intensity'], how='left')
# shuffle1 = list(groups[grp]).copy();random.shuffle(shuffle1)
# shuffle2 = list(groups[grp]).copy();random.shuffle(shuffle2)
# shuffle3 = list(groups[grp]).copy();random.shuffle(shuffle3)
# df = pd.DataFrame({'A': [shuffle1, shuffle2, shuffle3, shuffle1, shuffle2, shuffle3]})
# df =
# flattened_col = pd.DataFrame([(index, value) for (index, values) in df['A'].iteritems() for value in values],
#                              columns=['index', 'A']).set_index('index')
# df = df.drop('A', axis=1).join(flattened_col)
