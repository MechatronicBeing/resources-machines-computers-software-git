#Create pages-files from a data-file (containing all information)

#the levels (relative path) to the MB root scripts
rootScriptsLevel="../"
#GlobalValues script
globalValuesScriptname="${rootScriptsLevel}getGlobalValues.sh"

#INIT VARIABLES WITH GLOBAL VALUES
#Get the ABSOLUTE currentScript : execute the GlobalValues script, with the 'getAbsolutePath' and $0 parameters
currentScript=$(${0%/*}/${globalValuesScriptname} "getAbsolutePath" "$0")
#Get the ScriptName and ScriptPath
currentScriptName="${currentScript##*/}"
currentScriptPath="${currentScript%/*}/"

#Get the IFS used 
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSused")

#Get the IMPORTANT PATHS/NAME values
read -r categoryPath categoryName rootPath <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "categoryPath" "categoryName" "rootPath")

#Get other values : data-files + target dir
read -r dataPath dataFilesRawfile dataMBFilesfile dataFilesRawFS dataFilesRawIdFS pagesFilesTargetDir pagesFilesMDFilename pagesFilesHTMLFilename  repositoryDirAdjust repositoryDirChange repositoryFileChange fileIconDir fileIconSizeDir htmlSpacer escapeSpacesInUrl spacerTimes spaceCharacter  <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "dataPath" "dataFilesRawfile" "dataMBFilesfile" "dataFilesRawFS" "dataFilesRawIdFS" "pagesFilesTargetDir" "pagesFilesMDFilename" "pagesFilesHTMLFilename" "repositoryDirAdjust" "repositoryDirChange" "repositoryFileChange" "fileIconDir" "fileIconSizeDir" "htmlSpacer" "escapeSpacesInUrl" "spacerTimes" "spaceCharacter" )

#Field Separator
read -r startMDtableRow fieldSeparatorMDtableRow endMDtableRow symbolMDtableHeaderSeparator minimalLengthMDtableHeaderSeparator htmlTableRowTag htmlTableCellTag htmlTableHeaderTag <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "startMDtableRow" "fieldSeparatorMDtableRow" "endMDtableRow" "symbolMDtableHeaderSeparator" "minimalLengthMDtableHeaderSeparator" "htmlTableRowTag" "htmlTableCellTag" "htmlTableHeaderTag")

#Get other values : relative path
#Note : showedRelativeFinalTarget for ROOT containing all categories : need ONE MORE FOLDER to reach target!!!
#Note2 : showedRelativeFinalTarget for category folder (used for icons inside the category)
read -r showedRelativeFinalTarget showedRelativeCategoryTarget <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "getRelativePath" "root/${pagesFilesTargetDir}" "getRelativePath" "$pagesFilesTargetDir")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")

#The list of header to use for all lines (header or lines)
#NOTE : SHOWED AS ORDERED....
#Header In MD files
headerToUseForMDfiles=()
headerToUseForMDfiles=("MD_NAME")
headerToUseForMDfiles+=("LAST_MODIFIED")
headerToUseForMDfiles+=("HR_SIZE")
headerToUseForMDfiles+=("SHOWED_PROPERTIES")

#Headers in HTML files
headerToUseForHTMLfiles=()
headerToUseForHTMLfiles=("HTML_NAME")
headerToUseForHTMLfiles+=("LAST_MODIFIED")
headerToUseForHTMLfiles+=("HR_SIZE")
headerToUseForHTMLfiles+=("SHOWED_PROPERTIES")

#Array with all item information
declare -A itemInformation

#Uppercase the 1st character and lowercase the rest
uppercaseThenLowercase() {
  #Get the First character in $1
  firstCharacter="${1:0:1}"
  #Get the rest of $1
  remnant="${1:1:$((${#1}-1))}"
  #Return the text with uppercase and lowercase
  echo "${firstCharacter^^}${remnant,,}"
}

