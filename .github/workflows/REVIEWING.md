# Reviewing pull requests

Thanks to GitHub Actions, an artifact (=zip file) of the rendered website is now automatically created on each pull request.

Reviewers can proceed like that:

1) On the PR page, you can find a "details" link under "checks - On PR, build the site and ...". Go there, click on the top link in the left sidebar, and download the generated artifact at the bottom of the page.
2) Decompress it and make sure the target directory is called 'tutorials' (you may need to rename it)
3) From the parent directory (just above tutorials), run `python -m http.server`
4) Point your browser to http://localhost:8000/tutorials
5) Review the updated website and accept / refuse / comment the PR

**Note: for step 3, you can use any other simple HTTP server to serve the current directory if you don't have a Python 3 environment available.**