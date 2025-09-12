#!/bin/bash
# This script recursively loops over all files found at the given path.

# This is the shebang telling the system to run this script in a bash shell environment

# Base mount path
BASE_PATH="/run/media/sumodk"
# BASE_PATH is a variable storing the string given

# Check if a USB name was provided
if [[ -z "$1" ]]; then
  echo "Usage: $0 USB_NAME"
  exit 1
fi
 # if [condition is true] then [what to do] fi
 # this is the syntax for the IF conditional statement
 #  [[.....]] is used to enclose the conditional expression safely, ensures that no ...
 #  ... unexpected error occurs
 #  -z (length is 0), $1 (the first argument provided)
 #  So the condition looked for is "if the number of characters in the first argument ($1) ...
 #  ... provided is 0 (-z) then proceed to the code inside"
 #  echo - print the following
 #  $0 expands to the command/file name use to trigger the script, so here it expands to ...
 #  ... "Usage: checkHealth USB_NAME"
 # exit 1 - exits the scripts using error status 1 
 # In laymans terms : if the name of the USB is not given then tell the user that the syntax ...
 # ... required is the script name + usb name and stop the script.
 # if the usb name is provided then the [[ -z "$1" ]] will evaluate to false and the code ...
 # ... block is skipped over.

# Path to USB
USB_PATH="${BASE_PATH}/$1"
# USB_PATH is the variable that will hold the complete path to the USB. This is concatenation of ...
# ... BASE_PATH which is "run/media/sumodk" and $1 (first argument) which is the usb name, so the ...
# ... output is "run/media/sumodk/usbname"

# Check if the path to the USB exists
if [[ ! -d "${USB_PATH}" ]]; then
  echo "Error: $USB_PATH does not exist."
  exit 1
fi
# This is a validation to verify that the path provided infact points to a directory.
# ! - this is the 'not' operator
# -d - this means "is directory". This -d is part of the Bash [[.....]] conditional expression syntax
# "${USB_PATH}" - this is variable expansion syntax ...
#   $ - tells the shell to expand the variable
#   {} - is used to clearly delineate the contents in the variable from the surrounding text ...
#   ... this is required in cases where the variable is concatenated with other strings or ...
#   ... if extra functions are performed on the variable like sub-string extraction or case conversion.
#   "" - this preserves the result of the expansion as is, with spaces if any.
 # So in layman's terms it says if the path does not point to a directory then print the message ...
 # ... and exit the script with error code 1
  
# Required commands for health checks
DEPENDENCIES=(pdfinfo unzip identify unrar 7z)
# DEPENDENCIES is the variable that hold the array that is assigned to it.
# () - this is the array format
# what we have inside the () are commands that are needed to execute verification

# Check if dependencies are available
for cmd in "${DEPENDENCIES[@]}"; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Error: Required command '$cmd' not found. Please install it."
    exit 1
  fi
done
# Here we have nested functions, an IF conditional inside a FOR loop
# [for] ( counter/variable ) [in] ( list/array/etc ); [do] { code to be executed } [done]
# this is the for-loop syntax
# cmd - this is a place holder or varibale like name that holds the item that is being looped over
# "${DEPENDENCIES[@]}" - this is variable expansion as explained above, but here the variable is an array so ...
#     [@] - this outputs all the individual unique elements in the array as a list of unique elements
#     [*] - this is another operator that outputs all elements in an array, however it outputs the data in ...
#     ... the array as a single string so [@] is the safer option however if the array contained an element ...
#     ... of multiple words like unzip all it needs to be wrapped in "" like "unzip all" at assignment time ...
#     ... to be considered as a single element when using [@].
#     the for loop iterates over each item in the list output by [@] using "cmd" as the place holder for each ...
#     ... unique item during each iteration.
#     In the IF conditional, the variable "cmd" is expanded and validated 
#     ! (not operator), 
#     command -v  - checks if the given string is a system command and outputs the path if it exists.
#         command - shell command to check if the given command is available in the system and has a path.
#         -v (verbose) - prints the output of "command" to the terminal
#     >/dev/null - redirects (>) all stdout to /dev/null, a linux black hole
#     2>&1 - all stderr is redirected to stdout which is already being pushed into a black hole
#     so effectively no output is seen on the terminal.
# So in layman's terms what the IF condition is stating is if the exit code of the operation is not 0 ...
# ... (the operation here is run 'command -v [element in array]') then print the given message and ...
# ... exit with error code 1.

