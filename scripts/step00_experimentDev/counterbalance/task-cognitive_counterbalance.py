#!/usr/bin/env python
# encoding: utf-8

import os, shutil, glob
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

def generateListKey(trial_per_cond):
    list_stim1 = list(range(1,trial_per_cond+1)) + list(range(trial_per_cond*2+1, trial_per_cond*3+1 )) + list(range(trial_per_cond*4+1, trial_per_cond*5+1 ))# e.g. range(1,8)
    list_stim2 = list(range(trial_per_cond+1,trial_per_cond*2+1)) + list(range(trial_per_cond*3+1, trial_per_cond*4+1 )) + list(range(trial_per_cond*5+1, trial_per_cond*6+1 ))## e.g. range(8,15)
    list_dict = {'same':list_stim1, 'diff':list_stim2}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    x = ['same','diff']
    list_key  = [item for item in x for i in range(trial_per_cond*3)]
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
total_block = 2 # how many repeated blocks of this "cognitive" task
administer_items = [50, 100, 150] # what rotation degree are we using
cue_items = ['low', 'high']
counterbalance_freq = 6 # how many counterbalance versions do you want
cond_type = len(administer_items) * len(cue_items)  # 6: how many conditions are nested under the task
trial_per_cond = 6 # how many trials under one condition
consec_num = 4
taskname = 'cognitive'
dir_main = '/Users/h/Documents/projects_local/social_influence'
dir_save = os.path.join(dir_main, 'design','counterbalance')
dir_cue_high = os.path.join(dir_main,'stimuli','cue','task-' + taskname,'sch')
dir_cue_low = os.path.join(dir_main,'stimuli','cue','task-' + taskname,'scl')
# ______________________________________________________________________________

# if task-cognitive_counterbalance_ver-01_block-01.csv exists, delete
fileList = glob.glob(os.sep.join([dir_save, "task-cognitive_counterbalance*.csv"]))
# Iterate over the list of filepaths & remove each file.
for filePath in fileList:
    try:
        os.remove(filePath)
    except OSError:
        print("Error while deleting file")

if not os.path.exists(dir_save):
    os.makedirs(dir_save)


# 1. choose 24 numbers out of 48 and create stimuli columns ____________________
num_select = []

num_select = random.sample(range(1,49),  int(cond_type*trial_per_cond/len(administer_items)*total_block))
num_sort = sorted(num_select)
list_random = random.sample(num_sort, len(num_sort))

list1 = list_random[:int(len(list_random)/2)] #[:12] # block 1 or 2
list2 = list_random[int(len(list_random)/2):] #[12:] # block 1 or 2
list_newShuffle = list1*3 + list2*3
df1 = pd.DataFrame(random.sample(list1,len(list1))  +random.sample(list1,len(list1))  +random.sample(list1,len(list1))  )
df2 = pd.DataFrame(random.sample(list2,len(list2))  +random.sample(list2,len(list2))  +random.sample(list2,len(list2))  )
df = pd.DataFrame()
# shuffle high/low cues ________________________________________________________
# grab stimuli list (only allow png files in the list)
high_cue_list = [file for file in os.listdir(dir_cue_high) if file.endswith('.png')]
# split high into 2 bins - we will use each bin for one block of high cues
high_sample = random.sample(high_cue_list, int(cond_type*trial_per_cond) )
random.shuffle(high_sample)
hCue1 = high_sample[:int(len(high_sample)/2)]
hCue2 = high_sample[int(len(high_sample)/2):]
high_cue = [hCue1, hCue2]
low_cue_list = [file for file in os.listdir(dir_cue_low) if file.endswith('.png')]
# split high into 2 bins - we will use each bin for one block of high cues
low_sample = random.sample(low_cue_list, int(cond_type*trial_per_cond) )
random.shuffle(low_sample)
lCue1 = low_sample[:int(len(low_sample)/2)]
lCue2 = low_sample[int(len(low_sample)/2):]
low_cue = [lCue1, lCue2]
for index, df in enumerate([df1, df2]):



    # randomly shuffle high cues and assign to high rows
    df.columns = ['stimuli_num']

    # 2. create degree list ________________________________________________________
    df['administer'] = np.repeat(administer_items,len(df)/len(administer_items)) # add column 50/100

    # 3. create same different column ______________________________________________
    df['match'] = np.repeat(['same', 'different', 'same', 'different','same', 'different'], trial_per_cond) # add column same/different

    # 4. created cue list __________________________________________________________
    df['cue_type'] = np.resize(['high', 'low'], cond_type*trial_per_cond)
    df.loc[::2,'cue_image']  = high_cue[index]
    df.loc[1::2,'cue_image'] = low_cue[index]
    df['random_order'] = range(len(df))
    df_reset = df.reset_index()


    # 5. calculated trial type _____________________________________________________
    df['cond_type'] = ((df.cue_type == 'low') & (df.administer == administer_items[0])).astype(int) * 1 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[0])).astype(int) * 2 + \
        ((df.cue_type == 'low') & (df.administer == administer_items[1])).astype(int) * 3 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[1])).astype(int) * 4 +\
        ((df.cue_type == 'low') & (df.administer == administer_items[2])).astype(int) * 5 + \
        ((df.cue_type == 'high') & (df.administer == administer_items[2])).astype(int) * 6
    df['condition_name'] = np.repeat(['cognitive'], len(df))
    df['condition_num_filled_in_during_exper'] = 99
    df['block_num'] = int(index+1)

    for ind_img, row in df.iterrows():
        if df.loc[ind_img,'match'] == "different":
            image_filepath = str(df.loc[ind_img,'stimuli_num']) + '_' + str(df.loc[ind_img,'administer']) + '_R.jpg'
            df.loc[ind_img,'image_filename'] = image_filepath
                # row.imageFileName = imageFilePath
        elif df.loc[ind_img,'match'] == "same":
            image_filepath = str(df.loc[ind_img,'stimuli_num']) + '_' + str(df.loc[ind_img,'administer']) + '.jpg'
            df.loc[ind_img,'image_filename'] = image_filepath

    mainFileName = dir_save + os.sep + 'task-cognitive_mainDesign_notCounterbalanced.csv'
    df.to_csv(mainFileName)

    for cB_ver in range(1,counterbalance_freq):
        cB = shuffleDataFrame(df, consec_num)
        cB['cB_version'] = cB_ver # assign from for loop number
        cBverFileName = dir_save + os.sep + \
        'task-cognitive_counterbalance_ver-' + str('%02d' % cB_ver)+ \
         '_block-' +str('%02d' % int(index+1)) +'.csv'
        cB.to_csv(cBverFileName)
# 6. save main dataframe file - not counterbalanced ____________________________
# task-cognitive_mainDesign_notCounterbalanced.csv


# 7. split dataframes into two blocks and counterbalance _______________________

    # df_subset1 = pd.DataFrame()
    # df_subset2 = pd.DataFrame()
    # # 1) split dataframes
    # random_select1 = random.sample(range(14), 7)
    # random_select2 = random.sample(range(14,27), 7)
    # random_total = random_select1 + random_select2
    # random_total.sort()
    # df_subset1 = df.loc[random_total]
    # df_subset1.reset_index(drop = True, inplace = True)
    # random_other = np.setdiff1d(range(28),random_total)
    # df_subset2 = df.loc[random_other]
    # df_subset2.reset_index(drop = True, inplace = True)
    # 2) shuffle each bin with the function  ___________________________________
    # for index, df_subset in enumerate([df_subset1, df_subset2]):

        # b) save counterbalanced versions ____________________________________________
        # filename example: task-cognitive_counterbalance_ver-06_block-01.csv
