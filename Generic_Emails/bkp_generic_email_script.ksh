#!/bin/ksh
##############################################################################
#
# Script Name: generic_email_script.ksh
# Author: Trevor Little
# Purpose: Provide generic means to send emails to people
# Usage: Given some parameter file with exact variables names, send email with
#   provided parameters
#
##############################################################################

###########################################
#
# Helper Functions and Variables
#
###########################################

on=1
off=0
critical_flag=$off
informational_flag=$off
warning_flag=$off

abort_message(){
    printf "$1\n"
    echo "Aborting"
    exit 1
}

usage(){
    abort_message "INVALID USAGE OF SCRIPT.\nUsage: /path/to/this/script.ksh [-c|-i|-w] /path/to/parameter_file.ksh"
}

abort_for_required_parms(){
    abort_message "$1 not found in the given parameter file for the flag passed to the script."
}

skip_optional_parms_msg(){
    echo "no associated $1 parameter in given config file. skipping"
}

eval_flag(){
    flag=$1

    if [[ $flag -eq $on ]]
    then
        return $on
    else
        return $off
    fi

}

is_critical(){
    eval_flag $critical_flag
    return $?
}

is_informational(){
    eval_flag $informational_flag
    return $?
}

is_warning(){
    eval_flag $warning_flag
    return $?
}


check_parm_value(){
    if [[ $1 == "" ]];
    then
        return $off
    else
        return $on
    fi
}

check_flags(){

    sumOfFlags=$(($critical_flag + $informational_flag + $warning_flag))

    if [[ $sumOfFlags -gt $on ]]
    then
        abort_message "more than 1 flag is on.\nCritical Flag: $critical_flag\nWarning Flag: $warning_flag\nInformational Flag: $informational_flag"
    fi

}

determine_subject(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_subject
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_subject
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_subject
    fi
}

determine_from(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_from
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_from
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_from
    fi
}

determine_to(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_to
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_to
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_to
    fi
}

determine_body(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_body
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_body
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_body
    fi
}

determine_cc(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_cc
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_cc
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_cc
    fi
}

determine_attachment(){
    is_critical
    if [[ $? -eq $on ]]
    then
        echo $email_critical_attachment
    fi

    is_warning
    if [[ $? -eq $on ]]
    then
        echo $email_warning_attachment
    fi

    is_informational
    if [[ $? -eq $on ]]
    then
        echo $email_informational_attachment
    fi
}

###########################################
#
# Start: initialize options and variables
#
###########################################


if [[ $# -ne 2 ]];
then
    abort_message "not enough arguments passed to the script."
fi

getopts "ciw" opt;
case $opt in
    c) critical_flag=$on
    ;;
    i) informational_flag=$on
    ;;
    w) warning_flag=$on
    ;;
    *) usage
    ;;
    ?) usage
    ;;
esac

check_flags

email_file=$2
if ! [[ -s $email_file ]];
then
    abort_message "parameter file does not exist or is empty."
fi


. $email_file
if [[ $? -ne 0 ]];
then
    abort_message "not able to source provided parameter file."
fi

###########################################
#
# Assert required variables for basic email creation
#
###########################################

l_email_body=`determine_body`
check_parm_value $l_email_body
if [[ $? -eq $off ]];
then
    abort_for_required_parms "Email Body"
fi

l_email_from=`determine_from`
check_parm_value $l_email_from
if [[ $? -eq $off ]];
then
    abort_for_required_parms "Email From"
fi

l_email_subject=`determine_subject`
check_parm_value $l_email_subject
if [[ $? -eq $off ]];
then
    abort_for_required_parms "Email Subject"
fi


l_email_to=`determine_to`
check_parm_value $l_email_to
if [[ $? -eq $off ]];
then
    abort_for_required_parms "Email To"
fi


###########################################
#
# Build Dynamic Command with left over variables (if they exist)
#
###########################################


cmd="echo -e '$l_email_body' | mailx -S from=$l_email_from -s \"$l_email_subject\""

l_email_cc=`determine_cc`
check_parm_value $l_email_cc
if [[ $? -eq $on ]];
then
    cmd="$cmd -c $l_email_cc"
else
    skip_optional_parms_msg "cc"
fi


l_email_attachment=`determine_attachment`
check_parm_value $l_email_attachment
if [[ $? -eq $on ]];
then
    cmd="$cmd -a $l_email_attachment"
else
    skip_optional_parms_msg "attachment"
fi


#do this step last
cmd="$cmd $l_email_to"

###########################################
#
# Run Dynamic Command
#
###########################################

#eval "$cmd"
echo "$cmd"
if [[ $? -ne 0 ]];
then
    abort_message "NOT ABLE TO RUN DYNAMIC COMMAND.\nCOMMAND CREATED: $cmd"
fi
