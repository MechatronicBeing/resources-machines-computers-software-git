# Execute recursive options

#Take the parameters
parameter="$1"

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

  ################################################################################
  # Prepare the -real- script path
  #

    #get the current script path
    if [[ "${0:0:1}" == "/" ]]; then
      fullPath="${0}"
    else
      fullPath="${PWD}/${0#./}"
    fi
    #Simplify the path (avoid . and ..)
    simplifyPath=""
    #Loop 
    while [[ "$fullPath" != "${fullPath%%/*}" ]]; do
    
      #Get the 1st folder
      getFolder="${fullPath%%/*}"
      
      #If '..', Remove the last folder (fallback)
      if [[ "$getFolder" == ".." ]]; then
        simplifyPath="${simplifyPath%/*}"
        
      #If the folder is not empty or '.', add the folder
      elif [[ "$getFolder" != "" && "$getFolder" != "." ]]; then
        simplifyPath="${simplifyPath}/${getFolder}"
      fi
      
      #Remove the 1st folder done
      fullPath="${fullPath#*/}"
    done

    #Get the currentScript : use the path simplified and append the last string in fullpath
    currentScript="${simplifyPath}/${fullPath}"
    
    #Get the ScriptName and ScriptPath
    currentScriptName="${currentScript##*/}"
    currentScriptPath="${currentScript%/*}"

  #
  ##########################################################################
  


#INIT VARIABLES WITH GLOBAL VALUES
#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $($currentScriptPath/$globalValuesScriptname "categoryPath" "categoryName" "rootPath")

#Get the others values
read -r MBscriptsDir MBupdateScriptname  <<< $($currentScriptPath/$globalValuesScriptname "MBscriptsDir" "MBupdateScriptname")

#change to root directory
cd "$rootPath"

#Show message
echo "(${currentScriptName}) EXECUTE RECURSIVE FROM '$categoryName'"

#For each directory, with a name starting with the category
for D in $categoryName*; do
          
  #If it's a directory
  if [[ -d "$D" ]]; then
    #Skip the current directory, do only the sub-dir
    if [[ "$D" != "$categoryName" ]]; then
      #Create the call to the MB update script
      MBupdateScript="$D/${MBscriptsDir}/${MBupdateScriptname}"
      #if the script exist
      if [[ -f "$MBupdateScript" ]]; then
        #Execute it with the parameters
        $MBupdateScript "$parameter"
      fi
    fi
  fi
done
