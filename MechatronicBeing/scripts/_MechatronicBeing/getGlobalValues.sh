#Used as a global variables for all the scripts !!!
#Usage(1) : variable=$(getGlobalValues.sh "variable")
#Usage(2) : read -r variable1 variable2 <<< $(getGlobalValues.sh "variable1" "variable2")

#the level -relative path- to the MB root scripts
MBScriptsLevel=""

#HARD VALUES !!!! NEED TO CALL THIS SCRIPT TO FOUND ABSOLUTE PATHS, BEFORE THE REST....
#Get the current Script (in absolute path), the current ScriptName and ScriptPath (remove the file name)
currentScript=$(${0%/*}/${MBScriptsLevel}_functions/getAbsolutePath.sh "$0")
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#HARD VALUES !!!! Found the path to the category dir, needed to extract the script caller
categoryRootRelativePath="../../.."   #From THIS directory to the category folder
categoryPath=$(${currentScriptPath}_functions/findParentDirectory.sh "$currentScriptPath" "{$MBScriptsLevel}${categoryRootRelativePath}")

#Declare an associative array of "values"
declare -A valuesArray

#Get the 1st parameter : maybe the script caller ?
scriptCaller="$1"
#Try to see if the 1st parameter is the Script Caller
if [[ -f "$scriptCaller" ]]; then
  #Remove the path before the category folder (unwanted)
  scriptCaller="${scriptCaller:$((${#categoryPath}+1)):$((${#scriptCaller}+1-${#categoryPath}))}"
  #use the recordSeparatorCharacter as separator
  IFSusename="recordSeparatorCharacter"
  #start the index parameter to 1 (avoid the script caller)
  startParameterIndex=1
else
  #It's not a script, empty the scriptCaller
  scriptCaller=""
  #use the normal IFS (space)
  IFSusename="spaceCharacter"
  #Start the parameter index to 0 (default)
  startParameterIndex=0
fi

#IMPORTANT PATH VALUES !!!!!!!!
valuesArray["backToCategoryRootDir"]="../../.."  #From THIS script to the category root dir
valuesArray["mainCategoryName"]="resources"
valuesArray["mainCategoryDir"]="resources"
valuesArray["mainMBdir"]="MechatronicBeing"
valuesArray["homeCategory"]="HOME"

#Specials characters
valuesArray["nullCharacter"]=$'\x00'            #or '\0' #Warning: AVOID as a field delimiter !!
valuesArray["fileSeparatorCharacter"]=$'\x1C'
valuesArray["groupSeparatorCharacter"]=$'\x1D'
valuesArray["recordSeparatorCharacter"]=$'\x1E'
valuesArray["unitSeparatorCharacter"]=$'\x1F'
valuesArray["tabCharacter"]=$'\x09'             #or '\t'
valuesArray["lineFeedCharacter"]=$'\x0A'        #or '\n'
valuesArray["carriageReturnCharacter"]=$'\x0D'  #or '\r'
valuesArray["spaceCharacter"]=$'\x20'           #or ' '
valuesArray["fullBlockCharacter"]="█"
valuesArray["escapeSpacesInUrl"]="%20"
valuesArray["htmlSpacer"]="&nbsp;"
#MD TAGS
valuesArray["startMDtableRow"]="| "
valuesArray["fieldSeparatorMDtableRow"]=" | "
valuesArray["endMDtableRow"]=" |  "
valuesArray["symbolMDtableHeaderSeparator"]="-"
valuesArray["minimalLengthMDtableHeaderSeparator"]="3"
#HTML TAGS
valuesArray["htmlTableRowTag"]="tr"
valuesArray["htmlTableCellTag"]="td"
valuesArray["htmlTableHeaderTag"]="th"

#Save the current IFS
valuesArray["IFSdefault"]="$IFS"
#Update the IFS used
valuesArray["IFSused"]="${valuesArray[""$IFSusename""]}"

#The current directory / repository
valuesArray["currentCategorySummary"]="Free ""public domain"" resources, for many human/machine activities."

#Online repository
valuesArray["repositoryDirAdjust"]="../.."
valuesArray["repositoryDirChange"]="tree/main"
valuesArray["repositoryFileChange"]="blob/main"
valuesArray["onlineRepositoryName"]="https://github.com/MechatronicBeing/"
valuesArray["onlineArchiveZipFile"]="archive/refs/heads/main.zip"
valuesArray["onlineArchiveTgzFile"]="archive/refs/heads/main.tar.gz"
valuesArray["onlinePagesUrl"]="https://mechatronicbeing.github.io/"
valuesArray["onlineContact"]="MechatronicBeing![](MechatronicBeing/images/symbols/other/atsign.png)![](MechatronicBeing/images/symbols/bf/g.png)![](MechatronicBeing/images/symbols/bf/m.png)![](MechatronicBeing/images/symbols/bf/a.png)![](MechatronicBeing/images/symbols/bf/i.png)![](MechatronicBeing/images/symbols/bf/l.png)![](MechatronicBeing/images/symbols/other/centerdot.png)![](MechatronicBeing/images/symbols/bf/c.png)![](MechatronicBeing/images/symbols/bf/o.png)![](MechatronicBeing/images/symbols/bf/m.png)"

#MB FUNCTIONS SCRIPTS
valuesArray["MBfunctionsScriptsDirname"]="_functions/"
valuesArray["MBfunctionsScriptsDirPath"]="${MBScriptsLevel}${valuesArray[""MBfunctionsScriptsDirname""]}"
valuesArray["trimLeadingSpacesScriptname"]="trimLeadingSpaces.sh"
valuesArray["trimTrailingSpacesScriptname"]="trimTrailingSpaces.sh"
valuesArray["trimSpacesScriptname"]="trimSpaces.sh"
valuesArray["findParentDirectoryScriptname"]="findParentDirectory.sh"
valuesArray["findRelativePathScriptname"]="findRelativePath.sh"
valuesArray["writeInLogScriptname"]="writeInLog.sh"
valuesArray["getAbsolutePathScriptname"]="getAbsolutePath.sh"

#ERROR LOGS
valuesArray["writeInLogScript"]="${currentScriptPath}${valuesArray[""MBfunctionsScriptsDirPath""]}${valuesArray[""writeInLogScriptname""]}"
valuesArray["MBlogFile"]="${currentScriptPath}MB-log.txt"

#MB SCRIPTS
valuesArray["MBscriptsDir"]="${valuesArray[""mainMBdir""]}/scripts/_MechatronicBeing"
valuesArray["MBupdateScriptname"]="update.sh"
valuesArray["userSaveFile"]="update.sav" 

#Sub-directories scripts (used by update.sh)
valuesArray["scriptsUpdateDataDirname"]="data"
valuesArray["scriptsUpdateFilesDirname"]="files"
valuesArray["scriptsUpdatePagesDirname"]="pages"
valuesArray["scriptsUseGitDirname"]="git"

#Scripts names (called by update.sh)
valuesArray["dataWorksScriptname"]="data-works.sh"
valuesArray["dataFilesScriptname"]="data-files.sh"
valuesArray["updateScriptsScriptname"]="files-scripts.sh"
valuesArray["updateMBdirScriptname"]="update-MBdir.sh"
valuesArray["createFetch"]="create-fetch.sh"
valuesArray["pagesAuthorsScriptname"]="pages-authors.sh"
valuesArray["pagesOtherScriptname"]="pages-other.sh"
valuesArray["updateHtmlScriptname"]="md2html.sh"
valuesArray["gitMDdirScriptname"]="git-MBdir.sh"
valuesArray["gitAllDirScriptname"]="git-Alldir.sh"
valuesArray["gitClearHistoryScriptname"]="git-clearHistory.sh"
valuesArray["gitRemoveGitDirScriptname"]="git-removeGitDir.sh"
valuesArray["recursiveScriptname"]="recursive.sh"

#DATA FILES
valuesArray["dataFilesSubScriptsDirname"]="data-files/"
valuesArray["dataPath"]="${valuesArray[""mainMBdir""]}/data"
valuesArray["filesDataPath"]="${valuesArray[""dataPath""]}/files"
valuesArray["dataFilesRawfile"]="${valuesArray[""filesDataPath""]}/files.txt"
valuesArray["dataMBFilesfile"]="${valuesArray[""filesDataPath""]}/MB.txt"
valuesArray["dataGitfile"]="${valuesArray[""filesDataPath""]}/git.txt"

valuesArray["dataFilesRawFS"]=${valuesArray[""spaceCharacter""]} #field separator (a space)
valuesArray["dataFilesRawIdFS"]="_" #ID field separator
valuesArray["dataFilesChecksumCommand"]="sha256sum" #IF EMPTY: DO NOT CHECKSUM

#OBSOLETE :
valuesArray["dataFilesSubScriptname"]="data-files-recursive.sh"
# valuesArray["dataFilesContentScriptname"]="data-files-content.sh"  #Not used
valuesArray["dataFilesHeaderPrefix"]="headers/"
valuesArray["dataFilesMDLoaderLine"]="filesLoader.md_"
valuesArray["dataFilesHTMLLoaderLine"]="filesLoader.htm_"
valuesArray["dataFilesJSfile"]="files.js"
valuesArray["dataGitRawfile"]="git.txt"
valuesArray["dataGitMDfile"]="git.md_"
valuesArray["dataGitHTMLfile"]="git.htm_"
valuesArray["dataWorksFilename"]="works.lst"
valuesArray["mechatronicBeingFile"]="MechatronicBeing.md"

valuesArray["folderExpandableIconPath"]="${valuesArray[""mainMBdir""]}/images/symbols/other/blacktriangleright.png"
valuesArray["folderExpandedIconPath"]="${valuesArray[""mainMBdir""]}/images/symbols/other/blacktriangledown.png"

#TEMPLATES
valuesArray["pagesTemplatesPath"]="${valuesArray[""mainMBdir""]}/templates"
valuesArray["pagesRootTemplateFilename"]="pages/root.txt"

#DOWNLOAD SCRIPTS
valuesArray["downloadScriptsDir"]="${valuesArray[""mainMBdir""]}/scripts/download"
valuesArray["downloadZipFilename"]="download-zip.sh"
valuesArray["downloadTgzFilename"]="download-tgz.sh"
valuesArray["gitCloneFilename"]="git-clone.sh"
#valuesArray["gitFetchFilename"]="git-fetch.sh"   #Not used, moved to update 'fetch' script

#WEB-STYLES FOR PAGES
valuesArray["MBWebStylesDir"]="${valuesArray[""mainMBdir""]}/styles"
valuesArray["filesWebStyleFilename"]="pages-files.css"
valuesArray["filesWebStyleCheckedFilename"]="pages-files-checked.css"
valuesArray["filesWebStyleTargetedFilename"]="pages-files-targeted.css"

#WEB-SCRIPTS FOR PAGES
valuesArray["MBPagesWebScriptsTarget"]="${valuesArray[""mainMBdir""]}/scripts/web/MechatronicBeing-pages"
valuesArray["filesWebScriptFilename"]="pages-files.js"

#WEB-SCRIPTS (libs or apps)
valuesArray["zipWebScriptTarget"]="${valuesArray[""mainMBdir""]}/scripts/web/zip"
valuesArray["zipWebScriptFilename"]="zip.js"
valuesArray["updateHtmlDynamicWebDirname"]="${valuesArray[""mainMBdir""]}/scripts/web/md2html"
valuesArray["updateHtmlDynamicWebScriptname"]="md2html.js"

#MD2HTML scripts (generating dynamic HTML pages from MD files)
valuesArray["updateHtmlSubScriptsDir"]="md2html/"
valuesArray["updateHtmlStaticScriptname"]="md2html-static.sh"
valuesArray["updateHtmlDynamicScriptname"]="update-md2html-dynamic.sh"
valuesArray["readme2indexScriptname"]="rename-readme2index.sh"
valuesArray["readme2indexFilename"]="rename-readme2index.lst"

#PAGES-FILES SCRIPTS
valuesArray["pagesFilesScriptname"]="pages-files.sh"
valuesArray["pagesFilesSubDirname"]="pages-files/"
valuesArray["pagesFilesMDScriptname"]="pages-files-md.sh"
valuesArray["pagesFilesHTMLScriptname"]="pages-files-html.sh"
valuesArray["pagesFilesJSScriptname"]="pages-files-js.sh"
#PAGES-FILES : VALUES
valuesArray["fileIconDir"]="${valuesArray[""mainMBdir""]}/images/tango-icon-library"
valuesArray["fileIconSizeDir"]="32x32"
valuesArray["pagesFilesMDFilename"]="readme.md"
valuesArray["pagesFilesHTMLFilename"]="index.html"
valuesArray["spacerTimes"]="5"

#Pages-OTHER
valuesArray["pagesOtherSubScriptDir"]="pages-other/"
valuesArray["pagesOtherRootSubScriptname"]="pages-root.sh"
valuesArray["pagesOtherListSubScriptname"]="pages-list.sh"
#Pages-OTHER > ROOT
valuesArray["rootPagesScriptname"]="pages-root.sh"
valuesArray["rootPagesDirname"]="."
valuesArray["rootMDfilename"]="readme.md"

#PATH TO PAGES (targets)
valuesArray["pagesFilesTargetDir"]="${valuesArray[""mainMBdir""]}/pages/files"
valuesArray["pageListDir"]="${valuesArray[""mainMBdir""]}/pages/list"
valuesArray["pageAuthorsDir"]="${valuesArray[""mainMBdir""]}/pages/authors"

valuesArray["pageListMDfile"]="${valuesArray[""pageListDir""]}/readme.md"
valuesArray["pageListHTMLfile"]="${valuesArray[""pageListDir""]}/index.html"


#For each parameters (=variables) ask, 
for var in "$@"; do
  #If the var is a 'scripted' variable
  if [[ "$var" == "categoryPath" || "$var" == "categoryName" || "$var" == "rootPath" || "$var" == "categoryGitPath" ]] ; then
    #Create the call to the script 
    executeFindParentDirectoryScript="${currentScriptPath}${valuesArray[""MBfunctionsScriptsDirname""]}${valuesArray[""findParentDirectoryScriptname""]}"
    #Found the path to the category dir
    categoryPath=$($executeFindParentDirectoryScript "$currentScriptPath" "{$MBScriptsLevel}${valuesArray[""backToCategoryRootDir""]}")
    #Set the variables : category and root paths, and name category
    valuesArray["categoryPath"]="${categoryPath}"
    valuesArray["categoryName"]="${categoryPath##*/}"
    valuesArray["rootPath"]="${categoryPath%/*}"
    valuesArray["categoryGitPath"]="${valuesArray[""categoryName""]}/.git"
  fi
done

  
##################################################
#Variable for the results
result=""

#Get length and values from array of parameters
argLength="$#"
argValues=("$@")

#Loop all variables in parameters
for (( i=startParameterIndex; i<argLength; i++ )); do
  #Get the variable name, in parameter
  variableName="${argValues[i]}"
  #Empty the variable value
  variableValue=""
  
  #SPECIAL EXECUTE SCRIPTS
  if [[  "$variableName" == "getRelativePath" || "$variableName" == "getAbsolutePath"  ]]; then
    #Increment i (to get the target folder
    i=$((i+1))
    
    #Get the target (in the next parameter)
    targetPath="${argValues[i]}"
    
    #Depending on the variable name 
    if [[ "$variableName" == "getRelativePath" ]]; then
    #Create the script to execute
      executeScript="${currentScriptPath}${valuesArray[""MBfunctionsScriptsDirname""]}${valuesArray[""findRelativePathScriptname""]}"
    elif [[ "$variableName" == "getAbsolutePath" ]]; then
      executeScript="${currentScriptPath}${valuesArray[""MBfunctionsScriptsDirPath""]}${valuesArray[""getAbsolutePathScriptname""]}"
    fi
    
    #Execute the script, with the targetPath, and get the result
    variableValue=$($executeScript "$targetPath")
    
  #If the variable name exist, get the value !
  elif [[ -v "valuesArray[$variableName]" ]]; then
    variableValue="${valuesArray[$variableName]}"
  else
    #Else, the variable is not present, create a fake result
    variableValue=""
    
    #write an error line in the log file
    $(${valuesArray[""writeInLogScript""]} "[ERROR] ${scriptCaller}:" "variable \"${variableName}\" does not exist.")
  fi
  
  #Result
  if [[ "$result" == "" ]]; then
    #If the result is empty, set it with the value founded
    result="$variableValue"
  else
    #Add the value to the return message (use the IFS)
    result="${result}${valuesArray[""IFSused""]}${variableValue}"
  fi
done

#return the values
echo "$result"
