#!/bin/bash
echo -e "\n"
### note, reattach screen screen -d -r ####.$session_name
### kill screen with Ctrl-a + k
############################################################
##                                                        ##
## With notes from:                                       ##
## http://stackoverflow.com/questions/3623662/ddg#3626205 ##
##                                                        ##
## https://unix.stackexchange.com/questions/163872/       ##
## sharing-a-terminal-with-multiple-users-with-screen-    ##
## or-otherwise                                           ##
##                                                        ##
## https://www.putorius.net/                              ##
## create-multiple-choice-menu-bash.html                  ##
############################################################
echo -e "################################################"
echo -e "##         Multiuser Setup Script             ##"
echo -e "## Authored by Reddit user u/jogaltanon26     ##"
echo -e "################################################\n"
echo -e "##### To exit an active screen, Ctrl-a + d #####\n"
echo -e "For help with additional commands, 'screen -help'"
PS3='Do you want to join a currently shared session or make a session:  '
option=("Join" "Create" "Delete")
select session_option in "${option[@]}"; do
	case $session_option in
		"Join")
			echo -e "What's the multiuser screen name?"
			read case_join_name
			echo -e "Make sure the screen ownder has added you to the acl.."
			sleep 2
			echo -e "Attempting to add you to the shared screen" |  sudo screen -x $(whoami)/$case_join_name
			sleep 1
			exit
			;;
		"Create")
			echo -e "Answer the following qustions to setup your multiuser screen session."
			echo -e "Attempting to run as root.\n"
			echo -e "What do you want to name your session? Press Enter for Default: multi0"
			read session_name
			echo -e "How many users to you want to be in your session?"
			read num_users
			echo -e "Type the comma separated users you want to share your session with."
			read list_users
			user_local=$(whoami)
			##echo -e "Your user name is: $user_local "
			##### Set default session name to multi0 if user doesn't input a name.
			if [ -z "$session_name" ]; then 
				session_name="multi0"
			fi

			## Validate the number of users is an integer, exit if not.
			function is_int() { return $(test "$@" -eq "$@" > /dev/null 2>&1); }
				input=$num_users
				if $(is_int "${input}"); then
					echo -e "\n"
				else
			   		echo "Not a valid number of users... ${input}"
				fi

			## Validate number is 1 or more, can be the same user twice for all I care, else exit.
			if [[ $num_users =~ ^[+-]?[0-9]+$ ]]; then 
				if [ $num_users -lt 1 ]; then 
			   	  echo -e "Why are you even running this script if you want less than $num_users users to share your screen?"
			   	  echo -e "Quit messing around..."
			   	  exit
				fi
			## Redundant, can remove later.
			elif [[ $num_users =~ ^[+-]?[0-9]+\.$ ]]; then
				echo -e "Not an integer..."
				exit
			## Redundant, can remove later.
			elif [[ $num_users =~ ^[+-]?[0-9]+\.?[0-9]*$ ]]; then
				echo -e "Still an not an integer... i.e. a whole number..."
				exit
			fi

			echo -e "Making multiuser sesion: $session_name for $num_users users: $list_users"
			## Create a session
			## Show the commands I'm running, and execute them.
			echo -e "sudo screen -d -m -S $session_name" | sudo screen -d -m -S $session_name
			echo -e "sudo screen -S $session_name -X multiuser on" | sudo screen -S $session_name -X multiuser on
			##echo -e "Tell the other users to use the following commands on their screen."
			x=1
			while [ $x -le $num_users ]
			do
			        IFS=',' read -ra my_array <<< "$list_users"
			        for i in "${my_array[@]}"
			        do
			                echo -e "sudo screen -S $session_name -X acladd $i" | sudo screen -S $session_name -X acladd $i
					echo -e "Tell $i to run the following command: sudo screen -x $session_name"
					x=$(( $x + 1 ))
			        done
			done
			;;
		"Delete")
			echo -e "TBD Functionality"
			exit
			;;
	esac
			### Want to join the multi-screen from here but can't
			#echo -e "Joining the session you created."
			sleep 1
			echo -e "Run the following command: sudo screen -x $session_name "
			#echo -e "sudo screen -x $session_name" | sudo screen -x $session_name
			exit
done