#Write the values founded (CAN BE the header line OR a file/folder line) to the $1 file
writeMDInformationInfile() {
  #Get the file to write
  fileToWrite="$1"
  
  #Get the replace string
  addPrefix="$2"
  
  #Start the line
  lineToWrite="${startMDtableRow}"
  #Loop all fields
  for (( i=0; i<${#headerToUseForMDfiles[@]}; i++ )); do
    #Get the field name
    fieldName="${headerToUseForMDfiles[$i]}"
    #If a prefix is set, and the PREFIX+FIELDNAME key exist
    if [[ "$addPrefix" != "" && "${itemInformation[""${addPrefix}${fieldName}""]+isset}" ]]; then
      #Get the 'prefixed' value
      fieldValue="${itemInformation[""${addPrefix}${fieldName}""]}"
    else
      #Get the normal value
      fieldValue="${itemInformation[""${fieldName}""]}"
    fi
    
    #Add the value
    lineToWrite="${lineToWrite}${fieldValue}"   
    
    #IF it's not the last item, add the separator
    if (( i<${#headerToUseForMDfiles[@]}-1 )); then
      lineToWrite="${lineToWrite}${fieldSeparatorMDtableRow}"
    fi
  done 
  
  #End the line
  lineToWrite="${lineToWrite}${endMDtableRow}"
  #Print the line
  echo "${lineToWrite}" >> "$fileToWrite"
}

#Write the values founded (CAN BE the header line OR a file/folder line) to the $1 file
writeHTMLInformationInFile() {
  #Get the file to write
  fileToWrite="$1"

  #Get the replace string
  addPrefix="$2"

  #Change the tag used for the column, depending of the header information or not  
  if [[ "${itemInformation[""IS_HEADER""]}" != "" ]]; then
    colHTMLTag="${htmlTableHeaderTag}"
  else
    colHTMLTag="${htmlTableCellTag}"
  fi
  
  #Write the start of the line
  lineToWrite="<${htmlTableRowTag}>"
  #Loop all fields
  for (( i=0; i<${#headerToUseForHTMLfiles[@]}; i++ )); do
    #Get the field name
    fieldName="${headerToUseForHTMLfiles[$i]}"
    #If a prefix is set, and the PREFIX+FIELDNAME key exist
    if [[ "$addPrefix" != "" && "${itemInformation[""${addPrefix}${fieldName}""]+isset}" ]]; then
      #Get the 'prefixed' value
      fieldValue="${itemInformation[""${addPrefix}${fieldName}""]}"
    else
      #Get the normal value
      fieldValue="${itemInformation[""${fieldName}""]}"
    fi
    
    #Add the value
    lineToWrite="${lineToWrite}<${colHTMLTag}>${fieldValue}</${colHTMLTag}>"
  done 
  #End the line
  lineToWrite="${lineToWrite}</${htmlTableRowTag}>"
  
  #Print the line
  echo "${lineToWrite}" >> "$fileToWrite"
}

writeInformation(){
  #Write the information in the MD file(s)
  $(writeMDInformation)

  #Write the information in the HTML file(s)
  $(writeHTMLInformation)
}

writeMDInformation(){
  #Write the information in the main file
  $(writeMDInformationInfile "$categoryPath/$pagesFilesTargetDir/$pagesFilesMDFilename")
}

writeHTMLInformation(){
  #Write the information in the file
  $(writeHTMLInformationInFile "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}")
}

#Write the html head file
writeHTMLhead(){
  echo "<!DOCTYPE html>" > "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "<html xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"\" xml:lang=\"\">" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "  <head>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "    <meta charset=\"utf-8\" />" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, user-scalable=yes\" />" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "    <title>${categoryName}/files</title>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "  </head>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "  <body>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "    <table>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
}

#Write the html foot file
writeHTMLfoot(){
  echo "    </table>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "  </body>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
  echo "</html>" >> "$categoryPath/$pagesFilesTargetDir/${pagesFilesHTMLFilename}"
}

#Create spacer depending on the path (in $1) level
addSpacer()
{
  #Get fullPath
  fullPath="$1"
  
  #Get the last character in the 
  lastCharacter="${fullPath:$((${#fullPath}-1)):1}"
  
  #If the path end with /, remove it !!! used only for files !!
  if [[ "${lastCharacter}" == "/" ]]; then
    #remove '/'
    fullPath="${fullPath%/}"
  fi
  #Create a simplePath with '/' only (remove all other chars)
  simplePath="${fullPath//[^\/]/}"
  #Loop between levels
  for((i=0;i<${#simplePath};i++)); do 
    #add spacers
    for(( j=0; j<$spacerTimes; j++)); do
      dirSpacer="${dirSpacer}${htmlSpacer}"
    done
  done

  echo "$dirSpacer"
}

#Function  return a path to a icon according to file extension ($1)
getFileIcon() {
  #Get filename (uppercase)
  fileExtension="${1^^}"
  #Remove the '.' if present
  fileExtension="${fileExtension#.}"
  #result
  iconChoice=""

  #If the last character is "/", the "file" is a folder !
  if [[ "${fileExtension}" == "/" ]]; then
    iconChoice="places/folder.png"
  else
    #Depending of the file extension, found the icon.
    if [[ "${fileExtension}" == "MP3" ]]; then
      iconChoice="mimetypes/audio-x-generic.png"
    elif [[ "${fileExtension}" == "MP4" ]]; then
     iconChoice="mimetypes/video-x-generic.png"
    elif [[ "${fileExtension}" == "JPG" || "${fileExtension}" == "JPEG" || "${fileExtension}" == "PNG" ]]; then
      iconChoice="mimetypes/image-x-generic.png"
    elif [[ "${fileExtension}" == "ZIP" || "${fileExtension}" == "GZ" ]]; then
      iconChoice="mimetypes/package-x-generic.png"
    elif [[ "${fileExtension}" == "HTML" || "${fileExtension}" == "HTM" ]]; then
      iconChoice="categories/applications-internet.png"
    elif [[ "${fileExtension}" == "TXT" || "${fileExtension}" == "MD" ]]; then
      iconChoice="apps/accessories-text-editor.png"
    elif [[ "${fileExtension}" == "SH" ]]; then
      iconChoice="mimetypes/text-x-script.png"
    elif [[ "${fileExtension}" == "EXE" ]]; then
      iconChoice="mimetypes/application-x-executable.png"
    else
      iconChoice="mimetypes/text-x-generic-template.png"
    fi
  fi
    
  #Return the path to the icon
  echo "${fileIconDir}/${fileIconSizeDir}/${iconChoice}"
}

#change to category directory
cd "$rootPath"

#Create target directory (if not exist)
if [[ ! -d "$categoryPath/$pagesFilesTargetDir" ]]; then
  mkdir -p "$categoryPath/$pagesFilesTargetDir"
fi

#Show current directory
echo "((${currentScriptName})) CREATING PAGES-FILES FOR '$categoryName'"

#Empty the files
:> "$categoryPath/$pagesFilesTargetDir/$pagesFilesMDFilename"
:> "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"

#Create the header in the HTML page
$(writeHTMLhead)
    
#WARNING !! valid CSS-ID only use : [A-Za-z] + [0-9] + "-" and "_".
validPrefixID="${categoryName}"

filesToRead=("${categoryPath}/${dataFilesRawfile}" "${categoryPath}/${dataMBFilesfile}")

#Read all files
for (( fileIndex=0; fileIndex<${#filesToRead[@]}; fileIndex++ )); do
  fileToRead="${filesToRead[fileIndex]}"

  # If data file exist
  if [[ -f "${fileToRead}" ]]; then

    #Array of header in the file
    headerInFile=()

    #set the lineCounter
    lineCounter=0

    #Loop all lines in the data file
    while IFS= read -r line; do
      #remove the \r at the end (else, the line can be corrupted)
      line="${line%$'\r'}"
      
      #increment the line counter
      lineCounter=$(($lineCounter+1))
      
      #EMPTY ALL previous information
      for i in "${!itemInformation[@]}"; do
        itemInformation[$i]=""
      done
      
      #If it's the 1st line, extract the header
      if [[ "$lineCounter" -eq 1 ]]; then

        #EXTRACT THE HEADER
        lineExtracted="$line"
        #LOOP THE FIELDS (MINUS THE LAST)
        while [[ "$lineExtracted" != "${lineExtracted%%${dataFilesRawFS}*}" ]]; do 
          #Extract the current field name
          fieldName="${lineExtracted%%${dataFilesRawFS}*}"
          #Uppercase the fieldname
          fieldName="${fieldName^^}"
          #ADD IT TO THE HEADER ARRAY
          headerInFile+=("${fieldName}")
          
          #Add the value to the information array (for printing the header next)
          itemInformation[""${fieldName}""]="${fieldName}"
          
          #remove the column extracted
          lineExtracted="${lineExtracted#*${dataFilesRawFS}}"
        done
        #get the LAST current field name (not extracted)
        fieldName="${lineExtracted}"
        #Uppercase the fieldname
        fieldName="${fieldName^^}"
        #ADD IT TO THE HEADER ARRAY
        headerInFile+=("${fieldName}")
        #Add the last value to the information array (for printing the header next)
        itemInformation[""${fieldName}""]="${fieldName}"
        
        #If it's the 1st file to be read, print the header
        if [[ "$fileIndex" -eq 0 ]]; then
        
          #Add the information needed to create the final header
          itemInformation["IS_HEADER"]="YES"
          itemInformation["IS_IMPORTANT"]="YES"
          itemInformation["ID"]="trh_${validPrefixID}"
          itemInformation["MD_NAME"]=$(uppercaseThenLowercase "NAME")
          itemInformation["HTML_NAME"]=$(uppercaseThenLowercase "NAME")
          itemInformation["LAST_MODIFIED"]=$(uppercaseThenLowercase "LAST MODIFIED")
          itemInformation["TYPE+EXTENSION"]=$(uppercaseThenLowercase "TYPE")
          itemInformation["HR_SIZE"]=$(uppercaseThenLowercase "SIZE")
          itemInformation["SHOWED_PROPERTIES"]=$(uppercaseThenLowercase "PROPERTIES")
          itemInformation["HTML_ID"]="table-header"
          
          #WRITE THE INFORMATION (HEADER) IN THE FILES
          $(writeInformation)
          
          #FOR THE MD HEADER : REPLACE TEXT BY '-'
          for (( i=0; i<${#headerToUseForMDfiles[@]}; i++ )); do
            #Get the value
            headerValue="${itemInformation[""${headerToUseForMDfiles[$i]}""]}"
            #Replace all characters by '-'
            itemInformation["${headerToUseForMDfiles[$i]}"]="${headerValue//?/-}"
          done 
          
          #Write the additional line in the MD
          $(writeMDInformation)
        fi

      else
        #EXTRACT THE FOLDER/FILE INFORMATION
        #ALL values if main category
        
        lineExtracted="$line"
        #Extract all fields values
        for (( i=0; i<${#headerInFile[@]}; i++ )); do
          #if it's NOT the last index in the loop
          if (( $i < $((${#headerInFile[@]}-1)) )); then
            #Grab the information
            itemInformation["${headerInFile[i]}"]="${lineExtracted%%${dataFilesRawFS}*}"
            
            #remove the column extracted
            lineExtracted="${lineExtracted#*${dataFilesRawFS}}"
          else
            #Grab the LAST field name = the path
            itemInformation["${headerInFile[i]}"]="${lineExtracted}"
          fi
        done
        
        #Add the information, Empty=NO, updated later
        itemInformation["IS_HEADER"]="" 
        itemInformation["IS_FOLDER"]=""
        itemInformation["IS_IMPORTANT"]=""
        
        #ADD INFORMATION
        itemInformation["LAST_MODIFIED"]="${itemInformation[""LAST_MODIFIED_DATE""]} ${itemInformation[""LAST_MODIFIED_TIME""]}"
        itemInformation["HR_SIZE"]=$(numfmt --to=iec ${itemInformation[""SIZE""]})
        itemInformation["FULLNAME"]="${itemInformation[""PATH""]##*/}"
        itemInformation["LOCATION"]="${itemInformation[""PATH""]%/*}"
        if [[ "${itemInformation[""LOCATION""]}" == "${itemInformation[""PATH""]}" ]]; then
          itemInformation["LOCATION"]=""
        fi
        
        #Style the Type (1st letter uppercase, rest lowercase) 
        typeStyled=$(uppercaseThenLowercase "${itemInformation[""TYPE""]}")
        
        #GET NAME, EXTENSION, TYPE+FILE EXTENSION, PROPERTIES...
        if [[ "${itemInformation[""TYPE""]}" == "FOLDER" ]]; then
          itemInformation["IS_FOLDER"]="YES"
          itemInformation["PATH"]="${itemInformation[""PATH""]}/"
          itemInformation["NAME"]="${itemInformation[""FULLNAME""]}"
          itemInformation["EXTENSION"]="/"
          itemInformation["TYPE+EXTENSION"]="${typeStyled}"
          itemInformation["SHOWED_PROPERTIES"]="${itemInformation[""TOTAL_SUB-FILES""]} files,"
          itemInformation["SHOWED_PROPERTIES"]+=" ${itemInformation[""TOTAL_SUB-FOLDERS""]} folders"
          if [[ "${itemInformation[""LOCATION""]}" == "" ]]; then
            #A root folder
            itemInformation["REPOSITORY_PATH"]="${D}"
            itemInformation["IS_IMPORTANT"]="YES"
          else
            itemInformation["REPOSITORY_PATH"]="${D}/${repositoryDirChange}/${itemInformation[""PATH""]#*/}"
          fi
        else
          #Get the name (without extension)
          itemInformation["NAME"]="${itemInformation[""FULLNAME""]%.*}"
          fullname="${itemInformation[""FULLNAME""]}"
          #if the file had no prefix before extension (like '.extension')
          if [[ "${itemInformation[""NAME""]}" == "" ]]; then
            itemInformation["NAME"]="${itemInformation[""FULLNAME""]}"
            itemInformation["EXTENSION"]=""
            itemInformation["TYPE+EXTENSION"]="${typeStyled}:${fullname^^}"
          #If the file has NO extension (like 'file')
          elif [[ "${itemInformation[""NAME""]}" == "${itemInformation[""FULLNAME""]}" ]]; then
            itemInformation["EXTENSION"]=""
            itemInformation["TYPE+EXTENSION"]="${typeStyled}:${fullname^^}"
          else
            #Normal file 'name.extension'
            extension="${itemInformation[""FULLNAME""]##*.}"
            itemInformation["EXTENSION"]=".${extension}"
            itemInformation["TYPE+EXTENSION"]="${typeStyled}:${extension^^}"
          fi
          itemInformation["REPOSITORY_PATH"]="${D}/${repositoryFileChange}/${itemInformation[""PATH""]#*/}"
          itemInformation["REPOSITORY_PATH"]="${itemInformation[""REPOSITORY_PATH""]// /$escapeSpacesInUrl}"
          itemInformation["SHOWED_PROPERTIES"]="<details><summary>Checksum</summary><span>${itemInformation[""CHECKSUM""]}</span></details>"     
        fi

        #Escape spaces in URL
        itemInformation["REPOSITORY_PATH"]="${itemInformation[""REPOSITORY_PATH""]// /$escapeSpacesInUrl}"
        itemInformation["PATH"]="${itemInformation[""PATH""]// /$escapeSpacesInUrl}"
        
        #Get item icons and spacer
        fileIconPath=$(getFileIcon "${itemInformation[""EXTENSION""]}")
        itemInformation["FILE_ICON"]="<img class='file-icon' style='height: 22px;' src='${showedRelativeCategoryTarget}/${fileIconPath}'/>"
        #Create a spacer name 
        itemInformation["NAME_SPACER"]=$(addSpacer "${itemInformation[""PATH""]}")
        
        #MD NAME: Create the name-link style (spacer folder, file icon, anchor to the file)      
        itemInformation["MD_NAME"]="${itemInformation[""NAME_SPACER""]}<a href=\"${showedRelativeFinalTarget}/${repositoryDirAdjust}/${itemInformation[""REPOSITORY_PATH""]}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</a>"
        
        #HTML NAME
        itemInformation["HTML_NAME"]="${itemInformation[""NAME_SPACER""]}<a href=\"${showedRelativeFinalTarget}/${itemInformation[""PATH""]}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</a>"
        
        #WRITE THE INFORMATION (FOLDER or FILE) IN THE FILE(S)
        $(writeInformation)
      fi
      
      #If it's not the first file to be read AND the second line extracted, EXIT the loop
      if [[ "$fileIndex" -ne 0 && "$lineCounter" -eq 2 ]]; then
        break
      fi
    done < "${fileToRead}"
  fi
done

#Add the footer at the end of the HTML page
$(writeHTMLfoot)
