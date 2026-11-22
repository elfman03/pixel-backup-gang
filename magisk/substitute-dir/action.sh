:

# Set up locations

LOG=/data/local/tmp/substitute-dir.txt

photos_dir="/data/data/com.google.android.apps.photos"
media_dir="/data/data/com.android.providers.media"

echo "Searching for PHOTOS-OVERLAY partition" | tee $LOG
#
# check all /dev/block/sd?1 partitions
#
for thepart in /dev/block/sd?1 ; do
  overlay=`blkid "$thepart" | grep 'LABEL="PHOTOS-OVERLAY"'`
  #
  # If we find overlay
  #
  if [ "$overlay" != "" ] ; then
    break
  fi
done

if [ "$overlay" == "" ] ; then
  echo "NO PHOTOS-OVERLAY FOUND.   Create a USB partition and run 'mkfs.ext4 -L PHOTOS-OVERLAY /dev/block/sd?1'" | tee -a $LOG
  exit 1
fi

already=`mount | grep /mnt/photos-overlay`
if [ "$already" != "" ] ; then
  echo "photos-overlay already loaded.  reboot before running it again!" | tee -a $LOG
  exit 1
fi

am force-stop com.android.providers.media
am force-stop com.google.android.apps.photos

# Make internal mount point as needed, mount
#
mkdir -p /mnt/photos-overlay
mount "$thepart" /mnt/photos-overlay -o noatime
mount | grep /mnt/photos-overlay | tee -a $LOG
already=`mount | grep /mnt/photos-overlay`
if [ "$already" != "" ] ; then
  echo "base mount SUCCESS!" | tee -a $LOG
else
  echo "base mount FAIL!" | tee -a $LOG
  exit 1
fi

if [ ! -r /mnt/photos-overlay/initialized ] ; then
  echo "First Run...  Initializing photos-overlay with photos and media flash content" | tee -a $LOG
  #cp -pr --preserve=context "$media_dir/." /mnt/photos-overlay/media/
  cp -prc "$media_dir/." /mnt/photos-overlay/media/
  ret=$?
  if [ $ret -ne 0 ] ; then
    echo "MEDIA INITIALIZATION COPY FAILED! ret=$ret" | tee -a $LOG
    exit 1
  fi
  #
  #cp -prv --preserve=context "$photos_dir/." /mnt/photos-overlay/photos/
  cp -prc "$photos_dir/." /mnt/photos-overlay/photos/
  ret=$?
  if [ $ret -ne 0 ] ; then
    echo "PHOTOS INITIALIZATION COPY FAILED! ret=$ret" | tee -a $LOG
    exit 1
  fi
  #
  touch /mnt/photos-overlay/initialized
else
  echo "photos-overlay already initialized.  Not copying from flash content" | tee -a $LOG
fi

#
# Bind mount for google photos
#
mount --bind /mnt/photos-overlay/photos $photos_dir
mount | grep $photos_dir | tee -a $LOG
already=`mount | grep $photos_dir`
if [ "$already" != "" ] ; then
  echo "photos bind mount SUCCESS!" | tee -a $LOG
else
  echo "photos bind mount FAIL!" | tee -a $LOG
  exit 1
fi

#
# Bind mount for media scanner
#
mount --bind /mnt/photos-overlay/media $media_dir
already=`mount | grep $media_dir`
if [ "$already" != "" ] ; then
  echo "media bind mount SUCCESS!" | tee -a $LOG
else
  echo "media bind mount FAIL!" | tee -a $LOG
  exit 1
fi

#
# be pedantic.  In case Android triggered an interim restart
#
am force-stop com.android.providers.media
am force-stop com.google.android.apps.photos


echo "COMPLETE!" | tee -a $LOG

