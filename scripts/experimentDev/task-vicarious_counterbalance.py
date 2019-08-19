#!/usr/bin/env python
# encoding: utf-8

import os, shutil, glob
import random
import pandas as pd
import numpy as np
from itertools import groupby
from sklearn.utils import shuffle
import itertools
import ntpath

def noConsecutiveShuffle(list_key, list_dict, consec_num):
    # resource... https://discourse.psychopy.org/t/force-trial-order-reshuffle-until-a-constraint-is-met/2101
    random.shuffle(list_key)
    orderTest=False

    while orderTest == False:
        for i in range(len(list_key)):
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
    list_stim1 = range(1,trial_per_cond+1)   # e.g. range(1,8)
    list_stim2 = range(trial_per_cond+1,trial_per_cond*2+1) # e.g. range(8,15)
    list_stim3 = range(trial_per_cond*2+1, trial_per_cond*3+1 )# e.g. range(1,8)
    list_stim4 = range(trial_per_cond*3+1, trial_per_cond*4+1 )# e.g. range(8,15)
    list_stim5 = range(trial_per_cond*4+1, trial_per_cond*5+1 )# e.g. range(8,15)
    list_stim6 = range(trial_per_cond*5+1, trial_per_cond*6+1 )# e.g. range(8,15)
    list_dict = {'c1':list_stim1, 'c2':list_stim2, 'c3':list_stim3, 'c4':list_stim4, 'c5':list_stim5, 'c6':list_stim6}
    random.shuffle(list_stim1)
    random.shuffle(list_stim2)
    random.shuffle(list_stim3)
    random.shuffle(list_stim4)
    random.shuffle(list_stim5)
    random.shuffle(list_stim6)
    x = ['c1','c2', 'c3', 'c4', 'c5', 'c6']
    list_key  = [item for item in x for i in range(trial_per_cond)]
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
cond_type = 6 # how many conditions are nested under the task
trial_per_cond = 6 # how many trials under one condition
administer_items = ['low', 'med', 'high'] # what rotation degree are we using
counterbalance_freq = 6 # how many counterbalance versions do you want
consec_num = 4
taskname = 'vicarious'
dir_save = '/Users/h/Dropbox/Projects/social_influence/design'
dir_cue_high = '/Users/h/Dropbox/Projects/social_influence/stimuli/cue/task-' + taskname + '/sch'
dir_cue_low = '/Users/h/Dropbox/Projects/social_influence/stimuli/cue/task-' + taskname + '/scl'
# dir_video = '/Users/h/Dropbox/Projects/socialPain/stimuli/36_videos_lanlan'
dir_video = '/Users/h/Dropbox/Projects/social_influence/stimuli/task-vicarious_videofps-024_dur-4s/selected/'
# ______________________________________________________________________________

# if task-cognitive_counterbalance_ver-01_block-01.csv exists, delete
fileList = glob.glob(os.sep.join([dir_save, "task-" + taskname + "_counterbalance*_HML.csv"]))
# Iterate over the list of filepaths & remove each file.
for filePath in fileList:
    try:
        os.remove(filePath)
    except OSError:
        print("Error while deleting file")



# 1. shuffle 12 subject sequences ____________________

# sub_list = ['bn080', 'dn124', 'hs107', 'ht108', 'll042', 'mn106', 'ak064', 'bg096', 'dr052', 'ib109', 'jk103', 'kz120']

