# Create files with lines related for the current category


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
#Get the findRelativePath script function
read -r MBfunctionsScriptsDirname findRelativePathScriptname  <<< $($currentScriptDir/$globalValuesScriptname  "MBfunctionsScriptsDirname" "findRelativePathScriptname")
#Create the call to the script later
executeFindRelativePathScriptname="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$findRelativePathScriptname"
#the functions for trimming spaces
read -r MBfunctionsScriptsDirname trimSpacesScriptname <<< $($currentScriptDir/$globalValuesScriptname "MBfunctionsScriptsDirname" trimSpacesScriptname) 
#Create the scripts path for execution 
trimSpaces="$currentScriptDir/$rootScriptsLevel/$MBfunctionsScriptsDirname/$trimSpacesScriptname"
#the data savefile path + filename
read -r worksDataDir worksDataFile  <<< $($currentScriptDir/$globalValuesScriptname  "dataPath" "dataWorksFilename")
#In case of names with spaces, replace the " " with "%20"
spaceEscape=$($currentScriptDir/$globalValuesScriptname "escapeSpacesInUrl")
#Get others parameters
read -r targetDir repositoryDir  <<< $($currentScriptDir/$globalValuesScriptname  "pageAuthorsDir" "repositoryDirAdjust")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#the -RELATIVE- path used IN the final page [CALCULATED from the target dir]
#Add 1 more folder : the final folder (not in the targetDir)
showedRelativeFinalTarget=$($executeFindRelativePathScriptname "$targetDir" 1)

#The 2 md files
mdFiles=("readme.md.tmp" "index.md.tmp")

#Headers used in the Authors list
listFileHeader1="| **Authors** | **Works** | **Types** | **Licences** | **Folders** |  " 
listFileHeader2="| ----------- | --------- | --------- | ------------ | ----------- |  " 


#change to root directory
cd "$categoryPath"

#Show message
echo "(${currentScript##*/}) CREATING PAGE OF AUTHORS IN '$categoryName'"

#If the file authors exist, generate the content 
if [[ -e "$worksDataDir/$worksDataFile" ]]; then

  #Write header for the 2 filename (no difference)
  for mdFile in ${mdFiles[@]}; do
    echo "## List of authors and works in \"$categoryName\"  " > "$rootPath/${categoryName}_authors_$mdFile"
    echo "  " >> "$rootPath/${categoryName}_authors_$mdFile"
    echo "$listFileHeader1" >> "$rootPath/${categoryName}_authors_$mdFile"
    echo "$listFileHeader2" >> "$rootPath/${categoryName}_authors_$mdFile"
  done
  
  #Read the the list of authors
  while IFS= read -r line; do 
  
    #If the line is not empty
    if [[ "$line" != "" ]]; then
      #get all information (order is important !)
      authorName=`echo "$line" | cut -d'|' -f1`
      authorWebsite=`echo "$line" | cut -d'|' -f2`
      authorWorkName=`echo "$line" | cut -d'|' -f3`
      authorWorkSource=`echo "$line" | cut -d'|' -f4`
      authorWorkDescription=`echo "$line" | cut -d'|' -f5`
      authorWorkType=`echo "$line" | cut -d'|' -f6`
      authorWorkLicenses=`echo "$line" | cut -d'|' -f7`
      authorWorkPath=`echo "$line" | cut -d'|' -f8`
      
      #TRIM SPACES
      showedAuthorName=$($trimSpaces "$authorName")
      showedAuthorWebsite=$($trimSpaces "$authorWebsite")
      showedAuthorWorkName=$($trimSpaces "$authorWorkName")
      showedAuthorWorkSource=$($trimSpaces "$authorWorkSource")
      showedAuthorWorkDescription=$($trimSpaces "$authorWorkDescription")
      showedAuthorWorkType=$($trimSpaces "$authorWorkType")
      showedAuthorWorkLicenses=$($trimSpaces "$authorWorkLicenses")
      showedAuthorWorkPath=$($trimSpaces "$authorWorkPath")
      
      #Escape the spaces in url !!!!
      showedAuthorWorkPath="${showedAuthorWorkPath// /$spaceEscape}"
      showedAuthorWebsite="${showedAuthorWebsite// /$spaceEscape}"
      showedAuthorWorkSource="${showedAuthorWorkSource// /$spaceEscape}"
      
      #Escape all " in string by \"
      showedAuthorName="${showedAuthorName//\"/\\\"}"
      showedAuthorWebsite="${showedAuthorWebsite//\"/\\\"}"
      showedAuthorWorkName="${showedAuthorWorkName//\"/\\\"}"
      showedAuthorWorkSource="${showedAuthorWorkSource//\"/\\\"}"
      showedAuthorWorkDescription="${showedAuthorWorkDescription//\"/\\\"}"
      showedAuthorWorkType="${showedAuthorWorkType//\"/\\\"}"
      showedAuthorWorkLicenses="${showedAuthorWorkLicenses//\"/\\\"}"
      showedAuthorWorkPath="${showedAuthorWorkPath//\"/\\\"}"
      
      #If the AuthorWebsite is not empty, form an url with the author name // else, just show the name author
      if [[ "$showedAuthorWebsite" != "" ]]; then
        showedAuthorField="[$showedAuthorName]($showedAuthorWebsite)"
      else
        showedAuthorField="$showedAuthorName"
      fi
      
      #IF a description of the work is present, show it as a tooltip (to simplify the display)
      if [[ "$showedAuthorWorkDescription" != "" ]]; then
        #If the WorkSource is not empty, form an url with the work name // else, just show the work name
        if [[ "$showedAuthorWorkSource" != "" ]]; then
          showedSourceField="[$showedAuthorWorkName]($showedAuthorWorkSource \"$showedAuthorWorkDescription\")"
        else
          showedSourceField="[$showedAuthorWorkName](\"$showedAuthorWorkDescription\")"
        fi
      else
        #If the WorkSource is not empty, form an url with the work name // else, just show the work name
        if [[ "$showedAuthorWorkSource" != "" ]]; then
          showedSourceField="[$showedAuthorWorkName]($showedAuthorWorkSource)"
        else
          showedSourceField="$showedAuthorWorkName"
        fi
      fi
      
      #Write to INDEX (normal path)
      echo "| **$showedAuthorField** | *$showedSourceField* | $showedAuthorWorkType | $showedAuthorWorkLicenses | [files]($showedRelativeFinalTarget/$showedAuthorWorkPath) |  " >> "$rootPath/${categoryName}_authors_index.md.tmp"
      
      #Write to README (Add repository path with the normal path !!)
      echo "| **$showedAuthorField** | *$showedSourceField* | $showedAuthorWorkType | $showedAuthorWorkLicenses | [files]($showedRelativeFinalTarget/$repositoryDir/$showedAuthorWorkPath) |  " >> "$rootPath/${categoryName}_authors_readme.md.tmp"
      
    fi
  done < "$worksDataDir/$worksDataFile"

fi

#Create target directory (if not exist)
if [[ ! -e "$targetDir/" ]]; then
  mkdir -p "$targetDir/"
fi

#For the 2 filename (no difference)
for mdFile in ${mdFiles[@]}; do
  #move the files
  mv "$rootPath/${categoryName}_authors_$mdFile" "$targetDir/${mdFile%.tmp}"
done
