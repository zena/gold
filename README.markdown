SUMMARY
=======

Gold is a simple executable that helps git teamwork.

DESCRIPTION
===========

This is the workflow we use when developing zena.

The main idea is that developers work on feature branches on their fork and send an
email to the reviewer when work is ready. The reviewer pulls from these branches,
checks that all is good and either apply the commits to the gold master or abort.

There is a script called 'gold' that helps use this workflow once the remote references
are added.

Any questions ? Ask zena's mailing list: http://zenadmin.org/en/community


Workflow
========

You need to update the Settings in the 'gold' script to match your own project and emails.

Developer setup
---------------

    1. login on github (John)
    2. fork sandbox
    3. on local machine, clone your own fork
    > git clone git@github.com:john/PROJECT.git
    > cd PROJECT
    > gold setup

Working on new 'floppy' feature
-------------------------------

*John* (developer, on his own fork)

    > git checkout gold
    > git pull
    > git checkout -b floppy
    > commit, commit
    # propose
    > gold propose

*reviewer*

    # only if john is not a remote yet
    > gold add_dev john
    # review
    > gold review john/floppy
    # fail
    > gold fail

*John*

    > reset, commit, squash, etc
    # propose again
    > gold propose

*reviewer*

    # review
    > gold review john/floppy
    # ok
    > gold ok

*John*

    # cleanup
    > git co floppy
    > gold cleanup
