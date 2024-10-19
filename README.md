19 October 2024
# WebLog
Bash script to process a log of web requests.
Part of coursework for Security Intelligence
## Task
Develop your own bash script, which will take one or several arguments in the following fashion:
```
$ ./WebLog.sh [file] [IP]
```
With the following goals in mind:
- Case 1: one argument passed - file. It must look into the file and show the number of correct (200~299 status code) and incorrect (other status code) web requests for each IP address in the file.
- Case 2: two arguments passed - file and IP. It must look for web requests with the given IP and return the following information for each matching request: url, timestamp, operating system, and browser.
- Case 3: no arguments: ask for the two arguments and follow through with case case one or two accordingly.

Example of call to the program:
```
$ ./WebLog.sh access.log 194.224.19.82
```

## (Brief) Code Analysis

Yet to append (☞ﾟヮﾟ)☞☜(ﾟヮﾟ☜)

### Screenshots

## Acknowledgements
This exercise was part of Coursework 1 for the module Security Intelligence (Inteligencia de la Seguridad) at the URJC Universidad Rey Juan Carlos in 2024-2025. Coursework task provided by Professor Carlos Contreras.

## Why did I upload it?
This is my first big bash script so far and, just like with other small projects, I think it is pretty cool. :3


By the by, my coursework was submitted before I uploaded this script (THAT IS, I AM THE AUTHOR ;) ).
