#Create pages-files MD

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
read -r dataPath dataFilesRawfile dataFilesRawFS dataFilesRawIdFS pagesFilesTargetDir pagesFilesMDFilename pagesFilesHTMLFilename pagesFilesHTMLFilename1 pagesFilesHTMLFilename2 dataFilesLoaderDirname dataFilesLoaderMDfile dataFilesLoaderHTMLfile repositoryDirAdjust repositoryDirChange repositoryFileChange fileIconDir fileIconSizeDir htmlSpacer escapeSpacesInUrl spacerTimes spaceCharacter MBWebStylesDir filesWebStyleCheckedFilename filesWebStyleTargetedFilename <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "dataPath" "dataFilesRawfile" "dataFilesRawFS" "dataFilesRawIdFS" "pagesFilesTargetDir" "pagesFilesMDFilename" "pagesFilesHTMLFilename" "pagesFilesHTMLFilename1" "pagesFilesHTMLFilename2" "dataFilesLoaderDirname" "dataFilesLoaderMDfile" "dataFilesLoaderHTMLfile" "repositoryDirAdjust" "repositoryDirChange" "repositoryFileChange" "fileIconDir" "fileIconSizeDir" "htmlSpacer" "escapeSpacesInUrl" "spacerTimes" "spaceCharacter" "MBWebStylesDir" "filesWebStyleCheckedFilename" "filesWebStyleTargetedFilename")

#Field Separator
read -r startMDtableRow fieldSeparatorMDtableRow endMDtableRow symbolMDtableHeaderSeparator minimalLengthMDtableHeaderSeparator htmlTableRowTag htmlTableCellTag htmlTableHeaderTag <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "startMDtableRow" "fieldSeparatorMDtableRow" "endMDtableRow" "symbolMDtableHeaderSeparator" "minimalLengthMDtableHeaderSeparator" "htmlTableRowTag" "htmlTableCellTag" "htmlTableHeaderTag")

#Get other values : relative path
#Note : showedRelativeFinalTarget for ROOT containing all categories : need ONE MORE FOLDER to reach target!!!
#Note2 : showedRelativeFinalTarget for category folder (used for icons inside the category)
read -r showedRelativeFinalTarget showedRelativeCategoryTarget <<< $(${currentScriptPath}${globalValuesScriptname} "$currentScript" "getRelativePath" "root/${pagesFilesTargetDir}" "getRelativePath" "$pagesFilesTargetDir")

#Restore the IFS
IFS=$(${currentScriptPath}${globalValuesScriptname} "$currentScript" "IFSdefault")


#change to category directory
cd "$rootPath"

#Create target directory (if not exist)
if [[ ! -d "$categoryPath/$pagesFilesTargetDir" ]]; then
  mkdir -p "$categoryPath/$pagesFilesTargetDir"
fi

#Create the loader directory (if not exist)
if [[ ! -d "$categoryPath/$dataPath/${dataFilesLoaderDirname}" ]]; then
  mkdir -p "$categoryPath/$dataPath/${dataFilesLoaderDirname}"
fi

#Show current directory
echo "((${currentScriptName})) CREATING PAGES-FILES FOR '$categoryName'"

#Empty the MD file
:> "$categoryPath/$pagesFilesTargetDir/$pagesFilesMDFilename"
:> "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"
:> "$categoryPath/$pagesFilesTargetDir/1_${pagesFilesHTMLFilename}"
:> "$categoryPath/$pagesFilesTargetDir/2_${pagesFilesHTMLFilename}"
:> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
:> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
:> "$categoryPath/$dataPath/${dataFilesLoaderDirname}${dataFilesLoaderMDfile}"
:> "$categoryPath/$dataPath/${dataFilesLoaderDirname}${dataFilesLoaderHTMLfile}"


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
headerToUseForHTMLfiles+=("TYPE+EXTENSION")
headerToUseForHTMLfiles+=("HR_SIZE")
headerToUseForHTMLfiles+=("SHOWED_PROPERTIES")

