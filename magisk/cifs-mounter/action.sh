:

# Set up locations

LOG=/data/local/tmp/cifs-mounter.txt
CIFS=/mnt/runtime/write/emulated/0/CIFS.mount
CIFSuri=file:////storage/emulated/0/CIFS.mount

# Short circuit exit if CIFS already mounted
#
already=`mount | grep "on $CIFS"`
if [ "$already" != "" ] ; then
  echo "CIFS ALREADY MOUNTED!" | tee $LOG
  exit
fi

SHARE=`grep ^SHARE /sdcard/CIFS | awk '{print $2}'`
USERNAME=`grep ^USERNAME /sdcard/CIFS | awk '{print $2}'`
PASSWORD=`grep ^PASSWORD /sdcard/CIFS | awk '{print $2}'`
if [ "$SHARE" == "" ] ; then
  echo "ERROR: Missing SHARE in /sdcard/CIFS" | tee -a $LOG
  exit
fi
if [ "$USERNAME" == "" ] ; then
  echo "ERROR: Missing USERNAME in /sdcard/CIFS" | tee -a $LOG
  exit
fi
if [ "$PASSWORD" == "" ] ; then
  echo "ERROR: Missing PASSWORD in /sdcard/CIFS" | tee -a $LOG
  exit
fi

# create CIFS mountpoint as needed and set up selinux policies
#
if [ ! -d $CIFS ] ; then
  mkdir $CIFS
  chgrp media_rw $CIFS
  chmod 750 $CIFS
fi
#magiskpolicy --live "allow kernel kernel capability net_raw"
#magiskpolicy --live "allow kernel kernel socket { create bind }"
#magiskpolicy --live "allow mediaprovider unlabeled dir getattr"
#magiskpolicy --live "allow platform_app unlabeled dir getattr"
setenforce 0

# mount that badboy
#
echo "mounting SHARE=$SHARE with USERNAME=$USERNAME and PASSWORD=<REDACT>" | tee -a $LOG
mount -t cifs -o username=$USERNAME,password=$PASSWORD,vers=2.1,ro,noatime,uid=0,gid=1015 $SHARE $CIFS

# verify mount (should be $CIFS if it is really mounted)
#
already=`mount | grep "on $CIFS"`
if [ "$already" == "" ] ; then
  echo "ERROR: CIFS MOUNT FAILURE!" | tee -a $LOG
  exit
else
  echo "MOUNT SUCCESS!" | tee -a $LOG
fi

#
# If successful broadcast media scanner intent
#
echo "Broadcasting media scanner intent" | tee -a $LOG
am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d $CIFSuri