echo "Scanning all files in $USB_PATH recursively ..."
# Print the string to terminal

# Counters for summary
total_files=0
corrupt_files=0
skipped_files=0
# creating counter variables and assigning 0 as starting value.

while IFS= read -r -d '' file; do
  ((total_files++))

  # Strip path and get just the base file name
  base=${file##*/}
# 'base' is the variable that will store the result of what happens after the '='
# '${....}' is the varibale expansion syntax in bash script
# 'file' is the shell variable what holds the name/string that the WHILE loop is looking at ...
# ... in this iteration.
# '##' this is a removal operator. It says 'remove from the beginning to the last possible ...
# ... position' of the given pattern
# '*' any and all characters (a glob pattern)
# '/' the literal '/' character
# So in layman's terms it says 'strip whatever is stored in the shell variable 'file' ...
# ... till the last '/' character including the '/' and store what is left after the '/' in 'base'

  if [ ! -r "$file" ]; then
    echo " NO READ PERMISSION : $file"
    ((skipped_files++))
  else
#  [ ! -r "$file" ] This IF condition states if the files being looked at in this iteration of the WHILE loop ...
#  ... is not (denoted by '!') readable (denoted by '-r'), meaning if we do not have access to read the file ...
#  ... then execute what follows ...
#  ... this is a IF statement that has 2 (only 2) conditions so ....
# [else] this is part of the IF statement meaning if [ ! -r "$file" ] evaluates to false, meaning, ...
# ... if the file targeted is readable, then execute what follows.

    # Extract the file extension safely
    if [[ "$base" == *.* && "$base" != .* ]]; then
  # [[...]] since comparison is done ensures safe execution
  # the first part says if what is stored in the 'base' variable has the pattern 'something.something'
  # the && ensures that what follows is executed only if what is on the left of && executes successfully.
  # it looks at the exit code of the previous command and if it is 0 then run the next command
  # the next command says if what is stored in 'base' is not equal (denoted by '!=') to ...
  # ... the first character is a '.' followed by something.
  # In layman's terms it says if what is stored in 'base' has a pattern ...
  # ... with a sequence of characters followed by a '.' followed by another sequence of ...
  # ... characters and does not start with a dot then execute what follows

      ext=${base##*.}
    # 'ext' is the variable that will hold the output of what comes after the '='
    # '${}' is the variable expansion syntax
    # base is the variable that contains the stripped file name from $file
    # '##' longest comparison from the left, effectively targeting the last match of the pattern provided
    # '*.' all characters till '.' including the '.'
    # In layman's terms strip what is in 'base' starting from the left to the very last '.' including ...
    # ... the '.' and store what remains in the variable 'ext'

    else # What follows runs if the condition/s above evaluates to false
      echo "Skipping file with no extension: $file"
      ((skipped_files++))
      continue
      # This is a bash command telling bash to abort the current iteration ...
      # ... and go to the next
    fi
# [if] (condition is true); [then] { code to execute } [else] { code to execute } [fi]
# this is the IF statement sytanx where the evaluation of the condition can determine ...
# ... which of two code blocks are executed
# One condition, two codes

    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
# 'ext_lower' is the variable that will hold the output of what comes after the '='
# '$()' (command substitution) run everything inside '$()' and after execution replace ...
# everything in '$()' including the '$()' with the output of the commands run
# Why? because since we are executing bash functions the output would normally be printed ..
# ... to the terminal and then lost. '$()' ensures that the output is stored in the variable ...
# After the commands inside '$()' are run, bash will see this line as ...
# ... 'ext_lower="result from commands run'
# echo "$ext" prints the data stored in the 'ext' variable and pushes it into ...
# tr (translate) commnad which converts all uppercase characters to lowercase
# so if what was in "$ext" was JPEG after execution the line will look like ...
# ... 'ext_lower="jpeg"'

    case "$ext_lower" in
      pdf)
        echo "Checking PDF: $file"
        # prints the name of the file being checked
        pdfinfo "$file" >/dev/null 2>&1 && echo " OK" || { echo " CORRUPT"; ((corrupt_files++)) }
        # run the command on the 'file' -> send all stderr to stdout (2>&1) ...
        # ... send all stdout to linux blackhole (>/dev/null) ...
        # '&&' - if the exit code of the command to the left is 0 then run this
        # this is a 2 command line, the first is 'pdfinfo ...... 2>&1 && echo " OK"' ...
        # the second is after the '||'
        # '||' - or run this 
        # In layman's terms, run the command 'pdfinfo' on the file targeted and if ...
        # ... the exit code for this is 0, then run 'echo "OK"'
        # else run the corrupt part.
      ;;
      docx|doc|xlsx|xls|xlsm|pptx|ppt)
        echo "Checking Office file: $file"
        unzip -t "$file" >/dev/null 2>&1 && echo " OK" || { echo " CORRUPT"; ((corrupt_files++)) }
      ;;
      txt)
        echo "Checking Office file: $file"
        if file "$file" | grep -qE 'ASCII text|UTF-8 text|Unicode text'; then
          echo " OK"
        else
          echo " CORRUPT"
          ((corrupt_files++))
        fi
      ;;
      jpg|jpeg|png|gif|bmp|tiff)
        echo "Checking Image: $file"
        identify "$file" >/dev/null 2>&1 && echo " OK" || { echo " CORRUPT"; ((corrupt_files++)) }
      ;;
      dwg)
        echo "Checking DWG: $file"
        header=$(head -c 8 "$file" 2>/dev/null)
        # 'header' is the variable that will hold the output of command execution in '$(....)'
        # 'head' is a linux builtin command that prints out the first 10 lines (10 is the default) ...
        # ... of files it is pointed to.
        # It can be made to read, bytes using the '-c' flag.
        # Here it is showing the first 8 bytes of the .dwg files.
        if [[ "$header" =~ ^AC[0-9]{4}$ ]]; then
          # '=~' : this is the comparison operator for regex.
          # '^AC[0-9]{4}$' : This is regex (Regular Expression)
          #   ^ : the start of the line
          #   AC : the literal characters, uppercase A and C
          #   [0-9] : is number
          #   {4} : count of 4
          #   $ : end of the line
          # In layman's terms, if what is stored in $header is :
          # starts with the characters 'AC', then has 4 digits and that is all there is (denoted by $)...
          #   ... meaning a total of 6 characters then execute the code
          echo " OK"
        else
          echo " CORRUPT or unsupported DWG"
          ((corrupt_files++))
        fi
      ;;
      zip)
        echo "Checking ZIP archive: $file"
        unzip -t "$file" >/dev/null 2>&1 && echo " OK" || { echo " CORRUPT"; ((corrupt_files++)) }
      ;;
      rar)
        echo "Checking RAR archive: $file"
        unrar t -inul "$file" >/dev/null 2>&1 && echo " OK" || { echo " CORRUPT"; ((corrupt_files++)) }
      ;;
      *)
        # Skip unhandled extension
        echo "Skipping .$ext_lower file: $file"
        ((skipped_files++))
        continue
      ;;
    esac
    # [case] ( condition/object ) [in] [target)] { code to execute } [;;] [target)] { code to execute } [;;] [*)] { code to execute } [;;] [esac]
    # This is the syntax for the case statement
    # The block is enclosed in case .... esac 
    # 'ext_lower' is what all the targets will be compared to 
    # ';;' denotes the end of the each target block
    # '*)' targets all conditions/objects not handeled by the target blocks
    # Only that target block whose target meets the object/conditions is triggered and the resulting code is executed
    # All other are passed into the '*)' target block
  fi

