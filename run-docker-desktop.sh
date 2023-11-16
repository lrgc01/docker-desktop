#!/bin/sh

Usage() {
	echo "Usage: $0 <parameters:>"
        echo "   -i imgname"
        echo "   -s containerSequence"
        echo "   -n containerName"
        echo "   --priv (run in privileged mode)"
        echo "   --shm (use ipc=host)"
        echo "   -d (dryrun) -h (this help)"
}

#sudo docker run -d -p 3389:3389 -p 177:177/udp -v /home:/home --name=teste2 lrgc01/desktop:arm64 /lib/systemd/systemd --system --deserialize 35

while [ $# -gt 0 ]
do
   case $1 in
      -[iI]) IMGNAME="$2"
          shift 2
      ;;
      -[sS]) NUM="$2"
          shift 2
      ;;
      --[nN][aA][mM][eE]|-[nN]) 
          NAME="$2"
          shift 2
      ;;
      --[pP][rR][iI][vV]) 
          PRIVILEGED="--privileged"
          shift 1
      ;;
      --[sS][hH][mM]) 
          SHM="--ipc=host"
          shift 1
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

NUM=${NUM:-"1"}
NAME=${NAME:-"DeskDock$NUM"}
IMGNAME=${IMGNAME:-"lrgc01/desktop:latest" }
NUM_1=$(expr $NUM - 1)

if [ `whoami` != "root" ]; then
	SUDO="sudo"
fi

for _dev in /dev/fuse /dev/video$NUM_1 /dev/dri/card0 /dev/dri/renderD128
do
   if [ -c $_dev ]; then
      DEV="$DEV --device=$_dev:$_dev"
   fi
done
$DRYRUN $SUDO docker run -d \
        --restart=unless-stopped \
	-p 3389$NUM:3389 \
	-p 177$NUM:177/udp \
	-p 2222$NUM:22 \
	--cap-add=SYS_ADMIN \
	--security-opt=apparmor:unconfined \
        $DEV \
        $SHM \
        $PRIVILEGED \
	-v /home:/home \
	--entrypoint="/init" \
	--name=$NAME \
	--hostname=$NAME \
	$IMGNAME 
