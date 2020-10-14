# Setting up Autosyncing Fossil Repositories on macOS

Initialize a Fossil repo. Make sure you are in your home directory (~) first (or wherever you want the checkout directory to be)

```fossilize _reponame_```

This creates a repository - /Users/Shared/FOSSIL/_reponame_.fossil and a checkout directory called _reponame_, with all it's contents added to the repository. If the initial checkout directory already exists its contents will be **added and committed** to the repository. An optional icon will be added to the checkout directory. An alternative repository location can be specified using the -r option (see 'fossilize -h')

-k  KiCad Repo - prefilled with useful (empty) directories for use with KiCad EDA (Electronic design)
-i  with Fossil file icon on directory

**Remember the setup username & password!!!!**

Fossilize will prompt for setting up users and access permissions via the web interface at 8080 and then open a webpage at <http://127.0.0.1:8080/_reponame_>

The project can be named here and other settings adjusted.

Updating the repository with locally added files should be confirmed with

- _fossil status_ - Checks current settings
- _fossil extra_ - Sees if there are any files that have not been added to the repository.
- _fossil addremove_ - Adds and removes recursively all the files in the checkout directory
- _fossil update_ - Gets latest version from server
- _fossil commit (-m "Commit message")_ - Writes the changes to the repository and triggers an autosync.

*On remote machine*

Best to keep cloned repositories in central location /Users/Shared/FOSSIL (like server) or possibly in ~/FOSSIL/ Need to clone the repository from the server with appropriate credentials

fossil clone http:// _username__:__password_@imac.local:8888/ _reponame_ _newreponame_

This produces a new local repository which is autosynced with original repository on iMac.

Now you need to prepare the new checkout directory. Make a new folder (or mkdir _newdirectory_) and cd into it. Now open the repository in this directory.

fossil open /Users/Shared/FOSSIL/_reponame_

or

fossil open ../FOSSIL/_reponame_

The previous commands all work i.e.

_fossil status_ - Checks current settings _fossil extra_ - Sees if there are any files that have not been added to the repository. _fossil addremove_ - Adds and removes recursively all the files in the checkout directory _fossil update_ - Gets latest version from server _fossil commit (-m "Commit message")_ - Writes the changes to the repository and triggers an autosync.

This will work either way around - i.e initial repo on either desktop or laptop.

```[general]
# Here you define a comma separated list of targets.  Each of them must have a
# section below determining their properties, how to query them, etc.  The name
# is just a symbol, and doesn't have any functional importance.
targets = my_fossil

# Here is a test example for Fossil
[my_fossil]
service = fossil
url = http://127.0.0.1:8888/Grape/
username = anotheruser
password = password
report_id = 1
project_name = ammonite
default-priority = M
```
