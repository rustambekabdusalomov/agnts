# Tasks

Tasks are for repositories outside Jira, like your side projects. They go through the same steps as Jira tickets.

## New task

Pick a repository, describe the result you want (attach screenshots, mockups or files if they help), set the priority and choose how to start: ask questions first, start coding right away, or keep it in the queue.

## After you approve

Choose for each task whether agnts opens a pull request or pushes straight to main. It never pushes without your review.

## Repositories

Add a repository with its clone URL, a key prefix for task numbers, and the test command that must pass.

## Editing

While a task is still in the queue you can edit or delete it from its page.

## Several repositories

Pick several repositories, or a group, when one change spans them (an API and the app that calls it). agnts works on all of them in one run: each repository is a folder of its own, its checks run in its folder, and each changed repository gets its own commit and pull request, linked to the others. A repository the work does not change gets no pull request. The task counts as merged once every pull request it opened is merged; if one is closed without a merge, it shows as partly merged. If a push fails in one repository, the others stay pushed and Retry pushes the rest.
