#Find the parent directory, from a path (in $1 parameter) and a relative "back-path" (in $2, ex:'../../..').
#A stopBefore value ($3) can be used to stop before the XX directory

#get parameters
path="$1" 
downPath="$2"
stopBefore=$(("$3"))

#Get the First, Second, Last characters (for testing and final result)
firstCharacter="${path:0:1}"
secondCharacter="${path:1:1}"
lastCharacter="${path:$((${#path}-1)):1}"

#Remove the './' 
if [[ "${firstCharacter}${secondCharacter}" == "./"  ]]; then
  path="${path#*/}"
fi

#If the path end with '/', remove it -unwanted- !
if [[ "$lastCharacter" = "/" ]]; then
  path="${path%/*}"
fi


#Get the levels of the back-folders
#Simplify the path : from ".." to "."
#change all '..' to '+' char
step1="${downPath//../+}"
#Remove all characters '.' single and / (not wanted)
step2="${step1//[^\+]/}"
#count the level (=numbers of . character)
levels=$((${#step2}))

#For each levels (minus the $3 parameter)
for (( i=0 ; i<(levels-stopBefore); i++)); do
  path="${path%/*}"
done

#If the path ended with /, add '/' at the end
if [[ "$lastCharacter" = "/" ]]; then
  relativePath="${relativePath}/"
fi

#Return the path
echo "$path"