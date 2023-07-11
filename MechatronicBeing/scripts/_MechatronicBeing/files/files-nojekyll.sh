#Add a ".nojekyll" file at the root

#keep the current script directory (= the information of $0 AND PWD !!!)
currentScript="$PWD/${0#./}"
currentScriptDir="${currentScript%/*}"

#the (root) category -RELATIVE- directory (containing the FILES) used for search
#Read the information in the global file
categoryDir=$(cat "$currentScriptDir/../_variables/categoryPath.txt")

#trace back previous folder to found the last directory, BEFORE the rootDir (=the last ..)
path="$currentScriptDir" 
down="$categoryDir/.."
while :; do
  test "$down" = '..' && break
  path="${path%/*}"
  down="${down%/*}"
done
#Take only the final folder
categoryName="${path##*/}"
#Remove the last ".." and save the path (category root) for later !!!
categoryPath="${path%/*}"

#change to root CATEGORY directory
cd "$categoryPath"

#verify the presence of the ".nojekyll" file at the root
if ! [ -f ".nojekyll" ]; then
  #add a ".nojekyll" file
  touch ".nojekyll"
fi
