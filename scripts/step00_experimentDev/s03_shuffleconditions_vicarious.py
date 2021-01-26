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
# parameters ____________________________________________
cond_type = 6
block = 2
trial_per_cond = 2
stim_per_run = 4
counterbalance_freq = 6 # how many counterbalance versions do you want
ses = [1,3,4]
taskname = 'vicarious'
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
    # cb_fullpath = '/Users/h/Documents/projects_local/social_influence/design/s02_updatejitter/social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-001.csv'
fileList = glob.glob(os.path.join(dir_s02, 'social_inf*.csv'))

# 1. first split subject list into 3 groups

    # groups 1 2 3, ses 1,3,4
for set in range(5):
    sub_list = ['042-ll042','043-jh043','047-jl047','048-aa048','049-bm049',
                '052-dr052','064-ak064','066-mg066','080-bn080',
                '092-ch092','095-tv095','096-bg096','097-gf097','101-mg101',
                '103-jk103','106-nm106','107-hs107','108-th108','109-ib109',
                '115-jy115','120-kz120','121-vw121','123-jh123','124-dn124']
    random.shuffle(sub_list)
    groups = list(grouper(int(len(sub_list)/len(ses)) , sub_list ))
    for grp in range(3):
        list_block = np.repeat(list(groups[grp]),3)
        list_intensity = np.tile(np.array(['low_stim', 'med_stim', 'high_stim']),len(groups[0]) )
        df_vid = pd.DataFrame({'video_subject': list(list_block), 'stimulus_intensity': list(list_intensity)}, columns=['video_subject', 'stimulus_intensity'])
        # random.shuffle(df_vid)
        df_vid = df_vid.sample(frac=1).reset_index(drop=True)
        # random.shuffle(blocked_sublist)

        # list(grouper(int(len(blocked_sublist)/block), blocked_sublist))

    # 2. each will be allocated to each session 1, 3, 4    # from that, shuffle 8 subject x 3 stim intensity
    # layer that into the counter balance files.    # make sure every group is saved as a set
    # counterbalance_ses-01_block-01;     # counterbalance_ses-01_block-02
        # load 1 & 2: social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-001
        f1_int = 6* set + 2*grp + 1
        f2_int = 6* set + 2*grp + 2
        filename1 = os.path.join(dir_s02,'social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-' + str('%03d' % f1_int)+'.csv')
        filename2 = os.path.join(dir_s02,'social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-'+ str('%03d' % f2_int)+'.csv')
        df_f1 = pd.read_csv(filename1);     df_f2 = pd.read_csv(filename2)
        df_f1['block'] = 1;                 df_f2['block'] = 2
        df = pd.concat([df_f1,df_f2])
        df.reset_index(drop=False, inplace = True)


    # for jitter_file in fileList:
            # df = pd.read_csv(jitter_file)
        # regex = re.compile(r'\d+')
        # jitter_filename = os.path.basename(jitter_file)
        # extract_num = [int(x) for x in regex.findall(jitter_filename)]
            # add columns (cue, high low & stimulus intensity)
    # TRIALTYPES ________________________________________________________________________________________
        low_cue = [1,2,3]; high_cue = [4,5,6]
        d_cue = ChainMap(dict.fromkeys(low_cue, 'low_cue'), dict.fromkeys(high_cue, 'high_cue'))
        df['cue'] = df['Trial type'].map(d_cue.get)

        low_stim = [1,4]; med_stim = [2,5]; high_stim = [3,6]
        d_stim = ChainMap(dict.fromkeys(low_stim, 'low_stim'), dict.fromkeys(med_stim, 'med_stim'), dict.fromkeys(high_stim, 'high_stim'))
        df['stimulus_intensity'] = df['Trial type'].map(d_stim.get)

    # NOTE CUE: shuffle and layer ________________________________________________________________________________________
        high_cue_list = [file for file in os.listdir(dir_cue_high) if file.endswith('.png')]
        # split high into 2 bins - we will use each bin for one block of high cues
        high_sample = random.sample(high_cue_list, int(cond_type*trial_per_cond)) # 6 x 2
        random.shuffle(high_sample)

        low_cue_list = [file for file in os.listdir(dir_cue_low) if file.endswith('.png')]
        # split high into 2 bins - we will use each bin for one block of high cues
        low_sample = random.sample(low_cue_list, int(cond_type*trial_per_cond))
        random.shuffle(low_sample)

        h_ind = df.index[df['cue'] == 'high_cue'].tolist()
        l_ind = df.index[df['cue'] == 'low_cue'].tolist()

        df.loc[h_ind, 'cue_image'] = high_sample
        df.loc[l_ind, 'cue_image'] = low_sample

    # stimulus intensity ________________________________________________________________________________________
        df_sort = df.sort_values(by = 'stimulus_intensity',ascending = True, axis = 0)
        df_sort.reset_index(drop=False, inplace = True)

        df_vsort = df_vid.sort_values(by = 'stimulus_intensity',ascending = True, axis = 0)
        df_vsort.reset_index(drop=False, inplace = True)

        new_df = pd.concat([df_sort, df_vsort[['video_subject','stimulus_intensity']]], axis=1)

        df = new_df.sort_values('level_0').reset_index(drop=True)
        df = df.iloc[:, :-1] # remove duplicate column
    # video filename step 2 ________________________________________________________________________________________
        for ind_img, row in df.iterrows():
            if row.stimulus_intensity == "high_stim":
                image_filepath = row.video_subject.split('-')[1] + '*H.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath
            elif row.stimulus_intensity  == "med_stim":
                image_filepath = row.video_subject.split('-')[1] + '*M.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath
            elif row.stimulus_intensity  == "low_stim":
                image_filepath = row.video_subject.split('-')[1] + '*L.mp4'
                df.loc[ind_img, 'image_glob']  = image_filepath
    # video filename ________________________________________________________________________________________
        for ind_img, row in df.iterrows():
            image_fileglob = glob.glob(os.sep.join([dir_video,row.image_glob]))
            df.loc[ind_img, 'video_filename'] = os.path.split(image_fileglob[0])[1]
                # mainFileName = dir_save + os.sep + 'task-' + taskname + '_mainDesign_notCounterbalanced.csv'

    # split and save as counterbalance version X block 1 and 2

        column_names = ['index', 'block', 'Trial type', 'cue', 'stimulus_intensity',
            'ISI1', 'ISI2', 'ISI3', 'ITI', 'Event1Dur', 'Event2Dur', 'Event3Dur', 'Event4Dur',
            'cue_image', 'video_subject', 'image_glob','video_filename']

        df = df.reindex(columns=column_names)
        df1 = df[df['block'] == 1]
        df2 = df[df['block'] == 2]

        cb1fn = os.path.join(dir_save,'task-' + taskname + '_counterbalance_ver-' + str('%02d' % int(set+1))+ '_ses-' + str('%02d' % ses[grp])+'_block-01.csv')
        cb2fn = os.path.join(dir_save,'task-' + taskname + '_counterbalance_ver-' + str('%02d' % int(set+1))+ '_ses-' + str('%02d' % ses[grp])+'_block-02.csv')
        df1.to_csv(cb1fn);df2.to_csv(cb2fn)
