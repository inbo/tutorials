---
title: "Git and GitHub Authentication on Windows"
description: "How to safely identify yourself, or a third party on behalf of you, to Git or GitHub"
authors: [hansvancalster]
date: "2022-06-16"
categories: ["version control"]
tags: ["git", "github", "rstudio"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes+definition_lists
---

## Before we start

This tutorial assumes you have a GitHub account, and have Git, R and
RStudio installed on your system. The purpose of this tutorial is to
make clear recommendations about authentication for employees at INBO
who use Git version control in their workflows. The guidelines here are
meant for people who use Git and GitHub in RStudio, but the general
principles can be applied to other software too (e.g. GitHub Desktop).

If you do not have a GitHub account, you can [sign up for a new GitHub
account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account).
The installation of Git, R and RStudio at INBO, is done by IT
administrators who follow [these installation instructions for
admins](../../installation/administrator/). In addition, the user is
asked to do some extra steps after installation of
[Git](../../installation/user/user_install_git/),
[R](../../installation/user/user_install_r/) and
[RStudio](../../installation/user/user_install_rstudio/).

To authenticate means passing information (= credentials) that proves
that you are exactly who you declare to be. Authentication is about
securely accessing your GitHub account’s resources either directly by
yourself or on behalf of you by a third party. For instance, you can
grant an R package the right to do stuff on your behalf (e.g. reading
your e-mail address). You determine what can and what cannot be done and
this can be different for various third parties.

Most of the material in this tutorial is explained in length in
<https://happygitwithr.com/connect-intro.html>. We will mainly follow
[the advice given in the usethis
package](https://usethis.r-lib.org/articles/articles/git-credentials.html).

Authentication is a quite confusing and technical topic. In the [TL;DR
section](#tldr) (Too Long; Didn’t read) we just provide a summary of the
recipe to follow without any explanation. Using this recipe will
hopefully just work. If you want to get some intuition about what you
are doing, you will need to read the remainder of the tutorial too (and
also check out the weblinks included in this tutorial).

## TL;DR

First, enable two-factor authentication (2FA) for your GitHub account:
follow [these
steps](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication#configuring-two-factor-authentication-using-a-totp-mobile-app).
You need a time-based one-time password app for 2FA to work. We
recommend a mobile app which you can download on your smartphone such as
[`Aegis`](https://play.google.com/store/apps/details?id=com.beemdevelopment.aegis)
(open source, Android) or `Google Authenticator` (closed source,
[Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en&gl=US)
or
[iOS](https://apps.apple.com/us/app/google-authenticator/id388497605)).

Next, in R, install the `usethis` package (this will also install
packages `gert` and `gitcreds` which we use below) and the `checklist`
package:

``` r
install.packages("usethis")
install.packages("checklist",
                 repos = c(
                   inbo = "https://inbo.r-universe.dev",
                   CRAN = "https://cloud.r-project.org/")
                 )
```

Use the following commands to configure some global git options (the
scope, your user name and email, and the default branch name to
initialize a repo). You need to adapt “Your Name” and
“<your.name@inbo.be>” in the code. It’s also possible you already
configured this. You can check if this is the case with the command
`View(gert::git_config_global())` which lists all your current global
git configuration settings.

``` r
if (checklist::yesno(
  paste0("Are you sure you want to execute this code?\n",
         "This action will overwrite Git global configuration settings.\n",
         "Make sure you changed 'your name' and 'your@email.com' in the code,\n",
         "if you didn't select negative answer."))) {
  usethis::use_git_config(
    scope = "user",
    user.name = "Your Name",
    user.email = "your.name@inbo.be",
    init.defaultbranch = "main"
  )
} else {
    message("Action aborted")
}

# you can ignore this warning
# Warning message:
# In orig[nm] <- git_cfg_get(nm, "global") %||% list(NULL) :
#   number of items to replace is not a multiple of replacement length
```

If you plan to use functions that create something on GitHub (a repo, an
issue, a pull request, a branch, …) and for all remote operations from
the command line (`git pull`, `git push`, `git clone`, `git fetch`), you
can use the following commands to create a Personal Access Token (PAT)
and add it to the Git Credential Manager:

``` r
?usethis::create_github_token # read the help file
usethis::create_github_token() #browser opens, follow instructions
```

Add the PAT to the Git Credential Manager:

``` r
?gitcreds::gitcreds_set # read the help file
gitcreds::gitcreds_set() #paste PAT
```

After you have added the PAT to the Git Credential Manager, there is no
need for you to store it elsewhere. **WARNING**: handle your Personal
Access Token (PAT) as a secret. Anyone who has your token, has access to
your GitHub account.

Check if everything is OK:

``` r
usethis::git_sitrep()
```

The default Git protocol should be ‘https’ (recommended on Windows).

The `usethis` package promotes the use of a global `.gitignore` file
which prevents that some file types that could contain sensitive
information (from your account / credentials) are tracked by the Git
version control system. However, we prefer a [project-specific
`.gitignore`
file](https://github.com/inbo/checklist/blob/main/inst/generic_template/gitignore)
for this purpose. This is one of the many things that the `checklist`
package will take care of for you. It is therefore good practice to use
the `checklist` package to set up your RStudio projects for either R
packages or regular R code projects. We refer to the [`checklist`
package documentation](https://inbo.github.io/checklist/) for further
information.

## Modes of authentication

The way in which you need to authenticate depends on how you access your
resources in GitHub. For instance, to manage your repositories online
you can sign-in to GitHub using a username and password followed by
two-factor authentication. As another example, a function like
`checklist::new_branch()` will create a new branch on GitHub and
locally. In order to create a new branch, you will need a Personal
Access Token with appropriate scopes if you use the HTTPS protocol. A
token with no assigned scopes can only access public information.

We will follow the [recommendations given in the `usethis`
package](https://usethis.r-lib.org/articles/articles/git-credentials.html)
for safe Git and GitHub authentication on Windows, which cover multiple
facets:

1.  Turn on two-factor authentication for your GitHub account.
2.  Adopt HTTPS as your Git transport protocol.
3.  Use a personal access token (PAT) for all Git remote operations from
    the command line or from R.
4.  Allow tools to store and retrieve your credentials from the Git
    Credential Manager.

This deserves some further explanation. The first recommendation
essentially is an extra layer of security compared to a simple
username-and-password authentication on GitHub. It is unrelated to git
operations. To enable two-factor authentication for your GitHub account,
follow [these
steps](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication#configuring-two-factor-authentication-using-a-totp-mobile-app).
You need a time-based one-time password app for 2FA to work. We
recommend a mobile app which you can download on your smartphone such as
[`Aegis`](https://play.google.com/store/apps/details?id=com.beemdevelopment.aegis)
(open source, Android) or `Google Authenticator` (closed source,
[Android](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en&gl=US)
or
[iOS](https://apps.apple.com/us/app/google-authenticator/id388497605)).
The closed tools don’t require users ‘to read on’ and make everything
simple, while open tools will require some minimal responsibility
e.g. to take care of personal backups. Some open source desktop
applications are available as well and are listed in
<https://github.com/andOTP/andOTP/wiki/Open-Source-2FA-Apps> and
<https://en.wikipedia.org/wiki/Comparison_of_OTP_applications>. Mostly
these open source tools are geared towards offline storage and give
users maximum control over their credentials. 2FA is not that intrusive.
It only kicks in when you login from a new device or when your last
login on a device was a long time ago. If someone steals your username
and password, they still can’t login using that combination from their
device due to 2FA.

The second recommendation is to use the [HTTPS
protocol](#using-the-https-protocol) to transport information (data)
from your local Git repositories to their remote (online) counterparts.
A good alternative is the SSH protocol. We have also included in this
tutorial how to use the [SSH
protocol](#creating-public-private-ssh-key-pairs), but in our experience
this is not necessary in most circumstances and more involved to
implement in Windows. Users of the Linux operating system, on the other
hand, may prefer the SSH protocol. It is always possible to switch
between HTTPS and SSH protocols and we explain in [the SSH
section](#creating-public-private-ssh-key-pairs) how to do that.

The third recommendation is mandatory when you use the HTTPS protocol.
GitHub no longer allows a simple password for Git remote operations. The
remote is the place where you store your code on a Git Server, for
instance <https://github.com/inbo/tutorials>. Git remote operations
include, among others, `git clone`, `git fetch`, `git pull` and
`git push`.

The fourth recommendation is the easiest, because it just works out of
the box with recent versions of Git (2.29 or higher). The installation
of Git on Windows comes with a [Git Credential
Manager](https://github.com/GitCredentialManager/git-credential-manager)
which allows that web apps like [hackmd](https://hackmd.io/login) or R
packages like `gert` and `gh` can ask for your credentials and get them
from the credential store. In earlier days, it was sometimes needed to
store your PAT in a `.Renviron` text file which you store only locally
(the file will in that case contain a line `GITHUB_PAT=`…). This is no
longer needed and should be avoided because of the risk to expose the
PAT when that file is accidentally put online. You can check if you have
previously set a `GITHUB_PAT` in your `.Renviron` with the R command
`usethis::edit_r_environ()`.

## Creating Personal Access Tokens (PAT)

### Creating a new PAT

We move the steps about creating a PAT upfront, because this includes
guidelines to store the PAT with the Git Credential Manager so they can
be discovered automatically.

Personal access tokens can only be used for HTTPS Git operations. When
you create a PAT, you will be asked which scopes should be allowed
(i.e. what rights do you give). We suggest that you stick with the
scopes recommended by the `usethis` package. Executing the following
command takes your browser to a pre-filled form with the recommended
scopes (repo, user, workflow) where you can create your PAT.

``` r
usethis::create_github_token()
```

After you have done this, you can store this PAT in the Git Credential
Manager using this code:

``` r
gitcreds::gitcreds_set()
```

which will open a prompt where you can paste your PAT (or replace an old
one).

If you want to know more about PATs read [this section from happy git
with R](https://happygitwithr.com/https-pat.html#get-a-pat) and [this
section from the usethis
package](https://usethis.r-lib.org/articles/git-credentials.html#get-a-personal-access-token-pat).
In case your PAT is compromised, you should
[deactivate](https://github.com/settings/tokens) it ASAP on GitHub.

After you’ve done this, you can check your authentication settings. The
`usethis` package has a function to get a situation report on your
current Git/GitHub status, including information about authentication:

``` r
usethis::git_sitrep()
```

The situation report should normally report that the default Git
protocol is `https`, which we will discuss next.

### Regenerating an expired PAT

The PAT generated in the previous section has an expiration date
associated to it. This is an extra fail safe security layer. The default
is 30 days and you can specify a maximum expiration date of 1 year since
creation. This means that from time to time, you will need to regenerate
your PAT.

To do this, head over to the [Github settings tokens
page](https://github.com/settings/tokens) and click on the expired PAT.
Next, click regenerate token. After that is done, run the command
explained in the previous section again to add the newly generated token
to the Git Credential Manager:

``` r
gitcreds::gitcreds_set()
```

## Using the HTTPS protocol

The HTTPS protocol is the GitHub default URL transport protocol that
uses the Transport Layer Security (TLP) encryption protocol to encrypt
communications. To learn more about what https is, [read this
explanation](https://www.cloudflare.com/learning/ssl/what-is-https/).

The usual way to choose the protocol is when you clone a repository to
your computer. You can do this in various ways:

-   Point-and-click approach:
    -   Go to <https://github.com/inbo/tutorials>, press the clone
        button and copy the URL (default is HTTPS:
        `https://github.com/inbo/tutorials.git`)
    -   Open RStudio:
        `File > New project > Version control > Git > paste https://github.com/inbo/tutorials.git > create project`
-   Using git commands
    -   Open a terminal
    -   (Go to the folder where you want to clone the repository using
        `cd` command or open the terminal directly at that location)
    -   type `git clone https://github.com/inbo/tutorials.git`
-   Using R packages: choose one:
    -   `usethis::create_from_github(repo_spec = "https://github.com/inbo/tutorials.git", destdir = "path/to/gitrepofolder")`
    -   `gert::git_clone(url = "https://github.com/inbo/tutorials.git", path = "path/to/gitrepofolder")`

See also in [SSH protocol](#creating-public-private-ssh-key-pairs) the
paragraph about the use of the `git remote` command.

When you use these git commands or R functions, your PAT will be
discovered from the Git Credential Manager and automatically authorize
access (if you followed the steps in the previous section correctly)
[^1].

## Creating public-private SSH-key pairs

Below we describe the steps you need to run in order to make SSH-keys
(Secure SHell). The SSH protocol is, next to the HTTPS-protocol, a way
to safely interact with GitHub. A general and easy to follow explanation
about SSH can be read
[here](https://dev.to/risafj/ssh-key-authentication-for-absolute-beginners-in-plain-english-2m3f).
Both HTTPS and SSH are secure ways to communicate with a server (pass
information between your computer and a server). For a discussion of
technical differences and similarities on how both protocols handle
security, [this resource about SSH and
TLS](https://www.ssl2buy.com/wiki/ssh-vs-ssl-tls) is useful.

A private key, that is specific to your computer, and a matching public
key that is stored on your GitHub account are needed. The provided
instructions are for Windows and are taken from
<https://happygitwithr.com/ssh-keys.html>. The same source may be
consulted for other operating systems.

1.  Open RStudio: *Tools \> Global Options…\> Git/SVN \> Create RSA
    Key…* You can optionally use a passphrase for extra protection of
    the key. Without password, anyone who has a copy of your private
    key, can impersonate you when authenticating on GitHub. When the
    private key is password protected they need your password too. Click
    create and apply.

2.  In RStudio, open a Rproject with Git version control and navigate to
    the Git pane. Open the Git Shell (*More \> Shell*). First we check
    if the SSH agent works with the following command (The first $ is
    the prompt and you should not copy it. To paste in the shell click
    the right mouse button.):

        $ eval $(ssh-agent -s)
        # which should give something like this:
        Agent pid 59566

    If that works, we need to add the SSH key (if you provided a
    passphrase, you will need it here.):

        $ ssh-add ~/.ssh/id_rsa

3.  Restart RStudio. Next *Tools \> Global Options…\> Git/SVN* and click
    *View public key* in the SSH-RSA section. Copy to the clipboard.

4.  Open your personal GitHub account
    *`https://github.com/<githubusername>`* (you may need to login).
    Click your profile-icon in the upperright corner and go to *Settings
    \> SSH and GPG keys*. Click *New SSH key*. Paste the public key in
    the field and provide an informative title
    (e.g. `<year>-<computername>`). Click *Add SSH Key*.

5.  To use the SSH protocol (or HTTPS for that matter), you need to set
    the remote of your repository correctly. The following command is
    useful to find out which protocol your repository uses (*Git pane \>
    More \> Shell*) (open the Shell from within the RStudio project with
    Git version control which you want to switch to SSH):

        $ git remote -v

    You will either see `https://github.com/<OWNER>/<REPO>.git` or
    `git@github.com:<OWNER>/<REPO>.git`. The first one is the
    HTTPS-protocol, the latter one the SSH-protocol. Switching between
    protocols is possible at any time. To switch from HTTPS-protocol to
    SSH-protocol, type:

        $ git remote set-url origin git@github.com:USERNAME/REPOSITORY.git

    Check if the remote is set correctly with `git remote -v`.

[^1]: In case you did not follow the guidelines correctly, Git will
    prompt you to log in using a browser window and asks for your
    username and password. In the password section you will need to
    provide your PAT (not your GitHub password, which is indeed
    confusing). If you enabled two-factor authentication (like you
    should have), you’ll need to complete the 2FA challenge. Once you’ve
    authenticated successfully, your credentials are stored in the Git
    Credential Manager and will be used every time you clone an HTTPS
    URL. Git will not ask you for your credentials again unless you
    change your credentials.
