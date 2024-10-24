#!/bin/sh

Usage() {
        echo "Usage: $0"
	echo "    -n container_name (mandatory)"
	echo "    -u u1,u2,u3,... (comma separated list)"
	echo "    -g g1,g2,g3,... (comma separated list)"
	echo "    -s <shell_path> (user shell for all in list)"
        echo "    -e <environment file name>"
        echo "    -d (dryrun)"
        echo "    -h (this help)"
}

_SHELL=/bin/bash

while [ $# -gt 0 ]
do
   case $1 in
      --[nN][aA][mM][eE]|-[nN])
          _CONTNAME="$2"
          shift 2
      ;;
      --[uU][sS][eE][rR]|-[uU])
          _USERS="$2"
          shift 2
      ;;
      --[gG][rR][oO][uU][pP]|-[gG])
          _GROUPLIST="$2"
          shift 2
      ;;
      --[sS][hH][eE][lL][lL]|-[sS])
          _SHELL="$2"
          shift 2
      ;;
      --[eE][nN][vV][iI][rR]*|-[eE])
          _ENVFILE="$2"
          if [ -f "$_ENVFILE" ]; then
             . "$_ENVFILE"
          fi
          shift 2
      ;;
      --[dD][rR][yY]-[rR][uU][nN]|-[dD])
          DRYRUN='echo [DryRun] Would run:'
          _MINUSD="-d"
          shift 1
      ;;
      --[hH][eE][lL][pP]|-[hH])
          Usage
          exit
      ;;
      *) shift
      ;;
   esac
done

USERS=${_USERS:-""}
# Can use uid fixed in a variable
# _id_$user

   
if [ -z "$_GROUPLIST" ];then
   #_GROUPLIST="sudo,video,xrdp,lightdm"
   _GROUPLIST="sudo,video,audio,xrdp"
fi
if [ `whoami` != "root" ]; then
   SUDO="sudo"
fi   

if [ -z "$_CONTNAME" ]; then
   echo "Container name is mandatory (-n)"
   Usage
else
   for u in $(echo $USERS | sed -e 's/,/ /g')
   do
      _ID=$(eval echo \$_id_$u)
      if [ ! -z "$_ID" ]; then
         $DRYRUN $SUDO docker exec -i $_CONTNAME groupadd -g $_ID $u
         ID="-u $_ID -g $u"
      else
         ID=""
      fi
      $DRYRUN $SUDO docker exec -i $_CONTNAME useradd $ID -G $_GROUPLIST -s $_SHELL -d /home/$u -m $u
      $DRYRUN $SUDO docker exec -i $_CONTNAME bash -c "echo $u:123456 | chpasswd"
   done
fi
