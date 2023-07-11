# Create files with lines related for each directories starting with a same name

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
#Get the target directory and files
read -r targetDir downloadZipFilename downloadTgzFilename gitCloneFile <<< $($currentScriptDir/$globalValuesScriptname "downloadScriptsDir" "downloadZipFilename" "downloadTgzFilename" "gitCloneFilename")
#Get the target directory and files
read -r mainCategory repositoryName onlinearchiveZipFile onlineArchiveTgzFile <<< $($currentScriptDir/$globalValuesScriptname  "mainCategory" "onlineRepositoryName" "onlineArchiveZipFile" "onlineArchiveTgzFile")

##Found the important paths
categoryPath=$($executeFindParentDirectoryScript "$currentScriptDir" "$rootScriptsLevel/$relativeCategoryPath")
#Take only the final folder (the categoryName)
categoryName="${categoryPath##*/}"
#Move one folder and save the rootPath for later !!!
rootPath="${categoryPath%/*}"

#change to root directory
cd "$rootPath"

#Show message
echo "(${currentScript##*/}) CREATING DOWNLOAD SCRIPTS FOR '$categoryName'"

#Prepare files (with a header / 1st line)
echo "echo \"Download (and extract) remote $categoryName to your local\"" > "$rootPath/${categoryName}_${downloadZipFilename}.tmp"
echo "echo \"Download (and extract) remote $categoryName to your local\"" > "$rootPath/${categoryName}_${downloadTgzFilename}.tmp"
echo "echo \"GIT Clone remote $categoryName to your local\"" > "$rootPath/${categoryName}_${gitCloneFile}.tmp"

#For each directory, with a name starting with the category
for D in $categoryName*; do
          
  #If it's a directory
  if [[ -d "$D" ]]; then 
    #Write lines in files
    #For TGZ download
    echo "curl -LO ${repositoryName}${D}/${onlineArchiveTgzFile}" >> "$rootPath/${categoryName}_${downloadTgzFilename}.tmp"
    echo "tar -xf ${onlineArchiveTgzFile##*/}" >> "$rootPath/${categoryName}_${downloadTgzFilename}.tmp"
    echo "mv ${D}-main ${D}" >> "$rootPath/${categoryName}_${downloadTgzFilename}.tmp"
    echo "rm ${onlineArchiveTgzFile##*/}" >> "$rootPath/${categoryName}_${downloadTgzFilename}.tmp"
    #For Zip download
    echo "curl -LO ${repositoryName}${D}/$onlinearchiveZipFile" >> "$rootPath/${categoryName}_${downloadZipFilename}.tmp"
    echo "unzip ${onlinearchiveZipFile##*/}" >> "$rootPath/${categoryName}_${downloadZipFilename}.tmp"
    echo "mv ${D}-main ${D}" >> "$rootPath/${categoryName}_${downloadZipFilename}.tmp"
    echo "rm ${onlinearchiveZipFile##*/}" >> "$rootPath/${categoryName}_${downloadZipFilename}.tmp"
    #Git scripts
    echo "git clone --progress -v \"${repositoryName}${D}.git\"" >> "$rootPath/${categoryName}_${gitCloneFile}.tmp"
  fi
done

#Create target directory (if not exist)
if [[ ! -e "$rootPath/$categoryName/$targetDir/" ]]; then
  mkdir -p "$rootPath/$categoryName/$targetDir/"
fi

#Rename the temp file (by removing the .tmp at end)
mv "$rootPath/${categoryName}_${downloadTgzFilename}.tmp" "$rootPath/$categoryName/$targetDir/$downloadTgzFilename"
mv "$rootPath/${categoryName}_${downloadZipFilename}.tmp" "$rootPath/$categoryName/$targetDir/$downloadZipFilename"
mv "$rootPath/${categoryName}_${gitCloneFile}.tmp" "$rootPath/$categoryName/$targetDir/$gitCloneFile"