# power simulation

## best design generation
RUN_jitter_type01.m >> generate_jitter_type01.m

### RUN_jitter_type01
* 72 regressors
* 25 contrasts of interest
* 2s JITTER1 /  1s cue / 4s expectRating / 1s JITTER2 / 6.5s stimuli / 4s judgment

### RUN_jitter_type02
* 72 regressors (3condition x 2cue x 3stimulus_intensity x 4events)
* 25 contrasts of interests
* 5s JITTER1 /  1s cue / 4s expectRating / 5s JITTER2 / 6.5s stimuli / 4s judgment

### RUN_jitter_type03
* 18 regressors (2cue x 3stimulus_intensity x 3events)
* 25 contrasts of interests
* 2s JITTER1 /  1s cue / 4s expectRating / 1s JITTER2 / 9s stimuli / 1.5s JITTER3 / 4s judgment

### RUN_jitter_type04 - realized a bug in the code. Trialtypes should be 24 instead of 18. Will re-run on 1/15 and push.
* 24 regressors (2cue x 3stimulus_intensity x 4events)
* 25 contrasts of interests
* 36 trial per condition
* 2.5s JITTER1 /  1s cue / 2.5s JITTER2 / 4s expectRating / 2.5s JITTER3 / 6.5s stimuli / 2.5s JITTER4 / 4s judgment

### RUN_jitter_type05
* 18 regressors (3condition x 2cue x 3stimulus_intensity x 4events)
* 25 contrasts of interests
* 1 trial per condition
* 2.5s JITTER1 /  1s cue / 2.5s JITTER2 / 4s expectRating / 2.5s JITTER3 / 6.5s stimuli / 2.5s JITTER4 / 4s judgment


## output file from each `RUN_jitter_type##.m`
* ~/social_influence/design_interleaved/jitter_type##/
* best_design_struct.mat
* best_design_struct_under_idealLength.mat
* social_inf_Events_best_design_of_10000_ver-001.txt
* social_inf_Events_best_design_of_10000_under_ideal_length_sec_ver-001.txt
