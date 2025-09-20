#!/bin/ksh
##############################################################################
#
# Script Name: generic_email_script.ksh
# Author: Trevor Little
# Purpose: Provide generic means to send emails to people
# Usage: Given some parameter with exact variables names, send email with
#   provided parameters
#
# Command: /path/to/generic_email_script.ksh $PATH_TO_PARAMETER_FILE
#
##############################################################################

###########################################
#
# Helper Functions and Variables
#
###########################################

check_parm_value(){
    if [[ $1 == "" ]];
    then
        return 1
    else
        return 0
    fi
}

###########################################
#
# Start: Initial checks and variables
#
###########################################

if [[ $# -lt 1 ]];
then
    echo "not enough arguments. Aborting"
    exit 1

fi

email_file=$1

if ! [[ -f $email_file ]];
then
    echo "File does not exist. Exiting"
    exit 1
fi

source $email_file

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

cmd="$cmd $email_to"

###########################################
#
# Run Dynamic Command
#
###########################################

eval "$cmd"

if [[ $? -ne 0 ]];
then
    echo "NOT ABLE TO RUN DYNAMIC COMMAND. ABORTING"
    echo "COMMAND CREATED: $cmd"
    exit 1
fi
