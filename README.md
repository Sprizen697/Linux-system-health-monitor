
# Linux System Health Monitor

A Bash script that monitors Linux system health by checking disk usage, RAM usage, CPU load, and service status
The script saves health reports to a log file and displays important status messages in the terminal

(if this is used in wsl it'll only track the files and ram usage inside the wsl)

## goals

- Checks how much disk space is being used -done
- Checks RAM usage -done
- Shows CPU load and warns if it's high -done
- Checks if a given service is running -done
- Saves the results in a log file -done
- Prints the important status messages in the terminal -done
- Automation -added one for zsh(the current shell im using)