# participant '059-fn059', has only 2 videos
for cB_ver in range(1,counterbalance_freq):
    list1 = []
    list2 = []
    for x in range(0,3):
        sub_list = ['042-ll042','043-jh043','047-jl047','048-aa048','049-bm049',
        '052-dr052','064-ak064','066-mg066','080-bn080',
        '092-ch092','095-tv095','096-bg096','097-gf097','101-mg101',
        '103-jk103','106-nm106','107-hs107','108-th108','109-ib109',
        '115-jy115','120-kz120','121-vw121','123-jh123','124-dn124']
        random.shuffle(sub_list)
        half1 = sub_list[:int(len(sub_list)/2)] #[:24] # block 1 or 2
        half2 = sub_list[int(len(sub_list)/2):] #[24:] # block 1 or 2
        list1.append(half1)
        list2.append(half2)
    # list_newShuffle = list1*3 + list2*3
    flattenlist1 = list(itertools.chain(*list1))
    flattenlist2 = list(itertools.chain(*list2))
    df1 = pd.DataFrame(flattenlist1)
    df2 = pd.DataFrame(flattenlist2)

    # shuffle high/low cues ________________________________________________________
    # grab stimuli list (only allow png files in the list)
    high_cue_list = [file for file in os.listdir(dir_cue_high) if file.endswith('.png')]
    # split high into 2 bins - we will use each bin for one block of high cues
    high_sample = random.sample(high_cue_list, cond_type*trial_per_cond/2)
    random.shuffle(high_sample)

    low_cue_list = [file for file in os.listdir(dir_cue_low) if file.endswith('.png')]
    # split high into 2 bins - we will use each bin for one block of high cues
    low_sample = random.sample(low_cue_list, cond_type*trial_per_cond/2)
    random.shuffle(low_sample)


    for ind, sub_list in enumerate([flattenlist1, flattenlist2]):
        df = pd.DataFrame()
        # flattenlist = list(itertools.chain(*sub_longList))
        # flattenlist = list(itertools.chain(*list_obj1)) #list 1 or list 2
        # randomly shuffle videos
        df['video_subject'] = sub_list # (OR LIST 2)
        # # 2. create video list ________________________________________________________
        # df['administer'] = np.tile( np.repeat(administer_items,len(df)/len(administer_items)/3),3)
        df['administer'] = np.repeat(administer_items,12)
        # 4. created cue list __________________________________________________________
        df['cue_type'] =  np.tile(['high', 'low'], len(df)/2)
        df.loc[::2,'cue_image']  = high_sample#high_cue[index]
        df.loc[1::2,'cue_image'] = low_sample#low_cue[index]
        df['random_order'] = range(len(df))
        df_reset = df.reset_index()

        # 5. calculated trial type _____________________________________________________
        df['cond_type'] = ((df.cue_type == 'low') & (df.administer == administer_items[0])).astype(int) * 1 + \
            ((df.cue_type == 'high') & (df.administer == administer_items[0])).astype(int) * 2 + \
            ((df.cue_type == 'low') & (df.administer == administer_items[1])).astype(int) * 3 + \
            ((df.cue_type == 'high') & (df.administer == administer_items[1])).astype(int) * 4 +\
            ((df.cue_type == 'low') & (df.administer == administer_items[2])).astype(int) * 5 + \
            ((df.cue_type == 'high') & (df.administer == administer_items[2])).astype(int) * 6
        df['condition_name'] = np.repeat([taskname], len(df))
        df['condition_num_filled_in_during_exper'] = 99

        # image name _____________________________________________________
        for ind_img, row in df.iterrows():
            if row.administer == "high":
                image_filepath = row.video_subject.split('-')[1] + '*H.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath
            elif row.administer  == "med":
                image_filepath = row.video_subject.split('-')[1] + '*M.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath
            elif row.administer  == "low":
                image_filepath = row.video_subject.split('-')[1] + '*L.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath

        for ind_img, row in df.iterrows():
            image_fileglob = glob.glob(os.sep.join([dir_video,row.image_glob]))
            df.loc[ind_img, 'video_filename'] = os.path.split(image_fileglob[0])[1]
            print image_fileglob
        # split DataFrame
        mainFileName = dir_save + os.sep + "task-" + taskname + "_mainDesign_notCounterbalanced_block-" + str('%02d' % ind) + ".csv"
        df.to_csv(mainFileName)

    # df1 = df.iloc[:, :len(df)/2]
    # df2 = df.iloc[:, len(df)/2:]
    # for index, df in enumerate([df1, df2]):

        cB = shuffleDataFrame(df, consec_num)
        cB['cB_version'] = cB_ver # assign from for loop number
        cBverFileName = dir_save + os.sep + \
        "task-" + taskname + "_counterbalance_ver-" + str('%02d' % cB_ver)+ \
         "_block-" +str('%02d' % int(index+1)) +".csv"
        cB.to_csv(cBverFileName)
