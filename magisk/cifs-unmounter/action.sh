:

# Set up locations

LOG=/data/local/tmp/cifs-unmounter.txt
CIFS=/mnt/runtime/write/emulated/0/CIFS.mount

# Short circuit exit if CIFS not mounted
#
already=`mount | grep "on $CIFS"`
if [ "$already" == "" ] ; then
  echo "CIFS NOT MOUNTED!" | tee $LOG
  exit
fi

echo "unmounting CIFS" | tee -a $LOG
umount $CIFS

already=`mount | grep "on $CIFS"`
if [ "$already" == "" ] ; then
  echo "unmount CIFS SUCCESS!" | tee -a $LOG
else
  echo "unmount CIFS FAIL!" | tee -a $LOG
fi
