#!/usr/bin/env python3

# In this file, I collect all the functions introduced in the accompanying tutorial.
# Documentation is due for another day.
#
# Note that this might be well converted to a custom image `class`.

import os as os # operation system commands
import numpy as np # numerics, e.g. image array manipulation
import pandas as pd # data frames

import scipy.ndimage as ndi # more array manipulation
import scipy.signal as sig # signal processing (stay tuned!)

# some of the many useful modules of the skimage library
import skimage.io as skiio
import skimage.color as skicol
import skimage.filters as skifilt
import skimage.morphology as skimorph
import skimage.measure as skimeas
import skimage.segmentation as skiseg
import skimage.transform as skitrafo
import skimage.util as skiutil


### Basic Functions ###


def LoadImage(filepath):
    img = skiio.imread(filepath)
    return (skiutil.img_as_float(img))


def ExtractChannel(img, i):
    return(img[:, :, i])


def ImageToHSV(img_rgb):
    return(skicol.rgb2hsv(img_rgb))


def ExtractValue(img):
    return(ExtractChannel(ImageToHSV(img), 2))


def ValueInvertSingleChannel(channel):
    return(1.-channel)


def Blur(img, *args, **kwargs):
    return(skifilt.gaussian(img, *args, **kwargs))


### Coarse Feature Extraction ###


def ExtractPetriDish(newt_img, thresh = 0.98, rect = 5):

    mod = ExtractValue(newt_img) # the "V"=value channel

    bw = skimorph.closing(mod > thresh,
            skimorph.footprint_rectangle((rect, rect)))

    # label image regions
    label_image = skimorph.label(bw)

    biggest = np.argmax([region.area \
        for region in skimeas.regionprops(label_image)])

    dish_mask = skimorph.convex_hull_image(label_image == int(1+biggest))

    return(dish_mask)


def MaskPetriDish(newt_img):
    dish_mask = ExtractPetriDish(newt_img)

    img_masked = ExtractValue(newt_img) # the "V"=value channel
    img_masked[np.logical_not(dish_mask)] = 1.

    return(img_masked)


def FindTheNewt(newt_img):

    # note that this is similar to the "ExtractPetriDish" procedure,
    # just a preprocessed starting image and a different threshold.

    mod = 1. - MaskPetriDish(newt_img)

    # apply threshold
    thresh = skifilt.threshold_otsu(mod) # good old otsu :)
    bw = skimorph.closing(mod > thresh,
                          skimorph.footprint_rectangle((17, 17)))

    # label image regions
    label_image = skimorph.label(bw)
    biggest = np.argmax([region.area for region in skimeas.regionprops(label_image)])
    newt_mask = label_image == int(1+biggest)

    return(newt_mask)



### Cropping ###


def get_bbox(mask):
    mask_coords = np.stack(np.where(mask), axis = 1)
    bbox = {
        "min_x": np.min(mask_coords[:, 0]),
        "max_x": np.max(mask_coords[:, 0]),
        "min_y": np.min(mask_coords[:, 1]),
        "max_y": np.max(mask_coords[:, 1])
    }
    return(bbox)

def extend_bbox(bbox, pixels = 0):
    return {key: bound + (-1 if "min" in key else +1) * pixels \
            for key, bound in bbox.items()}


def crop(img, bx):
    if len(img.shape) == 3:
        return(img[bx["min_x"]:bx["max_x"], bx["min_y"]:bx["max_y"], :])
    if len(img.shape) == 2:
        return(img[bx["min_x"]:bx["max_x"], bx["min_y"]:bx["max_y"]])

def crop_mask(img, mask, return_crop_mask = False, extend_px = 0):
    bbox = extend_bbox(get_bbox(mask), extend_px)
    cropped_img = crop(img, bbox)

    if return_crop_mask:
        cropped_mask = crop(mask, bbox)
        return(cropped_img, cropped_mask)

    return cropped_img



### detail ROI ###


def CropTheNewt(newt_img):

    newt_mask = FindTheNewt(newt_img)

    cropped_newt, cropped_mask = crop_mask(newt_img, newt_mask, return_crop_mask = True, extend_px = 100)

    return (cropped_newt, cropped_mask)


def FindYellowBelly(newt_img):

    cropped_newt, cropped_mask = CropTheNewt(newt_img)

    # yellow is well visible in "saturation" (S of HSV)
    saturation = ExtractChannel(ImageToHSV(cropped_newt), 1)

    otsu = skifilt.threshold_otsu(saturation)

    blurred_saturation = Blur(saturation, sigma = 4)


    bins, edges = np.histogram(blurred_saturation.ravel(), bins = 256)
    histogram_change = np.diff(bins)


    # this still is a rather hacky heuristic
    # based on histogram peak detection
    downbins = sig.argrelmin(histogram_change)[0]
    downbin_values = histogram_change[downbins]
    right_ramp_bin = downbins[downbin_values < -5000][-1]

    threshold = edges[right_ramp_bin] + 0.1 # CAREFUL: this +0.1 could crash. Dangerous heuristic (N=2).

    yellow_mask = skimorph.closing(
        np.logical_and(cropped_mask, blurred_saturation > threshold),
        skimorph.footprint_rectangle((5, 5))
       )

    return(yellow_mask)


def GetMaskProperties(mask, img = None):
    if img is not None:
        props = skimeas.regionprops(
            np.array(mask, dtype = int),
            intensity_image = img
           )[0]
    else:
        props = skimeas.regionprops(np.array(mask, dtype = int))[0]

    return(props)


# TODO: continue with generalization of rotation functions
