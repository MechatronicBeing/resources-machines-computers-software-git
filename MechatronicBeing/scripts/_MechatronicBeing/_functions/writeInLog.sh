#write a line (from parameters) in the logfile

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

#Get the IFS used by IFSdefault
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the findRelativePath script function
MBlogFile=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "MBlogFile")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#Touch the error file
touch "${MBlogFile}"

#Write the date (don't add newline)
echo -n "$(date +"%Y-%m-%d %T"): " >> "${MBlogFile}"
#For each parameters added to the script, write-it to the log (but don't print a newline, with -n parameter)
for var in "$@"; do
  echo -n "${var} " >> "${MBlogFile}"
done

#Finally, add a new line
echo "" >> "${MBlogFile}"