done < <(find "$USB_PATH" -type f -print0)

# Here we have a three level nesting of functions
# An IF conditional and CASE function nested in an IF-ELSE conditional nested in a WHILE loop
# [while] ( condition is true ); [do] { function to be executed } [done] < <(find .......)
# This is the syntax for the WHILE loop, the normal syntax, with one exception ...
# ... the input for the WHILE loop is positioned at the end of the WHILE syntax ...
# This is because the counter variables need to be placed inside the WHILE loop and if the ...
# ... input to the WHILE loop is piped into the WHILE loop using | like ...
# ... find ....... | [while] ( condition is true ); [do] { function to be executed } [done] ...
# then the WHILE loop is running in a subshell and the counter variables go out of scope when ...
# the WHILE loop completes.
# The input for the WHILE loop : < <(find "$USB_PATH" -type f -print0)
#   the first < is directing the output of the remaining command into the WHILE loop.
#   the following <(.......) - this is called 'process substitution'. It runs the command inside ...
#   ... the () and treats the output like a file which is then redirected into the WHILE loop (the first '<')
#   the 'find' command looks through all the files in the given location and retrieves the names of the files ...
#   along with the respective paths 
#   "$USB_PATH" is variable expansion which results in the path that the find command is directed to look at....
#   ... here {} is not required as there is nothing touching the variable. It expands to : ...
#   ... '/run/media/sumodk/usbname'
#     -type tells the find command what kind of object it is looking for, f (file) : so we are telling the find ...
#     ... command that we are looking for a file object
#     -print0 : this tells find command to print out the path/filename of every file it finds at the given ...
#     ... location and add '\0' at the end to mark where one file and ends and the other begins.
#     ... without -print0 the output will look like 
#           path/to/file/filename
#           path/to/file/filename
#           path/to/file/filename
#     ... with -print0 the output will be 
#           path/to/file/filename\0
#           path/to/file/filename\0
#           path/to/file/filename\0
#     ... why are we doing this. We'll answer that when we deal with the WHILE loop condition syntax
# So in layman's terms what '< <(find "$USB_PATH" -type f -print0)' is doing is recursively looking at all the ...
# ... contents at the location the variable "$USB_PATH" is pointing at and when it finds a file, it adds the ...
# ... file's name to a list adding '\0' to the end of each file name found. Once all objects in the location ...
# ... has been looked at, the list is then passed to the WHILE loop in a file format.
# The (conditional) in the WHILE loop is 'while IFS= read -r -d '' file; do' :
#   for each iteration one file name is targeted in sequence, the flags are applied
#   IFS (Internal Field Separator)= : This is set to empty to prevent trimming of leading and ...
#   ... trailing spaces. This way if the file name has space at the start or the end it is ...
#   ... kept as is so that the file name seen by the WHILE loop does not mismatch with the ...
#   ... original name of the file in the targeted path when the corruption check happens.
#   read : This is what reads the input file from the 'find' command. It reads one line at ...
#   ... a time enabling targeting one file name per iteration. The IFS= ensures the leading ...
#   ... and trailing spaces are preserved. 
#   -r : tells the 'read' command not to treat '\' as escape commands
#   -d '' : d for delimiter, tell the 'read' command to use the null character '\0' as ...
#   ... the delimiter between file names because that is what we used to separate ...
#   ... each file when we ran the 'find' command, the -print0 flag
#   file : the shell variable where the name of file processed with the IFS=, -r and -d '' ...
#   ... is stored. This file variable is what is then passed into the loop.
# So in layman's terms 'while IFS= read -r -d '' file; do' means read from the file that was given by the ...
# ... 'find' command, one line at a time, without removing any existing leading or trailing spaces ...
# ... treating all '\' as not an escape character and using '\0' to identfy where a line ends. ...
# ... Then pass that line to the shell variable 'file'
# ((total_files++)), ((corrupt_files++)), ((skipped_files++)) : these are counter variables used to ...
# ... track how many files were there in total, how many were corrupt files and how many were skipped ...
# ... respectively. 


echo
echo " All relevant files in the USB named "$1" has been scanned."
echo "Total files checked: $total_files"
echo "Corrupt files: $corrupt_files"
echo "Skipped/unhandled files: $skipped_files"
