---
title: "Handle Git conflicts via GitHub.Com"
description: "How to handle git conflicts using the GitHub website"
authors: [thierryo]
date: 2024-04-17
categories: ["version control"]
tags: ["git", "version control"]
---

## Fix merge conflict with a pull request

Sometimes a pull request warns about a merge conflict.
A merge conflict occurs when one or more lines were altered in the base branch so that a merge conflict arises in the feature branch.
The warning looks like the image below.

![Message indicating a merge conflict on GitHub.com](merge-conflict-1.png)

You can fix most merge conflicts in the browser.
First push the `Resolve conflict` button in the warning.
The website sends you to a page with a list of all merge conflicts.
The webpage highlights them by a red vertical line.
Every merge conflict inserts three delimiters:

1. `<<<<<< feature branch name`: the start of the merge conflict
1. `======`: the separator between the content of both branches
1. `>>>>>> base branch name`: the end of the merge conflict

![Source with a merge conflict on GitHub.com](merge-conflict-2.png)

Fix the merge conflict by changing the source.
Often you can fix it by simply deleting the content of one of the branches within the conflict.
Potentially you need to keep a mix of both.
Don't forget to also delete the three delimiters when you're ready.
Should fixing the merge conflict be more complicated, then you probably better fix them via the [command line](../git_conflict/index.html).
In our example we solved the conflict by keeping the content of the feature branch.

![Solved merge conflict on GitHub.com](merge-conflict-3.png)

Once you have fixed all merge conflicts, go to the top of the page.
There hit the `Mark as resolved` button.

![Mark a merge conflict as resolved on GitHub.com](merge-conflict-4.png)

Finally you store the fixes in a new commit by hitting the `Commit merge` button.

![Commit a merge conflict on GitHub.com](merge-conflict-5.png)

