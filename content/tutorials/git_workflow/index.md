---
title: "Git workflow using the command line"
description: "Git workflow using the command line"
authors: [stijnvanhoey]
date: 2017-10-18T14:42:43+02:00
categories: ["version control"]
tags: ["git", "version control"]
---

### BEFORE I START WORKING

* **STEP 1**: Update the master branch on my PC to make sure it is aligned with the remote master

    ```
    git fetch origin
    git checkout master
    git merge --ff-only origin/master
    ```

* **STEP 2**: Choose your option:
    * **OPTION 2A**: I already have a branch I want to continue working on:  
    Switch to existing topic branch:

        ```
        git checkout name_existing_branch
        git fetch origin
        git rebase origin/master
        ```

    * **OPTION 2B**:  I'll make a new branch to work with: Create a new topic branch from master(!):

        ```
        git checkout master
        git checkout -b name_new_branch
        ```

### WHILE EDITING

*  **STEP 3.x**: adapt in tex, code,... (multiple times)
    * **New files added**

        ```
        git add .
        ```

    * **Adaptation**

        ```
        git commit -am "clear and understandable message about edits"
        ```

### EDITS ON BRANCH READY
* **STEP 4**: Pull request to add your changes to the current master. Choose your option:
    * **OPTION 2A CHOSEN**:

        ```
        git push origin name_existing_branch
        ```

    * **OPTION 2B CHOSEN**:

        ```
        git push origin name_new_branch
        ```

* **STEP 5**: Code review!

    Go to your repo on Github.com and click the *create pull request* block. You and collaborators can make comments about the edits and review the code.

    If everything is ok, click the  *Merge pull request*, followed by *confirm merge*. (all online actions on GitHub). Delete the online branch, since obsolete. 

    You're work is now tracked and added to master! Congratulations.

    If the code can't be merged automatically (provided by a message online), go to **STEP 6**.    
    
### PULL REQUEST CANNOT BE MERGED BY GITHUB
* **STEP 6**: master has changed and there are conflicts:  update your working branch with rebase

    ```
    git checkout name_existing_branch
    git fetch origin
    git rebase origin/master
    # fix conflicts local
    git add file_with_conflict
    git rebase --continue
    git push -f origin name_existing_branch
    ```    
    
    
