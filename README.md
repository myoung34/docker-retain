Docker Retainer
===============

According to the new Docker hub TOS, images without pulls in 6months will be purged.

I understand, but I also want my artifacts to stay.

This will run on a schedule and pull all image tags + architectures for a given user

## Usage ##

Note: the assumption is that your github user is the same as the dockerhub user.
If this is not true just set it in `.github/workflows/retain.yml`

To use this, just fork the repo

## Enabling Workflows ##
After you fork the repo, you'll have to manually enable the workflow, as GitHub disables this by default on forked repos

### Step 1 ###
Click the "Actions" tab in the repo, then click the big green button for "I understand my workflows, go ahead and enable them"
![Step 1](https://i.imgur.com/I8HjEi5.png)

### Step 2 ###
Click on the "Retain" workflow, then click the "Enable workflow" button
![Step 2](https://i.imgur.com/oGPF01R.png)

