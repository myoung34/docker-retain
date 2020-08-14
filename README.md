Docker Retainer
===============

According to the new Docker hub TOS, images without pulls in 6months will be purged.

I understand, but I also want my artifacts to stay.

This will run on a schedule and pull all image tags + architectures for a given user

## Usage ##

Note: the assumption is that your github user is the same as the dockerhub user.
If this is not true just set it in `.github/workflows/retain.yml`

To use this, just fork the repo
