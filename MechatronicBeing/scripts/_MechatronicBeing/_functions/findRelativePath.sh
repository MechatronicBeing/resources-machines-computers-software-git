#get the relative path from a path ($1)
#exemple : a/b/c       = ../../.. 
#exemple : a/./b/./c   = ../../..
#exemple : a/b/../c    = ../..
#exemple : a/b/../c/.. = ..
#The relative path can be ajusted (+ or - folders) with the $2

#Get the parameter
path="$1"
adjustRelativePath=$(("$2"))

#init the relative path
relativePath=""

#Get the First, Second, BeforeLast, Last characters (for testing and final result)
firstCharacter="${path:0:1}"
secondCharacter="${path:1:1}"
beforeLastCharacter="${path:$((${#path}-2)):1}"
lastCharacter="${path:$((${#path}-1)):1}"

#Replace '//' by '/'
path="${path//\/\//\/}"

#Remove the './' OR  '/' at first ('/' will be re-added at the end)
if [[ "${firstCharacter}${secondCharacter}" == "./" ||  "$firstCharacter" == "/" ]]; then
  path="${path#*/}"
fi

#Remove '/./' in the middle
path="${path//\/\.\//\/}"

#Remove '/' OR '/.' at the end ('/' will be re-added at the end)
if [[ "$lastCharacter" == "/" || "${beforeLastCharacter}${lastCharacter}" == "/." ]]; then
  path="${path%/*}"
fi

#remove all character except / (=a simple relative path with '/' only)
simplePath="${path//[^\/]/}"
#get the length of the simple path
lenSimplePath=$((${#simplePath}))

#For each '/' in the simplePath (+ or - with the adjustRelativePath parameter)
#Always add +1 (because : there are left and right items for 1 '/') !!
for (( i=0 ; i<(lenSimplePath+1+adjustRelativePath); i++)); do
  #add the '..' in the relativePath
  if [[ "$relativePath" == "" ]]; then
    relativePath=".."
  else
    relativePath="${relativePath}/.."
  fi
done

#If the relativePath is empty, use the '.'
if [[ "$relativePath" == "" ]]; then
  relativePath="."
fi

#If the path begin with /, add '/' to the relative path
if [[ "$firstCharacter" = "/" ]]; then
  relativePath="/${relativePath}"
fi

#If the path end with /, add '/' at the end of the relative path
if [[ "$lastCharacter" = "/" ]]; then
  relativePath="${relativePath}/"
fi

#Return the result
echo "$relativePath"
