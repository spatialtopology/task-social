# identify where cond_type == 1
# keep list of iloc
# assign row information to new column
#

import pandas as pd
import ntpath
import os
import glob
main_dir = '/Users/h/Documents/projects_local/social_influence/design'
cb_fn = os.path.join(main_dir,'counterbalance','task-*_ver*_block*.csv')
cb_list = glob.glob(cb_fn)
# for loop
# load csv file
for ind, cb_filename in enumerate(cb_list):
    basename = ntpath.basename(cb_filename)
    jitter_filename = os.path.join(main_dir,'jitter','social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-'+str('{0:03d}'.format(ind+1))+'.txt')
    opti = pd.read_csv(jitter_filename, sep = "\t")
    counterbalance = pd.read_csv(cb_filename)
    new_counterbalance = pd.concat([counterbalance,opti['ISI1'], opti['ISI2']], axis=1).copy()
    new_counterbalance.to_csv(os.path.join(main_dir,basename ))
