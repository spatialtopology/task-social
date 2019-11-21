#!/usr/bin/env python
"""
This code adjusts the jitter files (creates via s02_posner_jitter_sim.m)
so that the total length of the experiment is kept constant across simulations

parameters to tweak:
* main_dir
* total_jitter_length: 240 e.g. 120 trials * average jitter 2s = 240 s
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
total_jitter_length_1 = 72
total_jitter_length_2 = 36
num_trials_to_change1 = 15
num_trials_to_change2 = 5

for ind in range(30):
    # 1) load txt save_filename ________________________________________________
    jitter_filename = os.path.join(main_dir, 's01_jitter',
    'social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-'+str('{0:03d}'.format(ind+1))+'.txt')
    basename = os.path.splitext(ntpath.basename(jitter_filename))[0]
    opti = pd.read_csv(jitter_filename, sep = "\t")

    # 2) round number 2 decimal points ___________________________________
    opti_r = opti.copy()
    opti_r['ISI1'] = opti_r['ISI1'].astype(float).round(decimals=1)
    # 3) calculated sum ________________________________________________________
    total = opti_r['ISI1'].sum()

    # 4) if sum is smaller than 240 sec, _______________________________________
    # randomly select indices and add 240/number _______________________________
    if total < total_jitter_length_1:
        diff = total_jitter_length_1 - total
        increments = diff / num_trials_to_change1
        print(increments)
        subset = opti_r.loc[opti_r.ISI1 > 0.3,].sample(n=num_trials_to_change1)
        subset.ISI1  = subset.ISI1 + increments.round(2)
        for num in range(0,len(subset)):
            opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]

    # 5) if sum is greater than 240 sec, _______________________________________
    # identify those greater than 1.5 and subtract 240/number __________________
    elif total >= total_jitter_length_1:
        diff = abs(total_jitter_length_1-total)
        increments2 = diff / num_trials_to_change1
        print(increments2)
        subset = opti_r.loc[opti_r.ISI1 > 1.5,].sample(n=num_trials_to_change1)
        subset.ISI1  = subset.ISI1 - increments2.round(2)
        for num in range(0,len(subset)):
            opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]

    opti_r['ISI1'] = opti_r['ISI1'].astype(float).round(decimals=1)
    opti_r['ISI1'] = opti_r['ISI1'].apply(lambda x: '{0:0>2}'.format(x))

# ==============================================================================
    opti_r['ISI2'] = opti_r['ISI2'].astype(float).round(decimals=1)
    # 3) calculated sum ________________________________________________________
    total = opti_r['ISI2'].sum()

    # 4) if sum is smaller than 240 sec, _______________________________________
    # randomly select indices and add 240/number _______________________________
    if total < total_jitter_length_2:
        diff = total_jitter_length_2 - total
        increments3 = diff / num_trials_to_change2
        print(increments3)
        subset = opti_r.loc[opti_r.ISI2 > 0.3,].sample(n=num_trials_to_change2)
        subset.ISI2  = subset.ISI2 + increments3.round(2)
        for num in range(0,len(subset)):
            opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]

    # 5) if sum is greater than 240 sec, _______________________________________
    # identify those greater than 1.5 and subtract 240/number __________________
    elif total >= total_jitter_length_2:
        diff = abs(total_jitter_length_2-total)
        increments4 = diff / num_trials_to_change2
        print(increments4)
        subset = opti_r.loc[opti_r.ISI2 > 1.0,].sample(n=num_trials_to_change2)
        subset.ISI2  = subset.ISI2 - increments4.round(2)
        for num in range(0,len(subset)):
            opti_r.iloc[subset.iloc[num].name] = subset.iloc[num]


    # if 0 in ISI2
    # opti_r[(opti_r == 0).all(1)]
    if (opti_r['ISI1'] == 0).any():
        subset = opti_r.loc[opti_r.ISI1 == 0,]
        for ind in list(range(len(subset))):
            opti_r.loc[subset.index[ind], 'ISI1' ] = 0.1
        max = opti_r['ISI1'].idxmax()
        opti_r.loc[max, 'ISI1'] = opti_r.loc[max, 'ISI1']-(0.1*len(subset))
    if (opti_r['ISI2'] == 0).any():
        subset2 = opti_r.loc[opti_r.ISI2 == 0,]
        for ind in list(range(len(subset2))):
            opti_r.loc[subset2.index[ind], 'ISI2'  ] = 0.1
        max2 = opti_r['ISI2'].idxmax()
        opti_r.loc[max2, 'ISI2'] = opti_r.loc[max2, 'ISI2']-(0.1*len(subset2))

# add .1 to every index
# subtract .1 * number of counts from max isi2
    opti_r['ISI2'] = opti_r['ISI2'].astype(float).round(decimals=1)
    opti_r['ISI2'] = opti_r['ISI2'].apply(lambda x: '{0:0>2}'.format(x))


    opti_r.drop("Unnamed: 7", axis=1, inplace=True)
    save_filename = os.path.join(main_dir, 's02_updatejitter', basename + '.csv')
    opti_r.to_csv(save_filename,index=False)