#Array of header in the file
headerInFile=()

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

  classNames=""
  #Indicate if it's a folder or a file, for classname
  if [[ "${itemInformation[""IS_FOLDER""]}" != "" ]]; then
    classNames+="isAFolder"
  else
    classNames+="isAFile"
  fi
  
  if [[ "${itemInformation[""IS_IMPORTANT""]}" != "" ]]; then
    classNames+=" keepVisible"
  fi
  
  #Write the start of the line
  lineToWrite="<${htmlTableRowTag} id='tr_${itemInformation[""HTML_ID""]}' class='${classNames}' inFolder='${itemInformation[""HTML_INFOLDER""]}'>"
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
    lineToWrite="${lineToWrite}<${colHTMLTag} class='col${i}'>${fieldValue}</${colHTMLTag}>"
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
  
  #If the line is not a header
  if [[ "${itemInformation[""IS_HEADER""]}" == "" ]]; then
    #Write the css selectors in the file
    $(writeCSSSelectors)
  fi
}

writeMDInformation(){
  #Write the information in the main file
  $(writeMDInformationInfile "$categoryPath/$pagesFilesTargetDir/$pagesFilesMDFilename")
  
  #If it's the header
  if [[ "${itemInformation[""IS_HEADER""]}" != "" ]]; then
    #Write the separator header line in the main file (use the overwrite_value prefix)
    $(writeMDInformationInfile "$categoryPath/$pagesFilesTargetDir/$pagesFilesMDFilename" "${itemInformation[""OVERWRITE_PREFIX""]}")
    #Write the normal column in the loader file (the separator will be written after)
    $(writeMDInformationInfile "$categoryPath/$dataPath/${dataFilesLoaderDirname}${dataFilesLoaderMDfile}")
  fi
  
  #if "WRITE_IN_LOADER' is not empty, it's a header or the root folder,
  if [[ "${itemInformation[""WRITE_IN_LOADER""]}" != "" ]]; then
   #write-it in the LOADER, but use the 'overwrite' values
    $(writeMDInformationInfile "$categoryPath/$dataPath/${dataFilesLoaderDirname}${dataFilesLoaderMDfile}" "${itemInformation[""OVERWRITE_PREFIX""]}")
  fi
}

writeHTMLInformation(){
  #Write the checkbox
  echo "${itemInformation[""HTML_SELECT_ID""]}" >> "$categoryPath/$pagesFilesTargetDir/1_${pagesFilesHTMLFilename}"
  
  #Write the information in the file
  $(writeHTMLInformationInFile "$categoryPath/$pagesFilesTargetDir/2_${pagesFilesHTMLFilename}")
  
  #if "WRITE_IN_LOADER' is not empty, BUT is not the header, it's the root folder ! write to the loader
  if [[ "${itemInformation[""WRITE_IN_LOADER""]}" != "" && "${itemInformation[""IS_HEADER""]}" == "" ]]; then
    #write-it in the LOADER, but use the 'overwrite' values
    $(writeHTMLInformationInFile "$categoryPath/$dataPath/${dataFilesLoaderDirname}${dataFilesLoaderHTMLfile}" "${itemInformation[""OVERWRITE_PREFIX""]}")
  fi
}

