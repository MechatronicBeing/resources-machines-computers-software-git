#Create dynamic HTML files from Markdown
#WARNING : in development/testing.

#Get the parameter filepath
fileToConvert="$1"

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

#Get the IFS used by IFSdefault
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath")

#Get the others parameters
read -r  scriptsDir scriptName spaceEscape <<< $(${currentScriptPath}${globalValuesScriptname}  "$currentScript" "updateHtmlDynamicWebDirname" "updateHtmlDynamicWebScriptname" "escapeSpacesInUrl")

#the -RELATIVE- path used IN the final page
filepathMD="${fileToConvert%/*}"
####NOT SURE IF THIS WORK !!!!!! UNTESTED
relativeFilePath=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "${filepathMD#./}")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#Create the html files (name file or index.html -if renamed-)
pathWithoutExt="${fileToConvert%.*}"
htmlFileCreated="${pathWithoutExt}.html"
fileNameWithoutExt="${pathWithoutExt##*/}"

echo "((${currentScript##*/})) GENERATING DYNAMIC '${htmlFileCreated}'"

#escape space in url
filenameProtected="${fileNameWithoutExt// /$spaceEscape}"

#Create a new html file, with scripts (trying to load the md file) and noscript (embed the mdfile)
echo "<!DOCTYPE html>" > "${htmlFileCreated}"
echo "<html>" >> "${htmlFileCreated}"
echo "<head>" >> "${htmlFileCreated}"
echo "<title>${fileNameWithoutExt%.*}</title>" >> "${htmlFileCreated}"
echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> "${htmlFileCreated}"
echo "<meta charset=\"UTF-8\">" >> "${htmlFileCreated}"
echo "</head>" >> "${htmlFileCreated}"
echo "<body>" >> "${htmlFileCreated}"
echo "<div id=\"divMD\" data-mdFile=\"${filenameProtected}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></div>" >> "${htmlFileCreated}"
echo "<noscript><embed id=\"embedMD\" src=\"${filenameProtected}\" frameborder=\"0\" allowfullscreen style=\"position:absolute;top:0;left:0;width:100%;height:100%;\"></noscript>" >> "${htmlFileCreated}"
echo "<script src=\"$relativeFilePath/$scriptsDir/$scriptName\"></script>" >> "${htmlFileCreated}"
echo "</body>" >> "${htmlFileCreated}"
echo "</html>" >> "${htmlFileCreated}"
