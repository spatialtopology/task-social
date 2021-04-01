# Repository for social influence on <br/>[1. pain](##pain)<br/>[2. vicarious pain](##vicarious-pain)<br/>[3. cognitive difficulty](##cognitive)<br/>

## run code from scripts > step01_taskscripts

![socialinfluence](https://github.com/spacetop-admin/figures/blob/master/fig_socialinfluence.png)


--- 

# Stimuli description
## I. pain
* code from github: https://github.com/canlab/Paradigms_Private/blob/master/PAINGEN_paradigms/TriggerThermode.m
* ATS. @Boulder rm173 socialinfluence48, socialinfluence49, socialinfluence50
* temperature can go up by 10 degrees per second, Thus plateau must vary.
* 48 C: baseline 36, rate 10, 1.6 sec plateau
* 49 C: baseline 36, rate 10, 1.4 sec plateau
* 50 C: baseline 36, rate 10, 1.2 sec plateau

## II. vicarious-pain
1. original dataset
	* UNBC-McMaster Shoulder Pain Expression Archive Database
	* http://www.pitt.edu/~emotion/um-spread.htm
	* **Reference**: Lucy, P., Cohn, J. F., Prkachin, K. M., Solomon, P., & Matthrews, I. (2011). Painful data: The UNBC-McMaster Shoulder Pain Expression Archive Database. IEEE International Conference on Automatic Face and Gesture Recognition (FG2011)

2. Newly generated videos (run code as indicated bellow)
	1. Generate high low cue png via `create_social_ratings.ipynb`
	2. Create videos via `create_videos_96frames.py`
	3. Select video via `McMaster_vicarious_videos.ipynb` output: `newversion_final_videos.csv`
	4. Move created videos via `mv_videos.py`
	5. Counterbalance python via experimentDev > CounterBalance

3. Other
	1. publication in CANlab
		* CANlab publication:
		* CANlab github: https://github.com/canlab/Paradigms_Public/tree/master/inprep_Lanlan_Perceived_pain_gender_bias

	2. stimuli in CANlab google drive
		* https://drive.google.com/open?id=1w6wBWPvWoPUGIM22g2jW7ynzeiy3S5oB

## III. cognitive
* Mental rotation task
* **Reference**: Ganis, G., & Kievit, R. A. (2015). A New Set of Three-Dimensional Shapes for Investigating Mental Rotation Processes: Validation Data and Stimulus Set. Journal of Open Psychology Data, 3(1), e3. DOI: http://doi.org/10.5334/jopd.ai
* Repository: https://figshare.com/articles/A_new_set_of_three_dimensional_stimuli_for_investigating_mental_rotation_processes/1045385

---

# Data storage
* behavioral: 
* biopac: 
* imaging: 

---

# Analysis

---

## To Dos
- [x] Pain: 4s duration
- [ ] Documentation: update code description
- [ ] Documentation: update spatialtopology.github.io



