## README

This script is a shell script to install `kubectl`, `kubectx`, and `krew` with various plugins for Kubernetes. 

### Prerequisites

Before running this script, make sure that your machine has the following software installed: 

- curl
- tar
- git
- sed

### Installation

To run this script, perform the following steps:

1. Open your terminal.

2. Give execute permission to a script file, you can use the chmod command as follows:
```bash
chmod +x pimp-my-kubectl.sh
```
3. Type `./pimp-my-kubectl.sh` and hit Enter.

The script will download and install `kubectl`, `kubectx`, and `krew`. It will also install krew plugins such as `community-images`, `blame`, `tree`, `count`, `deprecations`, `datree`, `colorize-applied`, and `explore`.

After you run the script, you should be able to use `kubectl`, `kubectx`, and all of the plugins listed above.

### Contributing

Please feel free to contribute to this script by making a pull request on the Github repository. 

### Credits

Thank you to the authors of kubectl, kubectx, and krew plugins for creating these amazing tools!
