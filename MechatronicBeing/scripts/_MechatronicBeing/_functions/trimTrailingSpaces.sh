#Function : Trim all trailing spaces from $1 parameter

#Get the text
txt="$1"
#Loop until the last character is not a space OR the text is empty
while [[ "$txt" != "" && "${txt:$((${#txt}-1)):1}" == " " ]]; do 
  #Remove the last character (a space)
  txt="${txt:0:$((${#txt}-1))}"
done
#return the text
echo "$txt"
