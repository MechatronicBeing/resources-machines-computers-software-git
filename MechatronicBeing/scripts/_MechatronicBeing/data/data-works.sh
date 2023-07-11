#Create a data file for the current category, with all works founded

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#keep the current script directory (= the information of $0 AND PWD !!!)
currentScript="$PWD/${0#./}"
currentScriptDir="${currentScript%/*}"

#INIT VARIABLES WITH GLOBAL VALUES
#the relative category path 
relativeCategoryPath=$($currentScriptDir/$globalValuesScriptname "categoryPath")
#Get the findParentDirectory script function
read -r MBfunctionsScriptsDirname findParentDirectoryScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findParentDirectoryScriptname")
#Create the call to the script later
executeFindParentDirectoryScript="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findParentDirectoryScriptname"
#the functions for trimming spaces
read -r MBfunctionsScriptsDirname trimSpacesScriptname <<< $($currentScriptDir/$globalValuesScriptname "MBfunctionsScriptsDirname" trimSpacesScriptname) #"trimTrailingSpacesScriptname" "trimLeadingSpacesScriptname"
#Create the scripts path for execution 
trimSpaces="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$trimSpacesScriptname"
## trimLeadingSpaces="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$trimLeadingSpacesScriptname"
##trimTrailingSpaces="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$trimTrailingSpacesScriptname"
#the data savefile path + filename
read -r dataPath dataWorksFilename  <<< $($currentScriptDir/$globalValuesScriptname  "dataPath" "dataWorksFilename")
#the main file for ALL MechatronicBeing resources (describing authors, works, licence...)
mechatronicBeingFile=$($currentScriptDir/$globalValuesScriptname "mechatronicBeingFile")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#The filename to the temporary list
tmpWorksList="workList.tmp"

#change to root directory
cd "$categoryPath"

#Show message
echo "(${currentScript##*/}) CREATING LIST OF WORKS FOR '$categoryName'"

find . -type f -iname "$mechatronicBeingFile" | while IFS= read -r mbFile; do 
  #get all informations
  authorName=""
  authorWebsite=""
  authorWorkName=""
  authorWorkLicenses=""
  authorWorkSource=""
  authorWorkType=""
  authorWorkDescription=""
  
  #Get the path (remove ./ at start from find)
  authorWorkPath="${mbFile#./}"
  #Remove the filename
  authorWorkPath="${authorWorkPath%/*}"
  
  #Read the file to found the data
  while read line; do 
    #Take the only 15 first characters AND 
    startLine="${line:0:15}"
    #UUppercase the text
    startLine="${startLine^^}"
    #If the variable is not founded AND start with the keyword
    if [[ "$authorName" == "" && "$startLine" =~ "AUTHOR" ]]; then
      authorName="${line#*:}"
    elif [[ "$authorWebsite" == "" && "$startLine" =~ "WEBSITE" ]]; then
      authorWebsite="${line#*:}"
    elif [[ "$authorWorkLicenses" == "" && "$startLine" =~ "LICENSE" ]]; then
      authorWorkLicenses="${line#*:}"
    elif [[ "$authorWorkName" == "" && "$startLine" =~ "NAME" ]]; then
      authorWorkName="${line#*:}"
    elif [[ "$authorWorkName" == "" && "$startLine" =~ "TITLE" ]]; then
      authorWorkName="${line#*:}"
    elif [[ "$authorWorkSource" == "" && "$startLine" =~ "SOURCE" ]]; then
      authorWorkSource="${line#*:}"
    elif [[ "$authorWorkType" == "" && "$startLine" =~ "TYPE" ]]; then
      authorWorkType="${line#*:}"
    elif [[ "$authorWorkDescription" == "" && "$startLine" =~ "DESCRIPTION" ]]; then
      authorWorkDescription="${line#*:}"
    fi
    
    #If all data is founded, stop reading the file
    if [[ "$authorName" != "" && "$authorWorkLicenses" != "" && "$authorWebsite" != "" && "$authorWorkName" != "" && "$authorWorkSource" != "" && "$authorWorkType" != "" && "$authorWorkDescription" != "" ]]; then
      break
    fi
  done < "$mbFile"
  
  #If the work name is not founded, add the name folder.
  if [[ "$authorWorkName" == "" ]]; then
    authorWorkName="${authorWorkPath##*/}"
  fi
  
  #TRIM SPACES
  showedAuthorName=$($trimSpaces "$authorName")
  showedAuthorWebsite=$($trimSpaces "$authorWebsite")
  showedAuthorWorkName=$($trimSpaces "$authorWorkName")
  showedAuthorWorkSource=$($trimSpaces "$authorWorkSource")
  showedAuthorWorkLicenses=$($trimSpaces "$authorWorkLicenses")
  showedAuthorWorkType=$($trimSpaces "$authorWorkType")
  authorWorkDescription=$($trimSpaces "$authorWorkDescription")
  
  echo "$showedAuthorName | $showedAuthorWebsite | $showedAuthorWorkName | $showedAuthorWorkSource | $authorWorkDescription | $showedAuthorWorkType | $showedAuthorWorkLicenses | ${authorWorkPath}/ " >> "$rootPath/${categoryName}_${tmpWorksList}"
done

# Create target directory (if not exist)
if [[ ! -e "$categoryPath/$dataPath/" ]]; then
  mkdir -p "$categoryPath/$dataPath/"
fi

#Sort alphabetically the author list in the file
cat "$rootPath/${categoryName}_${tmpWorksList}" | sort -k1 > "$categoryPath/$dataPath/$dataWorksFilename"
#Remove the temporary file
rm "$rootPath/${categoryName}_${tmpWorksList}"