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
    # sub_dir_list = list_without_dsstore(PSPI_dir)
    # # participant folder
    # for s_ind, sub_dir in enumerate(sub_dir_list):
    #     sub_name = sub_dir.split('-')[1]
    #     au_folder = list_without_dsstore(os.sep.join([PSPI_dir,  sub_dir]))
    #
    #     for a_ind, a_dir in enumerate(au_folder):
    # path = os.sep.join([PSPI_dir,  sub_dir, a_dir, '*.txt'])
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
    ####### MUST DO
    ####### MUST DO
    ####### MUST DO
    # create images with 96 frames
    # IF max_ind is greater than 48,
    # grab max_ind-47 ~ max_ind + 48
    if max_ind  > 48:
        new_images = images[max_ind-48:max_ind+48]
    # ELSE max_ind is less than 48,
    # grab 0 ~ 95
    elif max_ind  <=48:
        new_images = images[0:96]

    ####### MUST DO
    ####### MUST DO
    ####### MUST DO
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

subjects = ['101-mg101','103-jk103','106-nm106',
'107-hs107','108-th108','109-ib109','115-jy115','120-kz120','121-vw121',
'123-jh123','124-dn124']
# '042-ll042','043-jh043','047-jl047','048-aa048','049-bm049',
# '052-dr052','059-fn059','064-ak064','066-mg066','080-bn080','092-ch092',
# '095-tv095','096-bg096','097-gf097',

# list of participants LOOP
# for subnum_folder in os.listdir(main_dir):
#     if not subnum_folder.startswith('.'): # removing .ds_stores
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





# ______ 8< ____________________________________________________________________
        # for af_fldr in os.listdir(individual_video_list):
        # # individual_video_dir = '~/vicariousBackPainVideos/Images/124-dn124/dn124t1aaaff'
        #     if not af_fldr.startswith('.'): # removing .ds_stores
        #         ind_video_dir = os.path.join(individual_video_list, af_fldr)
        #         #### '~/vicariousBackPainVideos/Images/124-dn124/dn124t1aiaff'
        #         for file in os.listdir(ind_video_dir): # dn124t1aaaff
        #             if not file.startswith('.') and file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith("png"):
        #                 num_of_images = len(os.listdir(ind_video_dir)) # dn124t1aiaff420.png
        #                 im = Image.open(os.path.join(ind_video_dir, file))
        #                 width, height = im.size
        #                 mean_width += width
        #                 mean_height += height
        #                         # im.show()   # uncomment this for displaying the image
        #
        #             # Finding the mean height and width of all images.
        #             # This is required because the video frame needs
        #             # to be set with same width and height. Otherwise
        #             # images not equal to that width height will not get
        #             # embedded into the video
        #         mean_width = int(mean_width / num_of_images)
        #         mean_height = int(mean_height / num_of_images)
        #
        #             # print(mean_height)
        #             # print(mean_width)
        #
        #             # Resizing of the images to give
        #             # them same width and height
        #         for file in os.listdir(ind_video_dir):
        #             if not file.startswith('.') and file.endswith(".jpg") or file.endswith(".jpeg") or file.endswith("png"):
        #                 # opening image using PIL Image
        #                 im = Image.open(os.path.join(ind_video_dir, file))
        #
        #                 # im.size includes the height and width of image
        #                 width, height = im.size
        #                 print(width, height)
        #
        #                     # resizing
        # new_resize_dir = os.path.join(new_main_dir, subnum_folder, af_fldr + '_resized')
        #                 if not os.path.exists(new_resize_dir):
        #                     os.makedirs(new_resize_dir)
        #                 new_resize_filename = os.path.join(new_resize_dir, file)
        #                 imResize = im.resize((mean_width, mean_height), Image.ANTIALIAS)
        #                 imResize.save( new_resize_filename, 'JPEG', quality = 95) # setting quality
        #                         # printing each resized image name
        #                 print(im.filename.split('\\')[-1], " is resized")
    # ________________________________________________________________________________
