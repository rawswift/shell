#!/usr/bin/env bash

# Copyright (C) 2013 Ryan Yonzon
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

config_dir="$HOME/.gms"
certs_dir="$HOME/.gms/certs"
smtp="smtp://smtp.gmail.com:587"
mail_recipient=
mail_sender_address=
mail_sender_name=
mail_subject=
mail_content=
secret=

usage="Usage: $(basename "$0") [OPTIONS]
Send email from terminal.

Options:
    -t, --to        Mail recipient e.g. hello@sample.org
    -f, --from      Mail sender e.g. me@sample.org
    -n, --name      Mail sender's name e.g. \"John Doe\"
    -s, --subject   Mail Subject e.g. \"Foobar\"
    -c, --content   Mail content (body) e.g. \"Hello world\"
    -h, --help      Help

Written by Ryan Yonzon"

if [ -d "$config_dir" ]; then

    args=$(getopt -o t:f:n:s:c:h -l "to:,from:,name:,subject:,content:,help" -n "gms" -- "$@");

    if [ $? -ne 0 ]; then
        echo "Bad arguments!"
        echo "Use -h or --help parameter for help."
        exit 1
    fi

    eval set -- "$args";

    while true; do
        case "$1" in
            -t|--to)
                shift;
                if [ -n "$1" ]; then
                    mail_recipient=$1
                    shift
                fi
                ;;
            -f|--from)
                shift;
                if [ -n "$1" ]; then
                    mail_sender_address=$1
                    shift
                fi
                ;;
            -n|--name)
                shift;
                if [ -n "$1" ]; then
                    mail_sender_name=$1
                    shift
                fi
                ;;                
            -s|--subject)
                shift;
                if [ -n "$1" ]; then
                    mail_subject=$1
                    shift
                fi
                ;;
            -c|--content)
                shift;
                if [ -n "$1" ]; then
                    mail_content=$1
                    shift
                fi
                ;;            
            -h|--help)
                shift;
                echo "${usage}"
                exit
                ;;
            --)
                shift;
                break;
        esac
    done


if [ "$mail_recipient" == "" ] || [ "$mail_sender_address" == "" ] || [ "$mail_subject" == "" ] || [ "$mail_content" == "" ]; then
   echo "Required parameter missing!"
   echo "Use -h or --help parameter for help."
   exit
fi

if [ "$mail_sender_name" != "" ]; then
    mail_sender="$mail_sender_address ($mail_sender_name)"
else
    mail_sender="$mail_sender_address"
fi

if [ "$secret" == "" ]; then
    echo "Email: ${mail_sender}"
    read -s -p "Password: " secret
    if [ "$secret" == "" ]; then
        echo -e "\nOopps password is null, there's no way we can send without authenticating"
        exit
    fi
fi

# if all goes well...
echo -e "\n"
echo -e "$mail_content" | \
mailx -v -s "$mail_subject" \
-S smtp-use-starttls \
-S ssl-verify=ignore \
-S smtp-auth=login \
-S smtp=$smtp \
-S from="$mail_sender" \
-S smtp-auth-user=$mail_sender_address \
-S smtp-auth-password=$secret \
-S ssl-verify=ignore \
-S nss-config-dir=$certs_dir \
$mail_recipient

else
    echo "Error: Could not find '${config_dir}' in home directory"
    echo "Run 'gms-setup' first!"
    exit
fi