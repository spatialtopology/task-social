#!/usr/bin/env python
"""
This code adjusts the jitter files (created via s01_social_influence_sim.m)
so that the total length of the experiment is kept constant across simulations

parameters to tweak:
* main_dir
* total_jitter_length_: average jitter * no. trial (e.g. 4.5 sec * 12 trials)
* num_trials_to_change: 10 e.g. adjust jitter for a subset of 10 trials
"""

import pandas as pd
import ntpath
import os
import glob
import numpy as np
from decimal import Decimal

__author__ = "Heejung Jung"
__version__ = "1.0.1"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Production"


# parameters to change _______________________________________________________________________
main_dir = '/Users/h/Documents/projects_local/social_influence/design'
total_jitter_length_ITI = 4.5 * 12# jitter average x No. trial
total_jitter_length_ISI1 = 1.5 * 12# jitter average x No. trial
total_jitter_length_ISI2 = 4.5 * 12# jitter average x No. trial
total_jitter_length_ISI3 = 4.5 * 12# jitter average x No. trial

num_trials_to_change1 = 5


jitter_param = {"ITI": 4.5 * 12,
"ISI1":1.5 * 12,
"ISI2":4.5 * 12,
"ISI3":4.5 * 12 }
for ind in range(30):
    opti = pd.DataFrame()
    diff1 = []; diff2 = []; total = []
    # 1) load txt save_filename ________________________________________________
    jitter_filename = os.path.join(main_dir, 's01_jitter_PVC2',
    'social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-'+str('{0:03d}'.format(ind+1))+'.txt')
    basename = os.path.splitext(ntpath.basename(jitter_filename))[0]
    opti = pd.read_csv(jitter_filename, sep = "\t")

    # 2) round number 2 decimal points ___________________________________
    opti_r = opti.copy()
    for key, total_jitter_length in jitter_param.items():
        opti_r[key] = opti_r[key].astype(float).round(decimals=1)
        # 3) calculated sum ________________________________________________________
        total = opti_r[key].astype(float).sum()

        # 4) if sum is smaller than 240 sec, _______________________________________
        # randomly select indices and add 240/number _______________________________
        if total < total_jitter_length:
            diff1 = total_jitter_length - total
            increments = diff1 / num_trials_to_change1
            print(increments)
            subset = opti_r.loc[opti_r[key] > 0.2,].sample(n=num_trials_to_change1)
            subset[key]  = subset[key] + increments.round(2)
            for num in range(0,len(subset)):
                opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]

        # 5) if sum is greater than 240 sec, _______________________________________
        # identify those greater than 1.5 and subtract 240/number __________________
        elif total >= total_jitter_length:
            # 1) calculate first, how much the total ISI deviates from the goal-ISI
            diff2 = abs(total_jitter_length-total)
            # 2) sort the ISIs and find the spot where the cumulative sum of the ISI becomes greater than diff2
            max_list = opti_r[key].sort_values(ascending = False)
            cumsum_ind = np.where(max_list.cumsum()>diff2+10)[0][0]
            subset_ind = max_list.index.tolist()[:cumsum_ind+2]
            subset = opti_r.iloc[subset_ind]
            # 3) subtract certain amount from ISIs (proportionally based on the ISI/cumsum ISI)
            subset[key]  = subset[key] - ((subset[key]/subset[key].sum())*diff2)
            for num in range(0,len(subset)):
                opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]

        opti_r[key] = opti_r[key].astype(float).round(decimals=1)
        opti_r[key] = opti_r[key].apply(lambda x: '{0:0>2}'.format(x))
    opti_r.drop("Unnamed: 13", axis=1, inplace=True)
    save_filename = os.path.join(main_dir, 's02_updatejitter', basename + '.csv')
    opti_r.to_csv(save_filename,index=False)
