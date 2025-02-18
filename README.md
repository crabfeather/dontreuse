# doNTreuse

### Description:
doNTreuse.sh is a simple Bash script for examining the extent of NT hash reuse from the result of Impacket's secretsdump.py. This is done by parsing the hashes, outputting groups separated by a delimiter containing all users who share the same password, and highlighting any administrators.<br/>

The tool is built to work with below format, but feel free to customize the regex for your needs.
```
<username>:<id>:<lm-hash>:<nt-hash>:::
```

### How to use:
```
./doNTreuse.sh ./hashes.txt ./admins.txt
```
Where "hashes.txt" is a list all hashes (one per line), and "admins.txt" is a list of all adminstrators (one per line).

### Contact:
Allan Edh\
Cybersecurity Consultant\
allan.edh@gmail.com
