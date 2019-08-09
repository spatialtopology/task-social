# importing libraries
import os
import cv2
from PIL import Image
import glob

# code from ___________________________________________________________________
# https://www.geeksforgeeks.org/python-create-video-using-multiple-images-using-opencv/
# ______________________________________________________________________________

# parameters ___________________________________________________________________
main_dir = '/Users/h/Dropbox/Projects/socialPain/sandbox/resources/vicariousBackPainVideos/Images'
fps = 24 # frames per second
fourcc = cv2.VideoWriter_fourcc(*'mp4v')
# fourcc_out = cv2.VideoWriter_fourcc(*'avc1')
new_main_dir = '/Users/h/Dropbox/Projects/socialPain/stimuli/task-vicarious_videofps-' + '%03d' % fps + '_dur-4s'
# ______________________________________________________________________________


# Video Generating function ____________________________________________________
def generate_video(image_folder, video_name, save_dir, fps, fourcc, subnum_folder, af_fldr):

    images = [img for img in os.listdir(image_folder)
              if img.endswith(".jpg") or
                 img.endswith(".jpeg") or
                 img.endswith("png")]

# identify max PSPI
    PSPI_dir = '/Users/h/Dropbox/Projects/socialPain/sandbox/resources/vicariousBackPainVideos/Frame_Labels/PSPI'
    PSPI_path = os.path.join(PSPI_dir, subnum_folder, af_fldr)
    path = os.sep.join([PSPI_path, '*.txt'])

    sub_name = subnum_folder.split('-')[1]
    aafff = af_fldr.replace(sub_name, '').replace('.txt', '')
    files = glob.glob(path)
    max_pspi = []
    for name in files:
        try:
            with open(name) as f:
                for line in f:
                    max_pspi.append(line.split())
        except IOError as exc: #Not sure what error this is
            if exc.errno != errno.EISDIR:
                raise
    max_ind = max_pspi.index(max(max_pspi))

    # create images with 96 frames around maximum PSPI
    if max_ind  > 48:
        new_images = images[max_ind-48:max_ind+48]
    elif max_ind  <=48:
        new_images = images[0:96]
    # Array images should only consider the image files ignoring others if any
    frame = cv2.imread(os.path.join(image_folder, new_images[0]))

    # setting the frame width, height width
    # the width, height of first image
    height, width, layers = frame.shape
    full_path = os.path.join(save_dir, video_name)
    video = cv2.VideoWriter(full_path, fourcc, fps, (width, height))

    # Appending the images to the video one by one
    for image in new_images:
        video.write(cv2.imread(os.path.join(image_folder, image)))

    # Deallocating memories taken for window creation
    cv2.destroyAllWindows()
    video.release()  # releasing the video generated



# 1. resizing images______________________________________________________________________________
# Checking the current directory path

subjects = ['042-ll042','043-jh043','047-jl047','048-aa048','049-bm049',
'052-dr052','059-fn059','064-ak064','066-mg066','080-bn080','092-ch092',
'095-tv095','096-bg096','097-gf097','101-mg101','103-jk103','106-nm106',
'107-hs107','108-th108','109-ib109','115-jy115','120-kz120','121-vw121',
'123-jh123','124-dn124']

for subnum, sub_fldr in enumerate(subjects):
    individual_video_list = os.sep.join([main_dir, sub_fldr]) # individual_video_list example : '~/vicariousBackPainVideos/Images/042-ll042'
    for af_fldr in os.listdir(individual_video_list):
        if not af_fldr.startswith('.'): # removing .ds_stores
            ind_video_dir = os.path.join(individual_video_list, af_fldr) # individual_video_list example : '~/vicariousBackPainVideos/Images/042-ll042'
            new_af_dir = os.path.join(new_main_dir, sub_fldr )
            if not os.path.exists(new_af_dir):
                os.makedirs(new_af_dir)
# 2. generating videos ___________________________________________________________________
# Calling the generate_video function
            video_name = af_fldr + '.mp4'
            save_dir = os.sep.join([new_main_dir, sub_fldr])
            generate_video(ind_video_dir, video_name, save_dir, fps, fourcc, sub_fldr, af_fldr)
# ______________________________________________________________________________
