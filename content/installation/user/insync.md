---
date: 2018-04-19T11:01:31+02:00
description: ""
title: Insync
weight: 8
---

[Insync](https://www.insynchq.com/) is a thirth party tools that synchronises files with [Google Drive](https://www.google.be/drive/about.html). It has some nice features which are still not available with the sync tools provides by Google. For the remaining of this tutorial, "GoogleDrive" refers to the sync tools provided by Google.

## The problem with GoogleDrive

GoogleDrive doesn't work well in combination with [RStudio](https://www.rstudio.com) projects or [Git](https://git-scm.com/) projects. We'll illustrate the problem with RStudio. RStudio has a performant auto save functionality. As soon as the user changes a few character in a script, the auto save kicks in. This functionality stores the backup information into a hidden subdirectory (`.Rproj.user`) of the project. It writes very often to the files in this subdirectory.

GoogleDrive is constantly monitoring the synchronised directory for new, changed or deleted files. As soon as it detects such file, it will lock the file, synchronise the file and unlock the file. The locking of the file pervents that changes are made to the file while it is being synchronised, because this would mess up the synchronisation. GoogleDrive works on all files with in a synced directory, including those created by the RStudio auto save function. However this function writes very often to those files, so often that it tries to write again to a file which still is locked by GoogleDrive. This results in a "cannot save to file" dialog box in RStudio, which has to be dismissed by the user. The happens so often that is becomes frustrating for the user.

## How Insync solves this problem

Insync is also constantly monitoring all files in the synchronised directories. unlike GoogleDrive, Insync has an option to ignore directories or files when synchronising. So when can set Insync to ignore `.Rproj.user`. Any files within `.Rproj.user` are no longer synchronised and thus never locked which caused the problem with RStudio.

_Wait at minute, so these file will be no longer be available through the GoogleDrive website? Isn't that a problem?_ Yes, they will not be available. And no that is not a problem. Only your **temporary** changes are no longer synchronised. When you **save** your script file in RStudio, you are saving a file to a location which is **not** on the ignore list and thus will be synchronised. _But this fille will be locked during sync?_ Yes, but the time between two consecutive **manual** saves of a script will a lot larger that the time required to sync the script. So the file will be unlocked by the next time you save the file.

## How to set the ignore list in Insync

First of all, it is important to do this **prior** to syncing files to your computer. Once a file or directory has been synced between the computer and the cloud, then Insync will keep syncing it. Even when a file or directory is afterward added to the ignore list.

### Set up

1. Open the Insync app
1. Click on your avatar
1. Choose `setting` and then `ignore list`
1. Add the search pattern into the form field and click on the circled '+'

The default action is to exclude all matching files and directories (including their files and subdirectories) from syncing ("do not upload or download"). Local files will remain only local and files in the cloud will remain only in the cloud. You can change this via the drop down menu of the pattern. Other options are "do not upload", "do not download" or "remove from this list".

We recommend to add following patterns:

- .rproj.user
- *.git
- *.rcheck
- *_cache
- *_files
- _site

## FAQ

1. Can I use the same local folder when switching from GoogleDrive to Insync
    - It is safer you use a different folder. 
1. I've already synced an RStudio project with Insync without setting the ignore list
    - Create a new RStudio project in a different folder and copy your data an script to this new RStudio project
