#!/bin/ksh
##############################################################################
#
# Script Name: generic_email_script.ksh
# Author: Trevor Little
# Purpose: Provide generic means to send emails to people
# Usage: Given some parameter file with exact variables names, send email with
#   provided parameters
#
# Usage: /path/to/this/script.ksh [-c|-i|-w] /path/to/parameter_file.ksh
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

blank=""
l_email_body=$blank
l_email_from=$blank
l_email_subject=$blank
l_email_to=$blank
l_email_cc=$blank
l_email_attachment=$blank
cmd=$blank

parameter_file=$2 #file argument to the script

abort_message(){
    printf "$1\n"
    echo "Aborting"
    exit 1
}

usage(){
    abort_message "INVALID USAGE OF SCRIPT.\nUsage: /path/to/this/script.ksh [-c|-i|-w] /path/to/parameter_file.ksh"
}

set_critical_variables(){
    l_email_subject=$email_critical_subject
    l_email_from=$email_critical_from
    l_email_to=$email_critical_to
    l_email_body=$email_critical_body
    l_email_cc=$email_critical_cc
    l_email_attachment=$email_critical_attachment
}

set_warning_variables(){
    l_email_subject=$email_warning_subject
    l_email_from=$email_warning_from
    l_email_to=$email_warning_to
    l_email_body=$email_warning_body
    l_email_cc=$email_warning_cc
    l_email_attachment=$email_warning_attachment
}

set_informational_variables(){
    l_email_subject=$email_informational_subject
    l_email_from=$email_informational_from
    l_email_to=$email_informational_to
    l_email_body=$email_informational_body
    l_email_cc=$email_informational_cc
    l_email_attachment=$email_informational_attachment
}


run_sanity_checks(){
    if ! [[ -s $parameter_file ]];
    then
        abort_message "parameter file does not exist or is empty."
    fi

    sumOfFlags=$(($critical_flag + $informational_flag + $warning_flag))

    if [[ $sumOfFlags -gt $on ]]
    then
        abort_message "more than 1 flag is on.\nCritical Flag: $critical_flag\nWarning Flag: $warning_flag\nInformational Flag: $informational_flag"
    fi
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

initialize_required_variables(){
    . $parameter_file
    if [[ $? -ne 0 ]];
    then
        abort_message "not able to source provided parameter file."
    fi

    eval_flag $critical_flag
    if [[ $? -eq $on ]]
    then
        set_critical_variables
    fi

    eval_flag $warning_flag
    if [[ $? -eq $on ]]
    then
        set_warning_variables
    fi

    eval_flag $informational_flag
    if [[ $? -eq $on ]]
    then
        set_informational_variables
    fi
}

check_required_parm(){
    if [[ $# -lt 2 ]]; #dependent on the fact that the initial value for all variables is ""
    then
        abort_message "$1 not found in the given parameter file for the flag passed to the script."
    fi
}

check_required_variables(){
    check_required_parm "Email_Body" $l_email_body
    check_required_parm "Email_From" $l_email_from
    check_required_parm "Email_Subject" $l_email_subject
    check_required_parm "Email_To" $l_email_to
}

add_to_cmd(){
    cmd="$cmd $*"
}

check_optional_parm(){
    if [[ $1 == $blank ]];
    then
        return $off
    else
        return $on
    fi
}

skip_optional_parms_msg(){
    echo "no associated $1 parameter in given config file. skipping"
}

build_command(){
    cmd="echo -e '$l_email_body' | mailx -S from=$l_email_from -s \"$l_email_subject\""

    check_optional_parm $l_email_cc
    if [[ $? -eq $on ]];
    then
        add_to_cmd "-c $l_email_cc"
    else
        skip_optional_parms_msg "cc"
    fi

    check_optional_parm $l_email_attachment
    if [[ $? -eq $on ]];
    then
        add_to_cmd "-a $l_email_attachment"
    else
        skip_optional_parms_msg "attachment"
    fi

    cmd="$cmd $l_email_to" #do this step last
}

run_command(){
    #eval "$cmd"
    echo "$cmd"
    if [[ $? -ne 0 ]];
    then
        abort_message "NOT ABLE TO RUN DYNAMIC COMMAND.\nCOMMAND CREATED: $cmd"
    fi
}

###########################################
#
# Start: initialize options and variables
#
###########################################

if [[ $# -ne 2 ]];
then
    abort_message "invalid number of arguments passed to the script."
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

run_sanity_checks

initialize_required_variables

check_required_variables

build_command

run_command
