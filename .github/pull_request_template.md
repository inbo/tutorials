<!--- indicate the Title for this pull request (PR) above -->

<!--
Thank you for contributing to the INBO tutorials repository.
-->

## Description
<!--- Briefly describe the tutorial or article that you want to contribute
or update-->
<!--- You can mention collaborators with "@githubname"-->


## Related Issue
<!--- if this closes an issue make sure to include e.g., "closes #4"
or similar - or if it just relates to an issue make sure to mention
it like "#4" -->
<!--See https://docs.github.com/en/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword-->


<!--If you like to preview the website version of your (draft) tutorial, please read https://github.com/inbo/tutorials/blob/master/.github/workflows/REVIEWING.md-->

## Task list

<!--see https://docs.github.com/en/github/managing-your-work-on-github/about-task-lists
for an explanation on how to use task lists-->

<!-- Please check if the following steps are OK:-->

- [ ] My tutorial or article is placed in a subfolder of `tutorials/content`
- [ ] The filename of my tutorial or article is `index.md`. In case of an Rmarkdown tutorial I have knitted my `index.Rmd` to `index.md` (both files are pushed to the repo). 
- [ ] I have included `tags` in the YAML header (see the tags listed in the [tutorials website side bar](https://inbo.github.io/tutorials/) for tags that have been used before)
- [ ] I have added `categories` to the YAML header and my category tags are from the [list of category tags](https://github.com/inbo/tutorials/blob/master/static/list_of_categories)


## Previewing the pull request

Thanks to GitHub Actions, an artifact (=zip file) of the rendered website is automatically created for each pull request.

### Instructions

1) On the PR page, you can find a "details" link under "checks - On PR, build the site and ...". Go there, click on the top link in the left sidebar ("Summary"), and download the generated artifact at the bottom of the page.
2) Decompress it and make sure the target directory is called 'tutorials' (you may need to rename it)
3) From the parent directory (just above the `tutorials` folder you created/renamed), run `python -m http.server 8887`, _or_ launch the Google Chrome [Web Server app](https://chrome.google.com/webstore/detail/web-server-for-chrome/ofhbbkphhbklhfoeikjpcbhemlocgigb) and point it at the parent directory.
4) Point your browser to http://localhost:8887/tutorials.
5) Review the updated website and accept/refuse/comment the PR

**Note: for step 3, you can use any other simple HTTP server to serve the current directory if you don't have a Python 3 environment or Google Chrome available.**