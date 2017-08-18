Add-JSS-User-to-group
=====================

Takes the output from a .csv file in the following format:
```
username1,usergroup1
username1,usergroup2
username2,usergroup1
username2,usergroup2
```

Then either adds those users to a new JSS user static group, or creates the group and adds the user.

Nerd sniped by @mlgraham and @lewandowski on Mac Admins Slack. Hopefully this is of some use to them.

Example datafile included in this repo, but shouldn't be used for anything other than testing.

Please test on a non production environment!

WARNING: This script relies on your csv files being formatted using Windows linefeed (CRLF) characters. Unix LF may work but legacy macOS CR does NOT.