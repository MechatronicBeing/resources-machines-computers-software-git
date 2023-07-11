#Create HTML files from Markdown

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#Get only the 1st parameter
userChoices="${1%% *}"

#Get the ABSOLUTE currentScript by calling the GlobalValues script, 
#with this script as the caller (1st, for debugging), the 'getAbsolutePath' command (2nd) and this script -again- as the target (3rd)
currentScript=$(${0%/*}/${globalValuesScriptname} "$0" "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used by IFSdefault
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath")

#Get other values
read -r updateHtmlSubScriptsDir updateHtmlStaticScriptname updateHtmlDynamicScriptname readme2indexScriptname readme2indexFilename <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "updateHtmlSubScriptsDir" "updateHtmlStaticScriptname" "updateHtmlDynamicScriptname" "readme2indexScriptname" "readme2indexFilename")
executeUpdateHtmlStaticScript="$currentScriptPath/${updateHtmlSubScriptsDir}${updateHtmlStaticScriptname}"
executeUpdateHtmlDynamicScript="$currentScriptPath/${updateHtmlSubScriptsDir}${updateHtmlDynamicScriptname}"
executeReadme2indexScript="$currentScriptPath/${updateHtmlSubScriptsDir}${readme2indexScriptname}"

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#change to root CATEGORY directory
cd "$categoryPath"

echo "(${currentScript##*/}) GENERATING HTML PAGES FOR '$categoryName'"

#Found the md files updated :
#for each md file, execute du -time to get the datetime of last modified before the full filepath.
find . -type f -iname '*.md' -exec du --time {} + | while IFS=$'\t' read -r sizeFile datetimeOfLastModifFile filepathMD; do 
  
  #Get file without extension
  pathnameWithoutFileExt="${filepathMD%.*}"
  filename="${filepathMD##*/}"
  fileLocation="${filepathMD%/*}"
  
  #Create the html files (name file or index.html -if renamed-)
  htmlFileCreated="${pathnameWithoutFileExt}.html"
  htmlFileRenamed="${fileLocation}/index.html"
  
  if [[ -f "$htmlFileCreated" ]]; then
    #The .html exist (previously generated), get the datatime of last modification
    IFS=$'\t' read -r size htmlFileDTLastModification filename <<< $(du --time --time-style=+'%Y-%m-%d %H:%M:%S' "$htmlFileCreated")
  
  elif [[ "${filename^^}" == "README.MD" && -f "$htmlFileRenamed" && ! -f "${fileLocation}/index.md" ]]; then
    #File is readme.md, there is a previous index.html but no index.md, get the datetime of last modification of the index.html (maybe the readme.html was renamed to index.html ?)
    IFS=$'\t' read -r size htmlFileDTLastModification filename <<< $(du --time --time-style=+'%Y-%m-%d %H:%M:%S' "$htmlFileRenamed")
  else
    #no html file founded : no date of modification.
    htmlFileDTLastModification=""
  fi
  #If the date time of last modification of MD file is newer than the date of modification (creation) of the html file
  if [[ "$datetimeOfLastModifFile" > "$htmlFileDTLastModification" ]]; then
  
    #Remove './' at start
    filepathMD="${filepathMD#./}" 
  
    #Generate the html...
    if [[ "$userChoices" == *"$charUpdateHtmlStaticScript"* ]]; then
      #Using the static script
      $executeUpdateHtmlStaticScript "$filepathMD"
    elif [[ "$userChoices" == *"$charUpdateHtmlDynamicScript"* ]]; then
      #Using the dynamic script
      $executeUpdateHtmlDynamicScript "$filepathMD"
    fi
    
    #If the filename is README and the html page was generated, BUT NO index.html NO index.md inside the folder
    if [[ "${filename^^}" == "README" && -f "$htmlFileCreated" && ! -f "$htmlFileRenamed" && ! -f "${fileLocation}/index.md" ]]; then
      #Add it to the readme2index file
      echo "$htmlFileCreated" >> "${currentScriptPath}${updateHtmlSubScriptsDir}$readme2indexFilename"
    fi
  fi
done

#Ask the sub-script to rename the readme.html to index.html needed
$executeReadme2indexScript
