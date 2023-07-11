#Clear the git commit history -by creating a new branch- (also : commit ALL files)

#Get the parameter message
msgWithCommit="$1"

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

#verify the presence of a '.git' directory
if [ -d ".git" ]; then
  #Creating a new banch (without history)
  git checkout --orphan newBranch
  #Adding the files
  git add -A 
  #Committing changes
  git commit -am "Clear commit history $msgWithCommit"
  #Deleting the main branch
  git branch -D main
  #Renaming newBranch to main
  git branch -m main
  #Push all changes
  git push -f origin main
fi
