#Update the 'MechatronicBeing' directory, based on the main category

#Files to save before updating
savedFiles="update-MBdir.savedFiles.lst"

#readme2indexFile
readme2indexFile="update-md2html.readme2index.lst"

#a temp directory, only for the saved files
savedFilesDir=".MB-savedFiles"

#keep the current script directory (= the information of $0 AND PWD !!!)
currentScript="$PWD/${0#./}"
currentScriptDir="${currentScript%/*}"

#the root -RELATIVE- directory (containing all OTHER categories) used for search
#Read the information in the global file
rootDir=$(cat "$currentScriptDir/../_variables/rootPath.txt")

#the MAIN directory for scripts (WORKING WITH ALL DIRECTORIES/CATEGORIES)
#WARNING : DO NOT PUT A NAME CATEGORY OR A SPECIFIC DIR, OR ELSE THE SCRIPT WILL FAIL !)
scriptsDirectory=$(cat "$currentScriptDir/_variables/MBscriptsDir.txt")

#track back previous folder to found the last directory, BEFORE the rootDir (=the last ..)
path="$currentScriptDir" 
down="$rootDir"
while :; do
  test "$down" = '..' && break
  path="${path%/*}"
  down="${down%/*}"
done
#Take only the final folder (the categoryName)
categoryName="${path##*/}"
#Remove the last ".." and save the rootPath for later !!!
rootPath="${path%/*}"

#change to root directory
cd "$rootPath"

#If the current category is not the "main", we update the dir
masterCategory=${categoryName%-*}
if ! [ "$categoryName" = "$masterCategory" ]; then 
  echo "[$0] UPDATE $categoryName/MechatronicBeing (from '$masterCategory')"

  #If a savefile exist
  if [ -f "$categoryName/$scriptsDir/$savedFiles" ]; then
    #mk a temporary dir, to save files (in the root category)
    mkdir "$categoryName/$savedFilesDir"
    #save the files before copying
    mv "$categoryName/$scriptsDir/$savedFiles" "$categoryName/$savedFilesDir/$savedFiles"
    files=$(cat "$categoryName/$savedFilesDir/$savedFiles")
    for file in $files
    do
      #If the file name doesn't start with '-' (remove)
      if  [[ "$categoryName/${file:0:1}" != '-' ]]; then
        #If the file name start with '+' (OPTIONNAL), remove it
        if  [[ "$categoryName/${file:0:1}" == '+' ]]; then
          file="${file:1}"
        fi
        #if the file/directory exist
        if [ -e "$categoryName/$file" ]; then
          mv -rf "$categoryName/$file" "$categoryName/$savedFilesDir/$file"
        fi
      fi
    done
  fi

  #remove the directory (recursive + forced)
  rm -rf "$categoryName/MechatronicBeing"
  
  #copy files from master to sub-directory
  cp -rf "$masterCategory/MechatronicBeing" "$categoryName/MechatronicBeing"
  
  #restore the saved files (if the savedFilesDir exist)
  if [ -d "$categoryName/$savedFilesDir" ]; then
    files=$(cat "$categoryName/$savedFilesDir/$savedFiles")
    for file in $files
    do
      #If the file name start with '-' (remove)
      if  [[ "$categoryName/${file:0:1}" == '-' ]]; then
        #remove the '-' in the line
        file="${file:1}"
        #if the file/directory exist : remove it
        if [ -e "$categoryName/$file" ]; then
          rm -rf "$categoryName/$file"
        fi
      else
        #If the file name start with '+' (OPTIONNAL), remove it
        if  [[ "$categoryName/${file:0:1}" != '+' ]]; then
          file="${file:1}"
        fi
        
        #if the file/directory exist, replace it
        if [ -e "$categoryName/$savedFilesDir/$file" ]; then
          mv -rf "$categoryName/$savedFilesDir/$file" "$categoryName/$file"
        fi
      fi

    done
    #move the savedFiles file for future updates
    mv -f "$categoryName/$savedFilesDir/$savedFiles" "$categoryName/$scriptsDir/$savedFiles"
    #remove the backup folder -now empty !-
    rm -rf "$categoryName/$savedFilesDir"
  else
    #1st update : empty the file (copied from the main category)
    echo "" > "$categoryName/$scriptsDir/$savedFiles"
    #Create a readme2indexFile.tmp : empty the file
    echo "" > "$categoryName/$scriptsDir/$readme2indexFile.tmp"
    
    #for each line ("readme.html" used for "index.html")
    files=$(cat "$categoryName/$scriptsDir/$readme2indexFile")
    for file in $files
    do
      #IF the line begin with './MechatronicBeing/', we CONSERVE IT
      if  [[ ${file:0:19} == "./MechatronicBeing/" ]]; then
        echo "$file" >> "$categoryName/$scriptsDir/$readme2indexFile.tmp"
      fi
      #else, the file is forgotten (not in the MechatronicBeing directory)
    done
    
    #rename the temporary file (overwrite) to the new file 
    mv -f "$categoryName/$scriptsDir/$readme2indexFile.tmp" "$categoryName/$scriptsDir/$readme2indexFile"
  fi
else
  echo "[$0] NO UPDATE ($categoryName is main)"
fi
    