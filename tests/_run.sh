#!/usr/bin/env bash

# Alternative to `make check`
# Script for running all the executable scripts in the folder 
# Success/Failure is reported

cd "${BASH_SOURCE[0]%/*}"      

echo "Working Directory:" $(pwd)
#echo "Which bash" $(which bash)

fails=0
for test in [^_]*.sh;
do
   if [[ -x "$test" ]]; then
       echo ">$test"
       out=$($test)
       [[ $? != 0 ]] && fails=$((fails + 1))
   fi
done

[[ $fails == 0 ]]  && echo "Pass" || echo "Fails: $fails"

exit $fails
