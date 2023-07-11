#Update the current category AND sub-category
#Use the parameters
#call it with '?' parameter to show all the parameters 
#NOTE : "clone" of a "makefile", but in vanilla-script

#the levels (relative path) to the MB root scripts
MBScriptsLevel=""
#GlobalValues script
globalValuesScriptname="${MBScriptsLevel}getGlobalValues.sh"

#INIT VARIABLES WITH GLOBAL VALUES
#Get the ABSOLUTE currentScript : execute the GlobalValues script, with the getAbsolutePath and the $0 parameters
currentScript=$(${0%/*}/${globalValuesScriptname} "$0" "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath userSaveFile <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath" "userSaveFile")

#VARIABLES : GET THE FOLDERS VALUES
read -r mainCategoryDir scriptsUpdateDataDirname scriptsUpdateFilesDirname scriptsUpdatePagesDirname scriptsUseGitDirname <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "mainCategoryDir" "scriptsUpdateDataDirname" "scriptsUpdateFilesDirname" "scriptsUpdatePagesDirname" "scriptsUseGitDirname")

#VARIABLES : GET THE SCRIPTNAME VALUES
read -r scriptsDirectory dataWorksScriptname dataFilesScriptname updateScriptsScriptname  updateMBdirScriptname pagesAuthorsScriptname  pagesFilesScriptname updateHtmlScriptname gitMDdirScriptname gitAllDirScriptname gitClearHistoryScriptname gitRemoveGitDirScriptname pagesOtherScriptname recursiveScriptname <<<  $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "MBscriptsDir" "dataWorksScriptname" "dataFilesScriptname" "updateScriptsScriptname" "updateMBdirScriptname" "pagesAuthorsScriptname" "pagesFilesScriptname"  "updateHtmlScriptname" "gitMDdirScriptname" "gitAllDirScriptname" "gitClearHistoryScriptname" "gitRemoveGitDirScriptname" "pagesOtherScriptname" "recursiveScriptname")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#declare the associative arrays
declare -A msgArray
declare -A scriptArray
declare -A dependenciesArray
declare -A startingScriptTime

#The good order of execution of script
orderExecution="u#os#acf#R#AF#hH#gG"

#A list of special characters for Help
specialCharsList="?=yt_"

#Special characters
charHelp="?"
charDoParallel="="
charYes="y"
charTimer="t"
charForce="_"
charWaitSubProcess="#" #only used as character
charThisScript="&" #only used as character
charRecursiveOption="R"
charSilentYes="Y"

avoidShowSpecialCharacters="${charHelp}${charDoParallel}${charWaitSubProcess}${charYes}${charTimer}${charThisScript}${charForce}"

#List of special parameters
msgArray["$charHelp"]="show list of parameters"
msgArray["$charDoParallel"]="execute operations in parallel"
msgArray["$charYes"]="skip confirmations"
msgArray["$charTimer"]="show elapsed time"
msgArray["$charForce"]="do not verify dependencies (force current parameters)"

#This script (for timing the execution)
scriptArray["${charThisScript}"]="$currentScriptName"

#DATA : FILES
msgArray["f"]="analyse the files"
scriptArray["f"]="${scriptsDirectory}/$scriptsUpdateDataDirname/${dataFilesScriptname}"

#DATA : WORK
msgArray["a"]="analyse the works"
scriptArray["a"]="${scriptsDirectory}/$scriptsUpdateDataDirname/${dataWorksScriptname}"

#Update MB
msgArray["u"]="update the 'MechatronicBeing' directory (from a local parent)"
scriptArray["u"]="$scriptsDirectory/$scriptsUpdateFilesDirname/$updateMBdirScriptname"

#SCRIPT / SCRIPTS
msgArray["s"]="update the scripts"
scriptArray["s"]="$scriptsDirectory/$scriptsUpdateFilesDirname/$updateScriptsScriptname"

#Pages / Other
msgArray["o"]="update the other MB pages ('root', 'list', etc.)"
scriptArray["o"]="$scriptsDirectory/$scriptsUpdatePagesDirname/$pagesOtherScriptname"

#Pages / Authors
msgArray["A"]="update the pages : 'authors'"
scriptArray["A"]="$scriptsDirectory/$scriptsUpdatePagesDirname/$pagesAuthorsScriptname"
dependenciesArray["A"]="a"

#Pages / Files  
msgArray["F"]="update the pages : 'files'"
scriptArray["F"]="$scriptsDirectory/$scriptsUpdatePagesDirname/$pagesFilesScriptname"
dependenciesArray["F"]="f"

#(Pages) / Generates static HTML
msgArray["h"]="generate static html pages"
scriptArray["h"]="$scriptsDirectory/$scriptsUpdatePagesDirname/$updateHtmlScriptname"

#(Pages) / Generates dynamic HTML
msgArray["H"]="generate dynamic html pages"
scriptArray["H"]="$scriptsDirectory/$scriptsUpdatePagesDirname/$updateHtmlScriptname"

#Git Commit
msgArray["g"]="commit the 'MechatronicBeing' directory, to the remote repository"
scriptArray["g"]="$scriptsDirectory/$scriptsUseGitDirname/$gitMDdirScriptname"

#GIT Commit All files
msgArray["G"]="commit all the files, to the remote repository"
scriptArray["G"]="$scriptsDirectory/$scriptsUseGitDirname/$gitAllDirScriptname"

# #GIT : clear the commit history
# msgArray["g"]="clear the git commit history, and commit all the files, on the remote repository"
# scriptArray["g"]="$scriptsDirectory/$scriptsUseGitDirname/$gitClearHistoryScriptname"

# #GIT : remove the .git directory
# msgArray["G"]="remove the local '.git' directory"
# scriptArray["G"]="$scriptsDirectory/$scriptsUseGitDirname/$gitRemoveGitDirScriptname"

#Recursive
msgArray["$charRecursiveOption"]="apply the same options on the $((${#subTargetDirs[@]})) sub-$categoryName directories"
scriptArray["$charRecursiveOption"]="$scriptsDirectory/$scriptsUpdateFilesDirname/$recursiveScriptname"

#Others Messages
msgDoYouWantTo="Do you want to"
msgUsePreviousOptions="use the previous options"
msgChooseYorN="Choose 'yes' or 'no' : "
msgChooseYorNorS="Choose 'yes' or 'no' or 'skip' : "
msgTypeNumberOrS="Type a number or 'skip' : "
msgTypeYesToConfirm="Type 'yes' to start the operation : "

#Function to show the elasped time of a script ($1 : char identifier of the script)
showElaspedTime() {
  #Get the currentTimer (in seconds)
  currentTimer=$(date +"%s")
  
  #Get the script identifier (a char)
  scriptId="$1"
  
  #Get the script name
  scriptname="${scriptArray[$scriptId]##*/}" 
  
  #The currentTime - the startingTimer (in seconds) of the script (index=char of the script)
  elapsedTime=$(($currentTimer-${startingScriptTime[$scriptId]}))
  
  #Get hours / min / sec for the elapsedTime
  hrs="$((elapsedTime/3600))"
  min="$(((elapsedTime/60)%60))"
  sec="$((elapsedTime%60))"
  
  #Print the result
  echo "[$scriptname] DONE IN $hrs:$min:$sec"
}

