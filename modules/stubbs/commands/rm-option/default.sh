#!/usr/bin/env bash
#
# NAME
#
#   rm-option
#
# DESCRIPTION
#
#   remove a command option
#

# Source common function library
source $RERUN_MODULES/stubbs/lib/functions.sh || { echo "failed laoding function library" ; exit 1 ; }


# Init the handler
rerun_init 

# Get the options
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$OPT" in
	# options with arguments
	-o|--option)
	    rerun_option_check "$#"
	    OPTION="$2"
	    shift
	    ;;
	-c|--command)
	    rerun_option_check "$#"
		# Parse if command is named "module:command"
	 	regex='([^:]+)(:)([^:]+)'
		if [[ $2 =~ $regex ]]
		then
			MODULE=${BASH_REMATCH[1]}
			COMMAND=${BASH_REMATCH[3]}
		else
	    	COMMAND="$2"		
	    fi
	    shift
	    ;;
	-m|--module)
	    rerun_option_check "$#"
	    MODULE="$2"
	    shift
	    ;;
        # unknown option
	-?)
	    rerun_option_error
	    ;;
	  # end of options, just arguments left
	*)
	    break
    esac
    shift
done

# Post process the options

[ -z "$MODULE" ] && {
    echo "Module: "
    select MODULE in $(rerun_modules $RERUN_MODULES);
    do
	echo "You picked module $MODULE ($REPLY)"
	break
    done
}

[ -z "$COMMAND" ] && {
    echo "Command: "
    select COMMAND in $(rerun_commands $RERUN_MODULES $MODULE);
    do
	echo "You picked command $COMMAND ($REPLY)"
	break
    done
}

[ -z "$OPTION" ] && {
    echo "Option: "
    read OPTION
}


# Verify this command exists
#
[ -d $RERUN_MODULES/$MODULE/commands/$COMMAND ] || {
    rerun_die "command not found: \""$MODULE:$COMMAND\"""
}

# Remove the .option file

if [ -f "$RERUN_MODULES/$MODULE/commands/$COMMAND/$OPTION.option" ]
then
    rm "$RERUN_MODULES/$MODULE/commands/$COMMAND/$OPTION.option" || {
        rerun_die "Error removing $OPTION.option file"
    }
    echo "Removed $RERUN_MODULES/$MODULE/commands/$COMMAND/$OPTION.option"
fi

# Regenerate the option.sh

# Generate option parser script.
rerun_generateOptionsParser $RERUN_MODULES $MODULE $COMMAND > $RERUN_MODULES/$MODULE/commands/$COMMAND/options.sh || rerun_die
echo "Wrote options script: $RERUN_MODULES/$MODULE/commands/$COMMAND/options.sh"

# Done

