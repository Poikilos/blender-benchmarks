#!/bin/sh

if [ ! -f "`command -v svn`" ]; then
    echo "You must have svn installed to use this script."
    exit 1
fi

cat > /dev/null << END
Problem: "Cannot duplicate collection in Blender 2.80, removed instancing"

Solution:
Comment https://developer.blender.org/T65054#700228 says the benchmarks
should be updated from 
https://svn.blender.org/svnroot/bf-blender/trunk/lib/benchmarks/
END
BENCH_ROOT="`pwd`"
mkdir -p svn
cd svn
SVN_URL="https://svn.blender.org/svnroot/bf-blender/trunk/lib/benchmarks/"
if [ ! -d benchmarks ]; then
    # svn co https://svn.blender.org/svnroot/bf-blender/trunk/lib/benchmarks/ --config-option servers:miscellany:use-commit-times=yes
    svn co $SVN_URL --config-option config:miscellany:use-commit-times=yes
    # ^ See https://www.finalbuilder.com/forums/t/how-to-preserve-date-with-svn-check-out/1580/3
    # though issue is unresolved here:
    # https://issues.apache.org/jira/browse/SVN-1256
    if [ $? -ne 0 ]; then
        if [ ! -d "benchmarks" ]; then
            echo "Error:"
        else
            echo "Warning:"
        fi
        echo "svn co $SVN_URL failed."
        if [ ! -d "benchmarks" ]; then
            exit 1
        else
            echo "(continuing anyway since benchmarks exists)"
        fi
    fi
    cd benchmarks
    if [ $? -ne 0 ]; then
        echo "Error:"
        echo "cd benchmarks failed in `pwd`."
        exit 1
    fi
else
    cd benchmarks
    if [ $? -ne 0 ]; then
        echo "Error:"
        echo "cd benchmarks failed in `pwd`."
        exit 1
    fi
    svn update --config-option config:miscellany:use-commit-times=yes
    if [ $? -ne 0 ]; then
        echo "Warning:"
        echo "svn update failed in `pwd`."
    fi
fi

# We are now in benchmarks.

cd cycles
if [ $? -ne 0 ]; then
    echo "Error:"
    echo "cd cycles failed in `pwd`."
    exit 1
fi

UPDATED="../../../updated"
UPDATED=$BENCH_ROOT/updated
#echo "UPDATED=$UPDATED"
#echo "Contents:"
#ls "$UPDATED"
#echo
if [ ! -d "$UPDATED" ]; then
    mkdir "$UPDATED"
fi
echo "The original benchmarks on the Google sheet were performed using http://download.blender.org/demo/test/cycles_benchmark_20160228.zip"
echo
echo "The google sheet is the solution for now, unless a later version uses a database:"
echo "https://docs.google.com/spreadsheets/d/1tM5iDs-Xflzh6t-WHgXNr3YoFDFjBXGE92Md86bmmVA/edit#gid=0"
echo
echo "This script only gets the updated benchmarks, stored in $UPDATED."
echo "For example, in 2.80 or higher, you must use the updated classroom there since 2.80 removes instancing!"
echo
echo "If there are any updates they will appear before done."
for sub in `ls`
do
    TS=`../../../newest.py $sub --only-ext=blend`
    DATE=`date -ud @$TS '+%Y-%m-%d'`
    if [ ! -d "$UPDATED/$sub" ]; then
        mkdir "$UPDATED/$sub"
    fi
    #OOPS=`date -ud @$TS '+%Y-%M-%d'`
    # ^ M is for minute not month!
    #echo "Checking for bad \"$UPDATED/$sub/$OOPS\"..."
    #if [ -d "$UPDATED/$sub/$OOPS" ]; then
    #    echo "removed."
    #    rm -Rf "$UPDATED/$sub/$OOPS"
    #else
    #    echo "not found."
    #fi
    if [ ! -d "$UPDATED/$sub/$DATE" ]; then
        cp -R "$sub" "$UPDATED/$sub/$DATE"
        echo "cp -R \"$sub\" \"$UPDATED/$sub/$DATE\""
    fi
done
echo "Done."
echo
