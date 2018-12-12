---
date: 2017-10-18T15:23:04+02:00
description: ""
author: "Stijn Van Hoey"
title: "Without internet"
---

When working off line, two Git tasks cannot be performed: fetching/pulling updates from the server, and pushing changes to the server. All other commands still work.

One can commit changes, branch off, revert and reset changes, the same as when there exists an internet connection.

### Example workflow:

**start offline mode**

```
while(notBored):
	commit changes
	add files
	branch off new features
```

**end offline mode**


*update master branch*

```
git fetch origin
```

*push changes to the server*

```
git push <branch-name>
```

*it is possible, that during your down-time, a pull request got accepted
in that case, perform the following steps*

```
git fetch origin
git checkout <branch-name>
git rebase master
```

*when necessary: solve merge conflicts, and rebase again.*

*Your feature branch can now be pushed to the server, and a pull request can be made*
    
