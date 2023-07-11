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
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath")

#get the script for renaming (readme.html to index.html)
read -r pagesOtherSubScriptDir pagesOtherRootSubScriptname pagesOtherListSubScriptname <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "pagesOtherSubScriptDir" "pagesOtherRootSubScriptname" "pagesOtherListSubScriptname")

echo "(${currentScript##*/}) CREATING OTHER PAGES"
 
#Execute the list page creation
${currentScriptPath}${pagesOtherSubScriptDir}${pagesOtherRootSubScriptname}

#Execute the root page creation
${currentScriptPath}${pagesOtherSubScriptDir}${pagesOtherListSubScriptname}
