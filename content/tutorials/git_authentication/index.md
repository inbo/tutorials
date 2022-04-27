---
title: "Git Authentication"
description: "How to safely identify yourself, or a third party on behalf of you, to Git or GitHub"
authors: [hansvancalster]
date: "2022-04-27"
categories: ["version control"]
tags: ["git", "github", "rstudio"]
output: 
  md_document:
    preserve_yaml: true
    variant: gfm+footnotes+definition_lists
---

## Before we start

This tutorial assumes you have a GitHub account, and have Git and
RStudio installed on your system. If you do not have a GitHub account,
you can [sign up for a new GitHub
account](https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account).
To enable Git with RStudio, open RStudio and go to
`Tools -> Global options -> Git/SVN`.

To authenticate means passing information (= credentials) that proves
that you are exactly who you declare to be. Authentication is about
securely accessing your GitHub account’s resources either directly by
yourself or on behalf of you by a third party. For instance, you can
grant an R package the right to do stuff on your behalf (e.g. reading
your e-mail address). You determine what can and what cannot be done and
this can be different for various third parties.

Most of the material in this tutorial is explained in length in
<https://happygitwithr.com/connect-intro.html>. The idea of this
tutorial is to condense some of this material and make clear
recommendations for use at INBO. We will mainly follow [the advice given
in the usethis
package](https://usethis.r-lib.org/articles/articles/git-credentials.html).

## TL;DR

Use the following commands to configure some global git options (if you
haven’t done this already):

``` r
gert::git_config_global_set("user.name", "Your Name") # change Your Name
gert::git_config_global_set("user.email", "your@email.com") # change your@email.com
gert::git_config_global_set("init.defaultBranch", "main")
```

Use the following commands to create a Personal Access Token (PAT) and
add it to the Git Credential Manager:

``` r
usethis::git_vaccinate()
usethis::create_github_token() #browser opens, follow instructions
gitcreds::gitcreds_set() #paste PAT
```

Check if everything is OK:

``` r
usethis::git_sitrep()
```

## Modes of authentication

There are various ways to authenticate and these modes depend on how you
access your resources in GitHub. Here are ways of authentication that we
recommend for various ways of accessing your GitHub resources.

-   Access to [GitHub](https://github.com/) via the browser
    -   Username and password combined with two-factor authentication
-   Interact with [GitHub as a Git Server](https://github.com/) via
    RStudio *and* Access to GitHub via the [GitHub REST
    API](https://docs.github.com/en/rest)
    -   The HTTPS protocol combined with a Personal Access Token (PAT)
        as credential (preferably cached in the Git Credential Manager)
-   Access to Github via the [GitHub Command Line
    Interface](https://cli.github.com/)
    -   See [gh auth
        login](https://cli.github.com/manual/gh_auth_login), which takes
        you to an interactive authentication via your browser. This
        procedure can also be used in a non-interactive way when
        authentication is needed inside a *GitHub Actions workflow* (not
        discussed further in this tutorial).

As can be seen from the above overview, authentication is necessary in
lots of instances. This ranges from something simple such as managing
your repositories online to more complex interactions.

We fully agree with the [recommendations given in the usethis
package](https://usethis.r-lib.org/articles/articles/git-credentials.html)
and repeat these here:

1.  Turn on two-factor authentication for your GitHub account.
2.  Adopt HTTPS as your Git transport protocol.
3.  Use a personal access token (PAT) for all Git remote operations from
    the command line or from R.
4.  Allow tools to store and retrieve your credentials from the Git
    Credential Manager.

This deserves some further explanation. The first recommendation
essentially is an extra layer of security compared to a simple username
and password only authentication. To enable two-factor authentication
for your GitHub account, follow [these
steps](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa/configuring-two-factor-authentication#configuring-two-factor-authentication-using-a-totp-mobile-app).
Another two-factor authentication app that is not mentioned on that
website but easy to use is Google Authenticator.

The second recommendation is to use the [HTTPS protocol](#https) to
transport information (data) from your local Git repositories to their
remote (online) counterparts. Alternatives include the HTTP (not secure)
and SSH protocol. We have also included in this tutorial how to use the
[SSH protocol](#ssh), but in our experience this is not necessary in
most circumstances and more involved to implement. It is always possible
to switch between HTTPS and SSH protocols and we explain in that section
how to do that.

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
(the file will in that case contain a line GITHUB_PAT=…). This is no
longer needed and should be avoided because of the risk to expose the
PAT when that file is accidentally put online. You can check if you have
previously set a GITHUB_PAT in your `.Renviron` with the R command
`usethis::edit_r_environ()`.

## <a name="https"></a>Using the HTTPS protocol

The HTTPS protocol is the GitHub default URL transport protocol. The
usual way to choose the protocol is when you clone a repository to your
computer. You can do this in various ways:

-   Manual way:
    -   Go to <https://github.com/inbo/tutorials> press clone button and
        copy the URL (default is HTTPS:
        <https://github.com/inbo/tutorials.git>)
    -   Open RStudio -> File -> New project -> Version control -> Git ->
        paste <https://github.com/inbo/tutorials.git> -> create project
-   Using git commands
    -   Open a terminal
    -   (Go to the folder where you want to clone the repository using
        `cd` command or open the terminal directly at that location)
    -   type `git clone https://github.com/inbo/tutorials.git`
-   Using R packages
    -   `usethis::create_from_github(repo_spec = "https://github.com/inbo/tutorials.git", destdir = "path/to/gitrepofolder")`
    -   `gert::git_clone(url = "https://github.com/inbo/tutorials.git", path = "path/to/gitrepofolder")`

See also in [SSH protocol](#ssh) the paragraph about the use of the
`git remote` command.

The first time you clone an HTTPS URL that requires authentication, Git
will prompt you to log in using a browser window. If you enabled
two-factor authentication (like you should have), you’ll need to
complete the 2FA challenge.

Once you’ve authenticated successfully, your credentials are stored in
the Git Credential Manager and will be used every time you clone an
HTTPS URL. Git will not ask you for your credentials again unless you
change your credentials.

In the event that you are not asked for an authentication via the
browser, but instead are asked for your username and password, you will
need to fill in your GitHub username and a PAT (not your GitHub
password, which is indeed confusing). The next section explains how you
do this (and how you avoid having to copy-paste a PAT manually).

## Creating Personal Access Tokens (PAT)

Personal access tokens can only be used for HTTPS Git operations. When
you create a PAT, you will be asked which scopes should be allowed
(i.e. what rights do you give). We suggest that you stick with the
scopes recommended by the `usethis` package. Executing the following
command takes your browser to a pre filled form with the recommended
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

## Checking your authentication settings

The `usethis` package has a function to get a situation report on your
current Git/GitHub status, including information about authentication:

``` r
usethis::git_sitrep()
```

If you see warnings about git_vaccinated, it is recommended to execute

``` r
usethis::git_vaccinate()
```

which adds a global `.gitignore` file that decreases the chance that you
accidentally leak credentials.

## <a name="ssh"></a>Creating public-private SSH-key pairs

Below we describe the steps you need to run in order to make SSH-keys.
The SSH protocol is, next to the HTTPS-protocol, a way to safely
interact with GitHub. A private key, that is specific to your computer,
and a matching public key that is stored on your GitHub account are
needed. The provided instructions are for Windows and are taken from
<https://happygitwithr.com/ssh-keys.html>. The same source may be
consulted for other operating systems.

1.  Open RStudio: *Tools > Global Options…> Git/SVN > Create RSA Key…*
    You can optionally use a passphrase for extra protection of the key.
    Click create and apply.

2.  In RStudio, open a Rproject with Git version control and navigate to
    the Git pane. Open the Git Shell (*More > Shell*). First we check if
    the SSH agent works with the following command (The first $ is the
    prompt and you should not copy it. To paste in the shell click the
    right mouse button.):

        $ eval $(ssh-agent -s)
        # which should give something like this:
        Agent pid 59566

    If that works, we need to add the SSH key (if you provided a
    passphrase, you will need it here.):

        $ ssh-add ~/.ssh/id_rsa

3.  Restart RStudio. Next *Tools > Global Options…> Git/SVN* and click
    *View public key* in the SSH-RSA section. Copy to the clipboard.

4.  Open your personal GitHub account
    *<https://github.com/><githubusername>* (you may need to login).
    Click your profile-icon in the upperright corner and go to
    *Settings > SSH and GPG keys*. Click *New SSH key*. Paste the public
    key in the field and provide an informative title
    (e.g. <year>-<computername>). Click *Add SSH Key*.

5.  By default communication with GitHub is via the HTTPS-protocol. To
    use the SSH protocol, you need to set the remote of your repository
    correctly. The following command is useful to found out which
    protocol your repository uses (*Git pane > More > Shell*) (open the
    Shell from within the RStudio project with Git version control which
    you want to switch to SSH):

        $ git remote -v

    You will either see <https://github.com/><OWNER>/<REPO>.git or
    <git@github.com>:<OWNER>/<REPO>.git. The first one is the
    HTTPS-protocol, the latter one the SSH-protocol. Switching between
    protocols is possible at any time. To switch from HTTPS-protocol to
    SSH-protocol, type:

        $ git remote set-url origin git@github.com:USERNAME/REPOSITORY.git

    Check if the remote is set correctly with `git remote -v`.
