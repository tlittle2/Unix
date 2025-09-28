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

critical_flag=0
informational_flag=0
warning_flag=0

usage(){
    echo -e "invalid usage of script. Aborting. \n"
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

determine_from(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_from
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_from
    fi

    is_informational
    if [[ $? -eq 1 ]]
    then
        echo $email_informational_from
    fi
}

determine_to(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_to
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_to
    fi

    is_informational
    if [[ $? -eq 1 ]]
    then
        echo $email_informational_to
    fi
}

determine_body(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_body
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_body
    fi

    is_informational
    if [[ $? -eq 1 ]]
    then
        echo $email_informational_body
    fi
}

determine_cc(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_cc
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_cc
    fi

    is_informational
    if [[ $? -eq 1 ]]
    then
        echo $email_informational_cc
    fi
}

determine_attachment(){
    is_critical
    if [[ $? -eq 1 ]]
    then
        echo $email_critical_attachment
    fi

    is_warning
    if [[ $? -eq 1 ]]
    then
        echo $email_warning_attachment
    fi

    is_informational
    if [[ $? -eq 1 ]]
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
    ?) usage; exit 1;
    ;;
esac

check_flags
if [[ $? -ne 0 ]];
then
    echo "more than 1 flag is on. Aborting"
    echo "Critical Flag: " $critical_flag
    echo "Warning Flag: " $warning_flag
    echo "Informational Flag: " $informational_flag
    exit 1
fi


email_file=$2
if ! [[ -s $email_file ]];
then
    echo "parameter file does not exist or is empty. Aborting"
    exit 1
fi


. $email_file
if [[ $? -ne 0 ]];
then
    echo "not able to source provided parameter file. Aborting"
    exit 1
fi


###########################################
#
# Assert required variables for basic email creation
#
###########################################

l_email_body=`determine_body`
check_parm_value $l_email_body
if [[ $? -eq 1 ]];
then
    echo "Email Body not found. Aborting."
    exit 1
fi


l_email_from=`determine_from`
check_parm_value $l_email_from
if [[ $? -eq 1 ]];
then
    echo "Email From not found. Aborting."
    exit 1
fi


l_email_subject=`determine_subject`
check_parm_value $l_email_subject
if [[ $? -eq 1 ]];
then
    echo "Email Subject not found. Aborting."
    exit 1
fi


l_email_to=`determine_to`
check_parm_value $l_email_to
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


cmd="echo -e '$l_email_body' | mailx -S from=$l_email_from -s \"$l_email_subject\""

l_email_cc=`determine_cc`
check_parm_value $l_email_cc
if [[ $? -eq 0 ]];
then
    cmd="$cmd -c $l_email_cc"
else
    echo "no associated cc parameter in given config file. skipping"
fi

l_email_attachment=`determine_attachment`
check_parm_value $l_email_attachment
if [[ $? -eq 0 ]];
then
    cmd="$cmd -a $l_email_attachment"
else
    echo "no associated attachment parameter in given config file. skipping"
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
    echo "NOT ABLE TO RUN DYNAMIC COMMAND. ABORTING"
    echo "COMMAND CREATED: $cmd"
    exit 1
fi
