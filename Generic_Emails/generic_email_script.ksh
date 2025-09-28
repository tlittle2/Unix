#!/bin/ksh

##############################################################################
#
# Script Name: generic_email_script.ksh
# Author: Trevor Little
# Purpose: Provide generic means to send emails to people
# Usage: Given some parameter with exact variables names, send email with
#   provided parameters
#
##############################################################################

###########################################
#
# Helper Functions and Variables
#
###########################################

critical_flag=0
informational_flag=0
warning_flag=0

usage(){
    echo "invalid usage of script"
    echo "Usage: /path/to/this/script.ksh [-c|-i|-w] parameter_file.ksh"
}

is_critical(){
    if [[ $critical_flag -eq 1 ]]
    then
        return 1
    else
        return 0
    fi
}

is_informational(){
    if [[ $informational_flag -eq 1 ]]
    then
        return 1
    else
        return 0
    fi
}

is_warning(){
    if [[ $warning_flag -eq 1 ]]
    then
        return 1
    else
        return 0
    fi
}


determine_subject(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_subject
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_subject
    fi

    is_informational
    if [[ $? -eq 1 ]]
    then
        echo $email_informational_subject
    fi
}

check_parm_value(){
    if [[ $1 == "" ]];
    then
        return 1
    else
        return 0
    fi
}

check_flags(){
    sumOfFlags=$(($critical_flag + $informational_flag + $warning_flag))
    if [[ $sumOfFlags -gt 1 ]]
    then
        return 1
    fi
}

###########################################
#
# Start: initialize options and variables
#
###########################################

if [[ $# -ne 2 ]];
then
    echo "not enough arguments. Aborting"
    exit 1

fi

getopts "ciw" opt;
case $opt in
c) critical_flag=1
;;
i) informational_flag=1
;;
w) warning_flag=1
;;
*) usage; exit 1;
;;
esac


check_flags
if [[ $? -ne 0 ]];
then
    echo "more than 1 flag is on. Aborting"
    echo "Critical Flag:" $critical_flag
    echo "Warning Flag:" $warning_flag
    echo "Informational Flag" $informational_flag
    exit 1
fi


email_file=$2
if ! [[ -s $email_file ]];
then
    echo "File does not exist. Exiting"
    exit 1
fi


. $email_file
if [[ $? -ne 0 ]];
then
    echo "not able to source provided file. Aborting"
    exit 1
fi


###########################################
#
# Assert required variables for basic email creation
#
###########################################

check_parm_value $email_body
if [[ $? -eq 1 ]];
then
    echo "Email Body not found. Aborting."
    exit 1
fi


check_parm_value $email_from
if [[ $? -eq 1 ]];
then
    echo "Email From not found. Aborting."
    exit 1
fi


email_subject=`determine_subject`

check_parm_value $email_subject
if [[ $? -eq 1 ]];
then
    echo "Email Subject not found. Aborting."
    exit 1
fi


check_parm_value $email_to
if [[ $? -eq 1 ]];
then
    echo "Email To not found. Aborting."
    exit 1
fi

###########################################
#
# Build Dynamic Command with left over variables (if they exist)
#
###########################################

cmd="echo -e '$email_body' | mailx -S from=$email_from -s \"$email_subject\""


check_parm_value $email_cc
if [[ $? -eq 0 ]];
then
    cmd="$cmd -c $email_cc"
fi


check_parm_value $email_attachment
if [[ $? -eq 0 ]];
then
    cmd="$cmd -a $email_attachment"
fi

#do this step last
cmd="$cmd $email_to"

###########################################
#
# Run Dynamic Command
#
###########################################

#eval "$cmd"
echo "$cmd"

if [[ $? -ne 0 ]];
then
    echo "NOT ABLE TO RUN DYNAMIC COMMAND. ABORTING"
    echo "COMMAND CREATED: $cmd"
    exit 1
fi
