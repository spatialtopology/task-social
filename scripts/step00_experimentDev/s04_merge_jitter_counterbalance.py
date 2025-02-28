# identify where cond_type == 1
# keep list of iloc
# assign row information to new column
#

import pandas as pd
import ntpath
import os
import glob
main_dir = '/Users/h/Documents/projects_local/social_influence/design'
cb_fn = os.path.join(main_dir,'s03_counterbalance','task-*_ver*_block*.csv')
cb_list = glob.glob(cb_fn)
# for loop
# load csv file
for ind, cb_filename in enumerate(cb_list):
    basename = ntpath.basename(cb_filename)
    jitter_filename = os.path.join(main_dir,'s02_updatejitter','social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-'+str('{0:03d}'.format(ind+1))+'.csv')
    opti = pd.read_csv(jitter_filename)
    counterbalance = pd.read_csv(cb_filename)

    # sort opti based on trialtype
    opti.sort_values(by=['Trial type'])
    # sort counterbalance based on trialtype
    counterbalance.sort_values(by=['cond_type'])
    #sort counterbalance based on "index"
    # counterbalance.insert(1, "trial_order", list(range(1,len(counterbalance)+1)),True )
    new_counterbalance = pd.concat([counterbalance,opti['ISI1'], opti['ISI2']], axis=1).copy()
    new_counterbalance.sort_values(by=['Unnamed: 0'])
    # new_counterbalance.drop("Unnamed: 0", axis=1, inplace=True)
    new_counterbalance.rename(columns={'Unnamed: 0':'trial_order'},
                 inplace=True)
    new_counterbalance.to_csv(os.path.join(main_dir,'s04_final_counterbalance_with_jitter', basename ))
