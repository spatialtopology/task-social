Repository for social influence on pain/vicarious pain/cognitive difficulty

## Pain
* github: https://github.com/canlab/Paradigms_Private/blob/master/PAINGEN_paradigms/TriggerThermode.m

## Vicarious pain
1. original dataset
* UNBC-McMaster Shoulder Pain Expression Archive Database
* http://www.pitt.edu/~emotion/um-spread.htm
* Reference: Lucy, P., Cohn, J. F., Prkachin, K. M., Solomon, P., & Matthrews, I. (2011). Painful data: The UNBC-McMaster Shoulder Pain Expression Archive Database. IEEE International Conference on Automatic Face and Gesture Recognition (FG2011)

2. publication in CANlab
* CANlab publication: 
* CANlab github: https://github.com/canlab/Paradigms_Public/tree/master/inprep_Lanlan_Perceived_pain_gender_bias

3. stimuli in CANlab google drive
* https://drive.google.com/open?id=1w6wBWPvWoPUGIM22g2jW7ynzeiy3S5oB

4. Newly generated videos
	* 1. Generate high low cue png via `create_social_ratings.ipynb`
	* 2. Create videos via `create_videos_96frames.py`
	* 3. Select video via `McMaster_vicarious_videos.ipynb` output: `newversion_final_videos.csv`
	* 4. Move created videos via `mv_videos.py`
	* 5. Counterbalance python via experimentDev > CounterBalance

## Cognitive 
* Mental rotation
* Reference: Ganis, G., & Kievit, R. A. (2015). A New Set of Three-Dimensional Shapes for Investigating Mental Rotation Processes: Validation Data and Stimulus Set. Journal of Open Psychology Data, 3(1), e3. DOI: http://doi.org/10.5334/jopd.ai
* Repository: https://figshare.com/articles/A_new_set_of_three_dimensional_stimuli_for_investigating_mental_rotation_processes/1045385

## To Dos
- [ ] Extract jitters
- [ ] Change movie dimension - 8/19 meeting
- [ ] Change cognitive task duration to 4 sec
- [ ] Split video participants into half
- [ ] Use one for block 1, use the other for block 2
- [ ] Line up cue type "high" low"
- [ ] Line up cue image
- [ ] Line up random order

