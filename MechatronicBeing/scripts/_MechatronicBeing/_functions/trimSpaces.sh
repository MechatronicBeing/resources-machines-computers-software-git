#Function : Trim Leading AND Trailing Spaces, from $1

#keep the current script directory (= the information of $0 ONLY !!!)
currentScript="${0#./}"
currentScriptDir="${currentScript%/*}"

#The scripts are used directly (NO getter script !)
trimLeadingSpaces="$currentScriptDir/trimLeadingSpaces.sh"
trimTrailingSpaces="$currentScriptDir/trimTrailingSpaces.sh"

#Call the functions with the $1 parameter, and return (echo) the result
leadindTextTrimmed=$($trimLeadingSpaces "$1")
textTrimmed=$($trimTrailingSpaces "$leadindTextTrimmed")
echo "$textTrimmed"
