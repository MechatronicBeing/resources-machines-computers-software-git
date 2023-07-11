#Rename readme.html to index.html if needed
#Note : not only readme.html, can be used with other files

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#Get the ABSOLUTE currentScript by calling the GlobalValues script, 
#with this script as the caller (1st, for debugging), the 'getAbsolutePath' command (2nd) and this script -again- as the target (3rd)
currentScript=$(${0%/*}/${globalValuesScriptname} "$0" "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used 
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath")

#Get the others parameters
read -r readme2indexFilename <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "readme2indexFilename")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#change to root CATEGORY directory
cd "$categoryPath"

echo "[${currentScriptName}] RENAMING README.HTML TO INDEX.HTML FOR '$categoryName'"


#Read all line in the file
while IFS= read -r file || [[ -n "$file" ]]; do
  #remove the \r at the end (else, the filepath can be 'corrupted')
  file="${file%$'\r'}"
  
  #Get the full path file
  fullpath="${categoryPath}/${file#./}"

  #if the file 'readme.html' exist
  if [[ -f "${fullpath}" ]]; then
    
    #If there is no 'index.md' file (else it will erase the new index.html)
    if ! [[ -n $(find ${fullpath%/*} -maxdepth 1 -iname "index.md") ]]; then
      #Show message
      echo "[${currentScript##*/}] RENAMING ${file} TO index.html FOR '$categoryName'"
      #rename the readme.htm to index.html
      mv "${fullpath}" "${fullpath%/*}/index.html"
    fi
  fi 
  
done < "${currentScriptPath}${readme2indexFilename}"