#Show the list of parameters
showParameters () {
  choices="$1"
  echo "Current directory : '$categoryName'"
  
  #Loop for all operations
  for (( i=0; i<${#orderExecution}; i++ )); do
    #Get the current operation (=character)
    currentChar="${orderExecution:$i:1}"
    
    #If the currentCharacter is wanted AND NOT a special character to avoid showing
    if [[ "$choices" == *"$currentChar"* && "$avoidShowSpecialCharacters" != *"${currentChar}"* ]]; then
      echo "'$currentChar' : ${msgArray[$currentChar]}"
    fi
  done
  
  #Loop for special character
  for (( i=0; i<${#specialCharsList}; i++ )); do
    #Get the current special =character
    currentChar="${specialCharsList:$i:1}"
    
    #If the currentCharacter is wanted
    if [[ "$choices" == *"$currentChar"* ]]; then
      echo "'$currentChar' : ${msgArray[$currentChar]}"
    fi
  done
}

#Solve all the dependency (search the scripts needed)
checkDependencies () {
  choices="$1"
  #index for search in the user parameter
  currentIndex=0
  
  #Loop all choices
  while :; do
    #If the all user-parameters have been read, then break the loop
    if [[ "$currentIndex" > $((${#choices}-1)) ]]; then 
      break
    fi
    #Get the user parameter, in the choice
    currentUserChar="${choices:$currentIndex:1}"
    #Get the needed parameters to execute before the user wanted script
    dependencyParameters="${dependenciesArray[$currentUserChar]}"
    #For each parameter
    for (( i=0; i<${#dependencyParameters}; i++ )); do
      #Get the character
      checkDependence="${dependencyParameters:$i:1}"
      #If the dependency parameter is not in the user choice, add it to the list !
      #IMPORTANT !! the dependency (script) will be EVALUATED too (for NEW dependency to add)
      if [[ "$choices" != *"$checkDependence"* ]]; then
        choices="$choices$checkDependence"
      fi
    done
    #Increase index to seach the next user parameter
    currentIndex=$(($currentIndex+1))
  done
  
  #Return the result
  echo "$choices"
}

#sort the parameters + use the dependency to found the minimalist parameters
bestParameters () {
  #Get the parameters (choices)
  choices="$1"
  #Do a copy, for work
  bestChoices="$choices"
  #Result
  sortedBestChoices=""
  
  #Index for search
  currentIndex=0
  
  #Loop all choices
  while :; do
    #If the all user-parameters have been read, then break the loop
    if [[ "$currentIndex" -ge $((${#choices})) ]]; then 
      break
    fi
    #Get the user parameter, in the choice
    currentUserChar="${choices:$currentIndex:1}"
    #Get the needed parameters to execute before the user wanted script
    dependencyParameters="${dependenciesArray[$currentUserChar]}"
    #For each parameter
    for (( i=0; i<${#dependencyParameters}; i++ )); do
      #Get the character
      checkDependence="${dependencyParameters:$i:1}"
      #If the dependence is already met, then remove from the parameters.
      if [[ "$choices" == *"$checkDependence"* ]]; then
        bestChoices="${bestChoices//$checkDependence/}"
      fi
    done
    #Increase index to seach the next user parameter
    currentIndex=$(($currentIndex+1))
  done
  
  #sort the choices (operations)
  for (( i=0; i<${#orderExecution}; i++ )); do
    #Get the current operation (=character)
    currentChar="${orderExecution:$i:1}"
    if [[ "$bestChoices" == *"$currentChar"* ]]; then
      sortedBestChoices="${sortedBestChoices}${currentChar}"
    fi
  done
  
  #sort the choices (special characters)
  for (( i=0; i<${#specialCharsList}; i++ )); do
    #Get the current operation (=character)
    currentChar="${specialCharsList:$i:1}"
    if [[ "$bestChoices" == *"$currentChar"* ]]; then
      sortedBestChoices="${sortedBestChoices}${currentChar}"
    fi
  done
  
  echo "$bestChoices"
}

#change to root directory (containing all directories)
cd "$rootPath"

#Found all the sub-categories
subTargetDirs=()
showSubTargetDirs=""
for D in $categoryName*; do
  if ! [ "$D" == "$categoryName" ]; then 
    subTargetDirs+=("$D")
    if [[ "$showSubTargetDirs" == "" ]]; then
      showSubTargetDirs="$D"
    else
      showSubTargetDirs="$showSubTargetDirs $D"
    fi
  fi
done

#Save the parameter (the "user choices")
userChoices="$1"

#If the userChoices does not contains the silent (recursive) option, show message
if [[ "$userChoices" != *"$charSilentYes"* ]]; then

  echo "MechatronicBeing UPDATE Script"
  echo "=============================="

  #if the userchoices is empty (not in the $1 parameter)
  if [[ "$userChoices" == '' ]]; then

    #If a savefile exist, load the last options
    if [[ -f "${currentScriptPath}${userSaveFile}" ]]; then
      read -r userChoices dateLastOption hourLastOption <<< $(cat "${currentScriptPath}${userSaveFile}")

      #Use the previous options ?
      echo "$msgDoYouWantTo $msgUsePreviousOptions (\"$currentScriptName $userChoices\" the $dateLastOption at $hourLastOption) ?" 
      while read -p "$msgChooseYorN" choice; do
        case $choice in
          [Nn]* ) userChoices=""; break;;
          [Yy]* ) break;;
        esac
      done
    
      echo ""
    fi
  else
    #If ask the help '?' print the help page
    if [[ "$userChoices" == *"$charHelp"* ]]; then
      ##Call the 'help' function
      showParameters "$orderExecution"
      #exit the program
      exit
    fi
  fi

  #if the userchoices is empty (no parameters or no previous savefile or no wanted previous options)
  if [[ "$userChoices" == '' ]]; then

    #For each operation
    for (( i=0; i<${#orderExecution}; i++ )); do
      #Get the character of the operation
      char="${orderExecution:$i:1}"
      #Avoid showing special characters
      if [[ "$avoidShowSpecialCharacters" != *"${char}"* ]]; then
        #Show the message
        echo "$msgDoYouWantTo ${msgArray[$char]} ?" 
        #Ask the user if the operation is wanted
        while read -p "$msgChooseYorN" choice; do
          case $choice in
            [Nn]* ) break;;
            [Yy]* ) userChoices="$userChoices$char"; break;;
          esac
        done
      fi
    done
        
    #User scripts
    #TODO : USER SCRIPT MSG
    
    echo ""
  fi
fi

#If the choice don't have a Force parameter
if [[ "$userChoices" != *"$charForce"* ]]; then
  #Check the Dependencies
  userChoices=$(checkDependencies "$userChoices")
fi

#Simplify the parameters
showedUserChoices=$(bestParameters "$userChoices")

#If the userChoices does not contains the silent (recursive) option, show message
if [[ "$userChoices" != *"$charSilentYes"* ]]; then

  #FINAL : CONFIRMATION OF THE OPTIONS
  echo "========================="
  echo "RUNTIME PARAMETER SUMMARY"
  echo "========================="
  #Show the list parameters with the choices of the user
  showParameters $userChoices
  echo "========================="
  #Confirm the operation
  echo "ARE YOU SURE OF THESE PARAMETERS (\"$currentScriptName $showedUserChoices\") ?"
  #If the userChoice contains the charYes, avoid the confirmation
  if [[ "$showedUserChoices" != *"$charYes"* ]]; then 
    while read -p "$msgTypeYesToConfirm" confirm; do
      if [[ "$confirm" == [Yy][Ee][Ss] ]]; then
        break
      else
        exit
      fi
    done
  fi
  
  #"Visual" breakline (for between (sub-)categories
  echo "[$currentScriptName] --------------------------------------"

  #Save the parameters
  echo "$showedUserChoices $(date +'%Y-%m-%d %T')" > "${currentScriptPath}${userSaveFile}"
  
  #If the user choose recursive, add a silent to the parameters
  if [[ "$userChoices" == *"$charRecursiveOption"* ]]; then
    userChoices="${userChoices}Y"
  fi
fi

#If the user want background operation, declare an associative array (sub-process id)
if [[ "$userChoices" == *"$charDoParallel"* ]]; then
  declare -A subProcessId
fi

#Goto current category
cd "$rootPath/$categoryName"

#If a timer is needed 
if [[ "$userChoices" == *"$charTimer"* ]]; then
  #Save the current time in seconds, for this script
  startingScriptTime["$charThisScript"]=$(date +"%s")
fi

#For each execution
for (( i=0; i<${#orderExecution}; i++ )); do
  #Get the current operation (=character)
  currentChar="${orderExecution:$i:1}"
  
  #If the user want parallel operations AND the currentChar is a wait
  if [[ "$userChoices" == *"$charDoParallel"* && "$currentChar" == "$charWaitSubProcess" ]]; then
    echo "[$currentScriptName] In: '$categoryName' / Waiting sub-process to end "
    #Wait for all sub-process to end
    for pid in ${subProcessId[*]}; do 
      wait $pid; 
    done;
    #If a timer is needed
    if [[ "$userChoices" == *"$charTimer"* ]]; then
      #Print the elasped time
      showElaspedTime "$charDoParallel"
      #Restart this timer
      startingScriptTime["$charDoParallel"]=$(date +"%s")
    fi
    
  #If the current operation (character) is wanted by the user
  elif [[ "$userChoices" == *"$currentChar"* ]]; then
    #Get the script to execute
    scriptToExecute="${scriptArray[$currentChar]}"
    
    #If the script exist
    if [ -f "$scriptToExecute" ]; then
      showedScriptname="${scriptToExecute##*/}"
      

      if [[ "$userChoices" == *"$charDoParallel"* ]]; then
        #parallel operations
        echo "[$currentScriptName] In: '$categoryName' / Execute: '$showedScriptname' & "
        #Execute the script (=operation) in background and save the pid for later (waiting)
        $scriptToExecute "$userChoices" &
        subProcessId["$currentChar"]=$!
      else
        #Sequential Operations :
        
        #If a timer is needed
        if [[ "$userChoices" == *"$charTimer"* ]]; then
          #Start this timer
          startingScriptTime["$currentChar"]=$(date +"%s")
        fi
      
        #Execute the script (operation)
        echo "[$currentScriptName] In: '$categoryName' / Execute: '$showedScriptname' "
        $scriptToExecute "$userChoices"
        
        #If the timer is needed
        if [[ "$userChoices" == *"$charTimer"* ]]; then
          #Print the elasped time
          showElaspedTime "$currentChar"
        fi
      fi
    else
      #Error
      echo "[$currentScriptName] In: '$categoryName' / Error: '$scriptToExecute' does not exist."
    fi
  fi
  
done

#Script is done, show elasped time (if wanted)
if [[ "$userChoices" == *"$charTimer"* ]]; then
  showElaspedTime "$charThisScript"
fi
