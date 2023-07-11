## Updating

### Updating files (from remote to local)
* using git : [git-fetch.sh](git-fetch.sh)

### Update the 'MechatronicBeing' directory
* [update.sh](full-update.sh) will execute the scripts :
  - [update/update-MBdir.sh](update/update-MBdir.sh) : get the recent 'MechatronicBeing' directory
  - [update/update-git-fetch.sh](update/update-git-fetch.sh) : create the file ["git-fetch.sh"](git-fetch.sh)
  - [update/update-downloading.sh](update/update-downloading.sh) : create  ["downloading/update-downloading.sh"](../downloading/download.sh) and ["downloading/git-clone.sh"](../downloading/git-clone.sh) files
  - [update/update-list.sh](update/update-list.sh) : create a basic list [../lists/](../lists/)
  - [update/update-list-full.sh](update/update-list-full.sh) : create a detailed list ["./lists/full/](../lists/full/)
  - [update/update-list-files.sh](update/update-list-files.sh) : create a file list in ["./lists/files/](../lists/files/)
  - [update/update-md2html.sh](update/update-md2html.sh) : generate all .html files from .md
  - and upload the files (see "Uploading files (from local to remote)")

### Update HTML pages from Markdown files
The script [update/update-md2html.sh](update/update-md2html.sh) is executed for generating all .html pages from .md files, in the root category.  
The script use 2 conversion methods : 
  1. IF the program "PANDOC" is installed in the system, the script execute it to convert the files.
    - Note1 : with this method, a "static" html page is created
  2. ELSE, the script will create a very simple html file, with javascript librairies, to read and convert the markdown file **directly** in the web-browser.  
    - Note2a : this method use [MARKED.js](https://marked.js.org/) librairie, distributed under the **MIT license**.
    - Note2b : this method allows to read the markdown file **on the fly**, BUT requires a fileserver to be efficient.  
  
### Uploading files (from local to remote)
* using git : 
  * 'Light' upload (only the ./MechatronicBeing/ folder) : [git/git-MBdir.sh](git/git-MBdir.sh)
  * Full upload (all the files) : [git/git-Fulldir.sh](git/git-Fulldir.sh)