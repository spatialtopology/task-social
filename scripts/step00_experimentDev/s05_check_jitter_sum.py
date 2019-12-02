#!/usr/bin/env python

"""
This code first counterbalances the number of cue and targets,
based on the valid/invalid sequence from s01_AR_seq_generator.m

second, the updated jitters will be concatenated
to form a full counterbalance csv file.
"""

import os
import pandas as pd
import numpy as np
from collections import Counter
import random
import glob
import ntpath

__author__ = "Heejung Jung"
__version__ = "1.0.1"
__email__ = "heejung.jung@colorado.edu"
__status__ = "Production"


# Parameters _______________________________________________________________________
main_dir = '/Users/h/Documents/projects_local/social_influence/design'

cb_fn = os.path.join(main_dir,'s04_final_counterbalance_with_jitter','task-*_ver*_block*.csv')
cb_list = glob.glob(cb_fn)
# for loop
# load csv file
output = pd.DataFrame()
output = pd.DataFrame(0, index=np.arange(len(cb_list)), columns=['sum_ISI1', 'sum_ISI2'])
output.columns = ['sum_ISI1', 'sum_ISI2']
for ind, cb_filename in enumerate(cb_list):
    basename = ntpath.basename(cb_filename)
    p = pd.read_csv(cb_filename)
    output.loc[ind,'sum_ISI1']  = np.sum(p['ISI1'])
    output.loc[ind,'sum_ISI2']  = np.sum(p['ISI2'])


output_filename = os.path.join(main_dir, 's05_checkjitter', 'total-jitter_task-posner_counterbalance.csv')
output.to_csv(output_filename)