#Write the css selectors
writeCSSSelectors() {
  
  arrayParents=(${itemInformation["HTML_ID"]//${dataFilesRawIdFS}/ })
  numbersParents=${#arrayParents[@]}
  
  parent=""
  for (( i=0; i<$numbersParents-1; i++)); do
    if [[ "$i" -eq 0 ]]; then
      #Get the first parent
      parent="${arrayParents[$i]}"
    else
      #Add the next parent
      parent="${parent}${dataFilesRawIdFS}${arrayParents[$i]}"
    fi
    
    if [[ $i -lt $(($numbersParents-2)) ]]; then
      #Show the parent row only if not targeted
      echo "#rd_ViewType_Single:checked ~ #${itemInformation[""HTML_ID""]}:checked ~ #filesList #tr_${parent}," >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
      echo "#${itemInformation[""HTML_ID""]}:target ~ #filesList #tr_${parent}," >> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
    else
      echo "#${itemInformation[""HTML_ID""]}:checked ~ #filesList #tr_${itemInformation[""HTML_ID""]}" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
      echo "#${itemInformation[""HTML_ID""]}:target ~ #filesList #tr_${parent}" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
    fi
  done
  
  if [[ $numbersParents -gt 1 ]]; then
    echo "{ display: table-row; } " >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
    echo "{ display: none !important; } " >> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
  fi
  
  #useless : if checked : was visible before !
  # echo "#${itemInformation[""HTML_ID""]}:checked ~ #filesList #tr_${itemInformation[""HTML_ID""]} { display: table-row !important; }" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  
  echo "#rd_ViewType_Single:checked ~ #${itemInformation[""HTML_INFOLDER""]}:checked ~ #${itemInformation[""HTML_ID""]}:not(:target) ~ #filesList #tr_${itemInformation[""HTML_ID""]} { display: table-row !important; }" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  
  
  echo "#${itemInformation[""HTML_ID""]}:target ~ #filesList #tr_${itemInformation[""HTML_ID""]} {display: table-row !important;}" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
  
  # IF TARGETS
  # echo "#rd_ViewType_Single:checked ~ #${itemInformation[""HTML_INFOLDER""]}:target ~ #filesList #tr_${itemInformation[""HTML_ID""]}," >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  # echo "#${itemInformation[""HTML_ID""]}:target ~ #filesList #tr_${itemInformation[""HTML_ID""]}" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  # echo "{ display: table-row !important; }" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  
  
  #Item selected : show information
  # echo "#rd_ViewType_Single:checked ~ ${itemActivation} ~ #filesList #${itemInformation[""HTML_ID""]} { display: table-row; }" >> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  

  #Add a line for the next element
  echo "">> "$categoryPath/$MBWebStylesDir/$filesWebStyleCheckedFilename"
  echo "">> "$categoryPath/$MBWebStylesDir/$filesWebStyleTargetedFilename"
}

#Finish the HTML writing : regroup the files into one
finishHTMLwriting() {
  cat "$categoryPath/$pagesFilesTargetDir/0+_${pagesFilesHTMLFilename}" > "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"
  cat "$categoryPath/$pagesFilesTargetDir/1_${pagesFilesHTMLFilename}" >> "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"
  cat "$categoryPath/$pagesFilesTargetDir/2_${pagesFilesHTMLFilename}" >> "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"
  cat "$categoryPath/$pagesFilesTargetDir/9+_${pagesFilesHTMLFilename}" >> "$categoryPath/$pagesFilesTargetDir/$pagesFilesHTMLFilename"
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


#Write the TABLE TAG
echo "<table id='filesList'>" >> "$categoryPath/$pagesFilesTargetDir/2_${pagesFilesHTMLFilename}"


#For each directory, starting with the same name
for D in $categoryName; do

  #If D is a directory
  if [[ -d "$D" ]]; then
    
    #WARNING !! valid ID in CSS use : [A-Za-z] + [0-9] + "-" and "_".
    validPrefixID="${D}"
    
    #If the data file exist
    if [[ -f "$D/${dataPath}/${dataFilesRawfile}" ]]; then
    
      #set the lineCounter
      lineCounter=0
    
      #Loop all lines in the data file
      while IFS= read -r line; do
        #remove the \r at the end (else, the line can be corrupted)
        line="${line%$'\r'}"
        
        #increment the line counter
        lineCounter=$(($lineCounter+1))
        
        #EMPTY ALL values from the last information
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
          #Extract the LAST current field name (not extracted)
          fieldName="${lineExtracted%%${dataFilesRawFS}*}"
          #Uppercase the fieldname
          fieldName="${fieldName^^}"
          #ADD IT TO THE HEADER ARRAY
          headerInFile+=("${fieldName}")
          #Add the last value to the information array (for printing the header next)
          itemInformation[""${fieldName}""]="${fieldName}"
          
          #Add the information needed to create the final header
          itemInformation["IS_HEADER"]="YES"
          itemInformation["WRITE_IN_LOADER"]="YES"
          itemInformation["IS_IMPORTANT"]="YES"
          itemInformation["ID"]="trh_${validPrefixID}"
          itemInformation["MD_NAME"]=$(uppercaseThenLowercase "NAME")
          itemInformation["HTML_NAME"]=$(uppercaseThenLowercase "NAME")
          itemInformation["LAST_MODIFIED"]=$(uppercaseThenLowercase "LAST MODIFIED")
          itemInformation["TYPE+EXTENSION"]=$(uppercaseThenLowercase "TYPE")
          itemInformation["HR_SIZE"]=$(uppercaseThenLowercase "SIZE")
          itemInformation["SHOWED_PROPERTIES"]=$(uppercaseThenLowercase "PROPERTIES")
          itemInformation["HTML_ID"]="table-header"

        else
          #EXTRACT THE VALUES
          
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
          
          #Add the information no header
          itemInformation["IS_HEADER"]="" #Empty=no
          
          #ADD information, EMPTY='NO', updated later
          itemInformation["WRITE_IN_LOADER"]=""
          itemInformation["OVERWRITE_PREFIX"]="" 
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
              itemInformation["REPOSITORY_PATH"]="${D}"
              itemInformation["WRITE_IN_LOADER"]="YES"
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

          itemInformation["REPOSITORY_PATH"]="${itemInformation[""REPOSITORY_PATH""]// /$escapeSpacesInUrl}"
          fileIconPath=$(getFileIcon "${itemInformation[""EXTENSION""]}")
          itemInformation["FILE_ICON"]="<img class='file-icon' style='height: 22px;' src='${showedRelativeCategoryTarget}/${fileIconPath}'/>"
          itemInformation["NAME_SPACER"]=$(addSpacer "${itemInformation[""PATH""]}")
          
          
          #MD: Create the name-link style (spacer folder, file icon, anchor to the file)      
          itemInformation["MD_NAME"]="<a href=\"${showedRelativeFinalTarget}/${repositoryDirAdjust}/${itemInformation[""REPOSITORY_PATH""]}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${itemInformation[""NAME_SPACER""]}${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</a>"
          
          #HTML
          #Replace the 1st part of the id ('1' : the root folder, '1') with the new validPrefixID (categoryname)
          if [[ "${itemInformation[""LOCATION""]}" == "" ]]; then
            itemInformation["HTML_ID"]="${validPrefixID}"
          else
            itemInformation["HTML_ID"]="${validPrefixID}${dataFilesRawIdFS}${itemInformation[""ID""]#*${dataFilesRawIdFS}}"
          fi
          itemInformation["HTML_NAME"]="${itemInformation[""NAME_SPACER""]}<label for='${itemInformation[""HTML_ID""]}' id='lbl_${itemInformation[""HTML_ID""]}'>${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</label>"
          itemInformation["HTML_INFOLDER"]="${itemInformation[""HTML_ID""]%${dataFilesRawIdFS}*}"
          itemInformation["HTML_SELECT_ID"]="<input type='radio' id='${itemInformation[""HTML_ID""]}' name='select_item' class='rd_itemSelect' inFolder='${itemInformation[""HTML_INFOLDER""]}' style='display: none' />"
        fi
        
        ####################### FOR LOADER : ADD OVERWRITE VALUES
        if [[ "${itemInformation[""WRITE_IN_LOADER""]}" != "" ]]; then
          #Use the OVERWRITE_PREFIX name (a prefix)
          itemInformation["OVERWRITE_PREFIX"]="OVERWRITE_"
          
          #If it's the header : add an additional value with '---' separator, for all column
          #ONLY USED FOR WRITE IN MD
          if [[ "${itemInformation[""IS_HEADER""]}" != "" ]]; then
          
            for (( i=0; i<${#headerToUseForMDfiles[@]}; i++ )); do
              #Get the value
              headerValue="${itemInformation[""${headerToUseForMDfiles[$i]}""]}"
              headerValueReplaced=""
              
              #Set the length
              endLength=${#headerValue}
               
              #If the value is less than the minimal length required to validate the table
              if [[ ${#headerValue} -lt ${minimalLengthMDtableHeaderSeparator} ]]; then
                #Force the minimal length required
                endLength=${minimalLengthMDtableHeaderSeparator}
              fi
              
              #loop all character and replace the header symbol separator
              for (( j=0; j<${endLength}; j++ )); do
                headerValueReplaced="${headerValueReplaced}${symbolMDtableHeaderSeparator}"
              done
              
              # Replace the OVERWRITED value with '-'
              itemInformation["${itemInformation[""OVERWRITE_PREFIX""]}${headerToUseForMDfiles[$i]}"]="$headerValueReplaced"
            done 
          
          else 
          
            #it's the root folder
            #MD : Change the link to redirect to pages/files target
          
            #Add the repository Dir change ('tree/main') + path to pages-files
            itemInformation["${itemInformation[""OVERWRITE_PREFIX""]}REPOSITORY_PATH"]="${categoryName}/${repositoryDirChange}/$pagesFilesTargetDir/"
            #Espace the spaces in url
            itemInformation["${itemInformation[""OVERWRITE_PREFIX""]}REPOSITORY_PATH"]="${itemInformation[""${itemInformation[""OVERWRITE_PREFIX""]}REPOSITORY_PATH""]// /$escapeSpacesInUrl}"
            #'OVERWRITE' the name field used (using the new LOADER_REPOSITORY_PATH)
            itemInformation["${itemInformation[""OVERWRITE_PREFIX""]}MD_NAME"]="<a href=\"${showedRelativeFinalTarget}/${repositoryDirAdjust}/${itemInformation[""${itemInformation[""OVERWRITE_PREFIX""]}REPOSITORY_PATH""]}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${itemInformation[""NAME_SPACER""]}${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</a>"
            
            
            #HTML :
            itemInformation["${itemInformation[""OVERWRITE_PREFIX""]}HTML_NAME"]="${itemInformation[""NAME_SPACER""]}<label for='${itemInformation[""HTML_ID""]}' id='lbl_${itemInformation[""HTML_ID""]}'>${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</label>"
          fi
        fi
        
        #WRITE THE INFORMATION (HEADER OR OTHER) IN THE FILE(S)
        $(writeInformation)
        
      done < "$D/${dataPath}/${dataFilesRawfile}"
      
    else
      #NO DATA-FILES !!!!
      #CREATE A LIMITED LINE WITH REDIRECT TO PAGES/FILES
    
      #EMPTY ALL values from the last information
      for i in "${!itemInformation[@]}"; do
        itemInformation[$i]=""
      done
      
      #MINIMAL VALUES
      itemInformation["ID"]="trh_${validPrefixID}"
      itemInformation["MD_NAME"]="$D"
      itemInformation["LAST_MODIFIED"]=""
      itemInformation["PATH"]="$D"
      itemInformation["EXTENSION"]="/"
      itemInformation["TYPE"]="FOLDER"
      typeStyled=$(uppercaseThenLowercase "${itemInformation[""TYPE""]}")
      itemInformation["TYPE+EXTENSION"]="${typeStyled}"
      itemInformation["HR_SIZE"]=""
      itemInformation["SHOWED_PROPERTIES"]=""

      fileIconPath=$(getFileIcon "${itemInformation[""EXTENSION""]}")
      itemInformation["FILE_ICON"]="<img class='file-icon' style='height: 22px;' src='${showedRelativeCategoryTarget}/${fileIconPath}'/>"
      itemInformation["NAME_SPACER"]=$(addSpacer "${itemInformation[""PATH""]}")
  
      #Add the repository Dir change ('tree/main') + path to pages-files
      itemInformation["REPOSITORY_PATH"]="${D}/${repositoryDirChange}/$pagesFilesTargetDir/"
      #Espace the spaces in url
      itemInformation["REPOSITORY_PATH"]="${itemInformation[""REPOSITORY_PATH""]// /$escapeSpacesInUrl}"
      #Change name
      itemInformation["MD_NAME"]="<a href=\"${showedRelativeFinalTarget}/${repositoryDirAdjust}/${itemInformation[""REPOSITORY_PATH""]}\" style='text-decoration: none; border-spacing: 0; border-width: 0;'>${itemInformation[""NAME_SPACER""]}${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</a>"
      
      #Change HTML name
      itemInformation["HTML_NAME"]="${itemInformation[""NAME_SPACER""]}<label for='${itemInformation[""HTML_ID""]}' id='lbl_${itemInformation[""HTML_ID""]}'>${itemInformation[""FILE_ICON""]}${htmlSpacer}${itemInformation[""NAME""]}${itemInformation[""EXTENSION""]}</label>"
      itemInformation["HTML_SELECT_ID"]="<input type='radio' id='${itemInformation[""HTML_ID""]}' name='select_item' class='rd_itemSelect' style='display: none' />"
    fi
  fi
done

#Write the Close TABLE TAG
echo "</table>" >> "$categoryPath/$pagesFilesTargetDir/2_${pagesFilesHTMLFilename}"

#For the HTML : finish the operation (concat all files)
$(finishHTMLwriting)
