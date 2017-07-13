# GitReview

Our team uses GitHub for our code repository and code review. GitHub also allows you to follow your favorite open-source repositories to watch how the codebase is changing. For this exercise, we’d like you to build an iOS app that shows Pull Requests (PRs) on a given repo. The main purpose of the app is to view the source changes (aka “diffs”) associated with the PRs.

More specifically, your app should:

Fetch and display data from the GitHub API
List PRs in the repo.  You might want to show only open PRs.
When a PR is selected, show the diffs for it.
This should be the aggregate diffs of the whole PR, not broken down by commit.
The diff should be a side-by-side style, similar to the way XCode displays diffs or the “Split” option on GitHub.
Please use native iOS (Objective-C or Swift), not web views, javascript, etc.
You can hard-code the app to point to the MagicalRecord repo, or any public repo you choose.  How you choose to build the app (interface and experience-wise) is up to you.  

Please post your code in a GitHub (or bitbucket) repo that we can access.  We’ll look at your commit history to see your development story.

We’re looking for/grading on your ability to:

Interface with a REST API, given the docs
Program a nice looking, compelling UI
Handle any trickiness or math involved in a side-by-side diff GUI
