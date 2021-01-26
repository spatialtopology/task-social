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
# check consecutive trial types:


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
            # ''.join(list_key).count('c4' * consec_num) >0 or \
            # ''.join(list_key).count('c5' * consec_num) >0 or \
            # ''.join(list_key).count('c6' * consec_num) >0:
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
    # list_stim4 = list(range(trial_per_cond*3+1, trial_per_cond*4+1 ))# e.g. range(8,15)
    # list_stim5 = list(range(trial_per_cond*4+1, trial_per_cond*5+1 ))# e.g. range(8,15)
    # list_stim6 = list(range(trial_per_cond*5+1, trial_per_cond*6+1 ))# e.g. range(8,15)
    list_dict = {'low_stim':list_stim1, 'med_stim':list_stim2, 'high_stim':list_stim3}#, 'c4':list_stim4, 'c5':list_stim5, 'c6':list_stim6}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    random.shuffle(list_stim3)
    # random.shuffle(list_stim4)
    # random.shuffle(list_stim5)
    # random.shuffle(list_stim6)
    x = ['low_stim','med_stim', 'high_stim']#, 'c4', 'c5', 'c6']
    list_key  = [item for item in x for i in list(range(trial_per_cond))]
    return list_key, list_dict

def shuffleDataFrame(df_subset, consec_num):
    list_key, list_dict = generateListKey(stim_per_run)
    list_order = noConsecutiveShuffle(list_key, list_dict, consec_num)
    # 7) sort based on shuffled sequence
    list_order[:] =  [x - 1 for x in list_order]
    cB = df_subset.reindex(list_order)
    cB.reset_index(drop = True, inplace = True)
    return cB


# parameters ____________________________________________
cond_type = 6
trial_per_cond = 2
stim_per_run = 4
counterbalance_freq = 6 # how many counterbalance versions do you want
taskname = 'pain'
dir_main = '/Users/h/Documents/projects_local/social_influence'
dir_s02 = os.path.join(dir_main, 'design', 's02_updatejitter')
dir_save = os.path.join(dir_main, 'design','s03_counterbalance')
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
    # cb_fullpath = '/Users/h/Documents/projects_local/social_influence/design/s02_updatejitter/social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-001.csv'
fileList = glob.glob(os.path.join(dir_s02, 'social_inf*.csv'))
for jitter_file in fileList:
    # load counterbalance file _______________________________
    df = pd.read_csv(jitter_file)
    regex = re.compile(r'\d+')
    jitter_filename = os.path.basename(jitter_file)
    extract_num = [int(x) for x in regex.findall(jitter_filename)]

    # based on counterbalance file number, create counterbalance version / session / block
    remainder = ((extract_num[1] - 1) // 5) ;  #  1,2,3,4,5,6
    cb_ver = (extract_num[1] % 5) # 1 2 3 4 0
    if cb_ver == 0:
        cb_ver = 5
    name_dict = {1: [1, 1],     2: [1, 2],     3: [3, 1],    4: [3, 2],    5: [4, 1],     0: [4, 2]}
    ses = name_dict[remainder][0];     block = name_dict[remainder][1]

    # add columns (cue, high low & stimulus intensity) _______________________________
    low_cue = [1,2,3]; high_cue = [4,5,6]
    d_cue = ChainMap(dict.fromkeys(low_cue, 'low_cue'), dict.fromkeys(high_cue, 'high_cue'))
    df['cue'] = df['Trial type'].map(d_cue.get)

    low_stim = [1,4]; med_stim = [2,5]; high_stim = [3,6]
    d_stim = ChainMap(dict.fromkeys(low_stim, 'low_stim'), dict.fromkeys(med_stim, 'med_stim'), dict.fromkeys(high_stim, 'high_stim'))
    df['stimulus_intensity'] = df['Trial type'].map(d_stim.get)

    #layer in cue images # shuffle low high images separately

    df1 = pd.DataFrame()
    df2 = pd.DataFrame()
    for index, totaldf in enumerate([df1, df2]):
        high_cue_list = [file for file in os.listdir(dir_cue_high) if file.endswith('.png')]
        high_sample = random.sample(high_cue_list, int(cond_type*trial_per_cond/2)) # 6 x 2
        random.shuffle(high_sample)
        low_cue_list = [file for file in os.listdir(dir_cue_low) if file.endswith('.png')]
        # split high into 2 bins - we will use each bin for one block of high cues
        low_sample = random.sample(low_cue_list, int(cond_type*trial_per_cond/2))
        random.shuffle(low_sample)

        h_ind = df.index[df['cue'] == 'high_cue'].tolist()
        l_ind = df.index[df['cue'] == 'low_cue'].tolist()

        df.loc[h_ind, 'cue_image'] = high_sample
        df.loc[l_ind, 'cue_image'] = low_sample
    cb_ver_filename = os.path.join(dir_save,'task-' + taskname + '_counterbalance_ver-' + str('%02d' % int(cb_ver))+ '_ses-' + str('%02d' % ses)+'_block-' + str('%02d' % block) + '.csv')
    df.to_csv(cb_ver_filename)
