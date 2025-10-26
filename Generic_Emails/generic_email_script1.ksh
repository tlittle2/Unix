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

blank=""
l_email_body=$blank
l_email_from=$blank
l_email_subject=$blank
l_email_to=$blank
l_email_cc=$blank
l_email_attachment=$blank
cmd=$blank

abort_message(){
    printf "$1\n"
    echo "Aborting"
    exit 1
}

usage(){
    abort_message "INVALID USAGE OF SCRIPT.\nUsage: /path/to/this/script.ksh [-c|-i|-w] /path/to/parameter_file.ksh"
}

skip_optional_parms_msg(){
    echo "no associated $1 parameter in given config file. skipping"
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

eval_flag(){
    flag=$1

    if [[ $flag -eq $on ]]
    then
        return $on
    else
        return $off
    fi

}

check_parm_value(){
    if [[ $1 == $blank ]];
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

check_required_parms(){ #parm to check is the last parameter on purpose
    error_msg_prefix=$1
    parm_to_check=$2

    check_parm_value $parm_to_check
    if [[ $? -eq $off ]];
    then
        abort_message "$1 not found in the given parameter file for the flag passed to the script."
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
    c) critical_flag=$on;
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
# Set required variables for basic email creation
#
###########################################

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

###########################################
#
# Assert required variables for basic email creation
#
###########################################

check_required_parms "Email_Body" $l_email_body
check_required_parms "Email_From" $l_email_from
check_required_parms "Email_Subject" $l_email_subject
check_required_parms "Email_To" $l_email_to

###########################################
#
# Build Dynamic Command with left over variables (if they exist)
#
############################################

cmd="echo -e '$l_email_body' | mailx -S from=$l_email_from -s \"$l_email_subject\""

check_parm_value $l_email_cc
if [[ $? -eq $on ]];
then
    cmd="$cmd -c $l_email_cc"
else
    skip_optional_parms_msg "cc"
fi


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
