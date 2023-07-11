#Function : Trim all leading spaces from $1 parameter

#Get the text
txt="$1"
#Loop until the first character is not a space OR the text is empty
while [[ "$txt" != "" && "${txt:0:1}" == " " ]]; do 
  #Remove the first character (a space)
  txt="${txt:1:$((${#txt}-1))}"
done
#return the text
echo "$txt"