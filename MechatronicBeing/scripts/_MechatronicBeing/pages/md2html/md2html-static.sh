#Create a static HTML files from MD 
#if pandoc is installed, use it to generate html

#keep the current script directory (= the information of $0 ONLY !!!)
currentScript="${0#./}"

#Get the parameter
fileToConvert="$1"

#Create the html files (name file or index.html -if renamed-)
fileNameWithoutExt="${fileToConvert%.*}"
htmlFileCreated="${fileNameWithoutExt}.html"

#test if pandoc is installed
if [ -x "$(command -v pandoc)" ]; then
  #Show the files generated !
  echo "((${currentScript##*/})) GENERATING STATIC '${htmlFileCreated}'"
  #Generate the html !
  pandoc -f gfm -t html -s "$fileToConvert" -o "$htmlFileCreated"
fi
