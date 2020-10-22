
# FROM https://stackoverflow.com/a/47159781
# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}


export JAVA11='/usr/lib/jvm/java-11'
export JAVA8='/usr/lib/jvm/java-1.8.0'

function java11env(){
        [ -z "$JAVA_HOME" ] || pathremove "$JAVA_HOME/bin"
        export JAVA_HOME="$JAVA11"
        pathprepend "$JAVA_HOME/bin"
}

function java8env() {
        [ -z "$JAVA_HOME" ] || pathremove "$JAVA_HOME/bin"
        export JAVA_HOME="$JAVA8"
        pathprepend "$JAVA_HOME/bin"
}
