#Analyse the folders/files :
# 1) in the current category, without .git and MB folders
# 2) in the MechatronicBeing folder
# 3) in the .git folder
#write a HEADER in the 1st line, and file/folder information on the other lines
#Note : information printed like a ls command (very 'formated')

#the levels (relative path) to the MB root scripts
MBScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${MBScriptsLevel}getGlobalValues.sh"

#Get the ABSOLUTE currentScript by calling the GlobalValues script, 
#with this script as the caller (1st, for debugging), the 'getAbsolutePath' command (2nd) and this script -again- as the target (3rd)
currentScript=$(${0%/*}/${globalValuesScriptname} "$0" "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used 
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath categoryGitPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath" "categoryGitPath")

#Get other values : data-files, separators and the checksum command
read -r filesDataPath dataFilesRawfile dataMBFilesfile mainMBdir dataGitfile tabCharacter dataFilesRawFS dataFilesRawIdFS dataFilesChecksumCommand <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "filesDataPath" "dataFilesRawfile" "dataMBFilesfile" "mainMBdir" "dataGitfile" "tabCharacter" "dataFilesRawFS" "dataFilesRawIdFS" "dataFilesChecksumCommand")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#change to ROOT directory
cd "$rootPath"

if [[ "$dataFilesChecksumCommand" != "" ]]; then
  msgChecksumOption="(with checksum) "
else
  msgChecksumOption=""
fi

#Show current directory
echo "(${currentScriptName}) CREATING LIST OF FILES ${msgChecksumOption}FOR '$categoryName'"

#Create data directory (if not exist)
if [[ ! -d "$categoryPath/$filesDataPath" ]]; then
  mkdir -p "$categoryPath/$filesDataPath"
fi

#RECURSIVE FUNCTION
#$1 : the folder to use
#$2 : the ID of the current folder
#$3 : the file to use for writing the information
#$4 : options (summary...)
#$5 to the end : path to exclude from analysis
#STEP 1 : get the information of the current folder and print it
#STEP 2 : for each sub-folders, call the recursive function
#STEP 3 : for each sub-files, get the information and print it
#BEWARE : in recursive, important variables -used later in the code- NEED TO BE LOCAL to work !!!!
doFolder()
{
  #Get path of the current folder
  local itemFullPath="$1"
  
  #Get the id for the current folder
  local itemId="$2"
  
  #Get the file to write
  local fileToWrite="$3"
  
  #Get the options (summary...)
  local options="$4"
  
  #Exclude paths
  local listPathsExcluded=()
  local excludePaths=()
  local notPathFolders=()
  local notPathFiles=()
   
  #Exclude paths
  for (( i=5; i<=$#; i++ )); do
    pathExcluded="${!i}"
    listPathsExcluded+=( "$pathExcluded" )

    excludePaths+=("--exclude=${pathExcluded}")
    notPathFiles+=("-not" "-path" "${pathExcluded}/*")
    notPathFolders+=("-not" "-path" "${pathExcluded}/*" "-not" "-path" "${pathExcluded}")
  done
  
  #Create an items counter for the current folder
  local currentItemsCounter=0
  
  ######## STEP 1 : get the information of the current folder and print it
  
  #is a folder
  itemType="FOLDER"
  
  #get the numbers of files
  filesNumber=$((`find "$itemFullPath" -maxdepth 1  -mindepth 1 -type f "${notPathFiles[@]}" | wc -l`))
  
  #Get number of dirs
  #Note : use local variable, used later to update the itemCounter before the files loop
  local dirsNumber=$((`find "$itemFullPath" -maxdepth 1 -mindepth 1 -type d "${notPathFolders[@]}" | wc -l`))
  
  #Count all files founded in the current directory
  filesNumberTotal=$((`find "$itemFullPath" -mindepth 1 -type f "${notPathFiles[@]}" | wc -l`))
  
  #Count all directories founded 
  dirsNumberTotal=$((`find "$itemFullPath" -mindepth 1 -type d "${notPathFolders[@]}" | wc -l`))

  #Get folder size and last time of modification
  lineInfo=$(du -s --time -B1 --apparent-size "${excludePaths[@]}" "$itemFullPath")
  itemSize="${lineInfo%%${tabCharacter}*}"; lineInfo="${lineInfo#*${tabCharacter}}"
  datetimeOfLastModifItem="${lineInfo%%${tabCharacter}*}"
  
  #If the checksum command is set
  if [[ "${dataFilesChecksumCommand}" != "" ]]; then
    #Print a fake checksum result
    itemChecksum="-${dataFilesRawFS}"
  else
    #No checksum column
    itemChecksum=""
  fi
 
  #write the folder-line
  echo "${itemId}${dataFilesRawFS}${itemType}${dataFilesRawFS}${itemSize}${dataFilesRawFS}${datetimeOfLastModifItem}${dataFilesRawFS}${filesNumber}${dataFilesRawFS}${filesNumberTotal}${dataFilesRawFS}${dirsNumber}${dataFilesRawFS}${dirsNumberTotal}${dataFilesRawFS}${itemChecksum}${itemFullPath}" >> "${fileToWrite}"
  
  #Continue only if not summary option
  if [[ "$options" != *"s"* ]]; then
  
    ######### STEP 2 : for each sub-folders, call the recursive function
    
    #Loop all sub-folders
    find "$itemFullPath" -maxdepth 1 -mindepth 1 -type d "${notPathFolders[@]}" | while read -r folderInside; do
      #increment the current item Number
      local currentItemsCounter=$(($currentItemsCounter+1))
      #Call the recursive function with the new folder and the new itemID
      doFolder "$folderInside" "${itemId}${dataFilesRawIdFS}${currentItemsCounter}" "${fileToWrite}" "$options" "${listPathsExcluded[@]}"
    done
    
    ######## STEP 3 : for each sub-files, get the information and print it
    
    #Cheat : use the dirsNumber to correct the ItemCounter
    #Because the variable is not updated outside the loop because of the pipe '|' !!!
    local currentItemsCounter=$(($dirsNumber))
    
    #Loop all sub-files
    find "$itemFullPath" -maxdepth 1 -mindepth 1 -type f "${notPathFiles[@]}" | while read -r fileInside; do
      #increment the current item Number
      local currentItemsCounter=$(($currentItemsCounter+1))
      
      #Is a file
      itemType="FILE"
      
      #Get the file Id
      fileId="${itemId}${dataFilesRawIdFS}${currentItemsCounter}"

      #Get folder size and last time of modification
      lineInfo=$(du -s --time -B1 --apparent-size "${excludePaths[@]}" "$fileInside")
      itemSize="${lineInfo%%${tabCharacter}*}"; lineInfo="${lineInfo#*${tabCharacter}}"
      datetimeOfLastModifItem="${lineInfo%%${tabCharacter}*}"

      #If the checksum command is set
      if [[ "${dataFilesChecksumCommand}" != "" ]]; then
        #If the command contains "/", it's a path from the category
        if [[ "${dataFilesChecksumCommand}" != "${dataFilesChecksumCommand%%/*}" ]]; then
          #Add the category path
          pathToCommand="${categoryPath}/"
        else
          #else, it's a system command, leave the path empty
          pathToCommand=""
        fi
        
        #Do Checksum
        checksumResult=$(${pathToCommand}${dataFilesChecksumCommand} "${rootPath}/${fileInside}")

        #Get the 1st field and add the dataFilesRawFS for printing
        itemChecksum="${checksumResult%% *}${dataFilesRawFS}"
      else
        itemChecksum=""
      fi
      
      #get the numbers of files
      noFilesNumber="-"
      noDirsNumber="-"
      noFilesNumberTotal="-"
      noDirsNumberTotal="-"
      
      #write the file-line
      echo "${fileId}${dataFilesRawFS}${itemType}${dataFilesRawFS}${itemSize}${dataFilesRawFS}${datetimeOfLastModifItem}${dataFilesRawFS}${noFilesNumber}${dataFilesRawFS}${noFilesNumberTotal}${dataFilesRawFS}${noDirsNumber}${dataFilesRawFS}${noDirsNumberTotal}${dataFilesRawFS}${itemChecksum}${fileInside}" >> "${fileToWrite}"
    done
  
  fi
}

#If the checksum command is not empty
if [[ "${dataFilesChecksumCommand}" != "" ]]; then
  #Create the column and add the dataFilesRawFS for printing
  checksumHeader="CHECKSUM${dataFilesRawFS}"
else
  #else, Print nothing
  checksumHeader=""
fi

#Print the Header for the main file
echo "ID${dataFilesRawFS}TYPE${dataFilesRawFS}SIZE${dataFilesRawFS}LAST_MODIFIED_DATE${dataFilesRawFS}LAST_MODIFIED_TIME${dataFilesRawFS}#SUB-FILES${dataFilesRawFS}TOTAL_SUB-FILES${dataFilesRawFS}#SUB-FOLDERS${dataFilesRawFS}TOTAL_SUB-FOLDERS${dataFilesRawFS}${checksumHeader}PATH" > "${categoryPath}/${dataFilesRawfile}"

#Analyse the files in the folder, but EXCLUDE .git and mechatronicbeing folders
doFolder "$categoryName" "$categoryName" "${categoryPath}/${dataFilesRawfile}" "" "$categoryGitPath" "${categoryName}/${mainMBdir}"

#Print the Header for the MB file
echo "ID${dataFilesRawFS}TYPE${dataFilesRawFS}SIZE${dataFilesRawFS}LAST_MODIFIED_DATE${dataFilesRawFS}LAST_MODIFIED_TIME${dataFilesRawFS}#SUB-FILES${dataFilesRawFS}TOTAL_SUB-FILES${dataFilesRawFS}#SUB-FOLDERS${dataFilesRawFS}TOTAL_SUB-FOLDERS${dataFilesRawFS}${checksumHeader}PATH" > "${categoryPath}/${dataMBFilesfile}"

#Analyse the files in mechatronicbeing folder
doFolder "${categoryName}/${mainMBdir}" "${categoryName}${dataFilesRawIdFS}MB" "${categoryPath}/${dataMBFilesfile}" ""

#Print the Header for the git file
echo "ID${dataFilesRawFS}TYPE${dataFilesRawFS}SIZE${dataFilesRawFS}LAST_MODIFIED_DATE${dataFilesRawFS}LAST_MODIFIED_TIME${dataFilesRawFS}#SUB-FILES${dataFilesRawFS}TOTAL_SUB-FILES${dataFilesRawFS}#SUB-FOLDERS${dataFilesRawFS}TOTAL_SUB-FOLDERS${dataFilesRawFS}${checksumHeader}PATH" > "${categoryPath}/${dataGitfile}"

#Analyse the git folder, do only a summary (1st line)
if [[ -d "$categoryGitPath" ]]; then
  doFolder "$categoryGitPath"  "${categoryName}${dataFilesRawIdFS}git" "${categoryPath}/${dataGitfile}" "s"
fi
