#Return an ABSOLUTE path (without any '.' or '..')

#get path in $1
path="$1"

#get the path
if [[ "${path:0:1}" == "/" ]]; then
  #if the path start with '/' it's already absolute
  fullPath="${path}"
else
  #else, add the $PWD (absolute) to the path, to form an absolute path, but not perfect
  fullPath="${PWD}/${path#./}"
fi

#Get the Last character
lastCharacter="${fullPath:$((${#fullPath}-1)):1}"

#Simplify the path (avoid . and ..)
simplifyPath=""

#Loop from start to end folders in the path
while [[ "$fullPath" != "${fullPath%%/*}" ]]; do

  #Get the 1st folder
  getFolder="${fullPath%%/*}"
  
  #If '..', Remove the last folder (fallback)
  if [[ "$getFolder" == ".." ]]; then
    simplifyPath="${simplifyPath%/*}"
    
  #If the folder is not empty or '.', add the folder
  elif [[ "$getFolder" != "" && "$getFolder" != "." ]]; then
    #Note : it will add the '/' root folder too !
    simplifyPath="${simplifyPath}/${getFolder}"
  fi
  
  #Remove the 1st folder done
  fullPath="${fullPath#*/}"
done

#use the path simplified and append the last string in fullpath
pathSimplified="${simplifyPath}/${fullPath}"

#If the path ended with /, add '/' at the end
if [[ "$lastCharacter" = "/" ]]; then
  pathSimplified="${pathSimplified}/"
fi

#Return the path simplified
echo "$pathSimplified"