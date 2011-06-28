
For simplicity we combine all the dependent directories into one.  For example in the nginx zip we also include PCRE and the various plugins we use.  This way we only have to download and unzip a single file to get everything we need.  If you need to add new dependencies you would unzip the current nginx.zip, add the directories of the dependencies and then rezip, and place here.

