rooted Magisk module action button based scripts for handling remount processing

Install Steps:
 * copy zip files to download folder of android device
 * Install modules in magisk using modules view
 * reboot

usb-mounter / usb-unmounter:
 * Attach drive to phone
 * in Magisk module view press action button to cross mount it.
   * drive is mounted to /mnt/runtime/write/emulated/0/DCIM/Camera/sidemount
 * When done, use unmounter Magisk module action to unmount it
 * NOTE: script DOES initiate a media scan intent after mounting
 * NOTE: Pixel by default works with FAT32 usb.
 * NOTE: Kernel customization required for exFAT

cifs-mounter / cifs-unmounter
 * create a file /sdcard/CIFS with content
   * SHARE username       (e.g., //192.168.1.1/myshare)
   * USERNAME username
   * PASSWORD password    (note, may not work with empty passwords)
 * in Magisk module view press action button to cross mount it.
   * drive is mounted to /mnt/runtime/write/emulated/0/DCIM/Camera/sidemount
 * When done, use unmounter Magisk module action to unmount it
 * NOTE: script DOES initiate a media scan intent after mounting
 * NOTE: partition is mounted READONLY
 * NOTE: requires kernel customization to enable CIFS

wifi-adb
 * Use action button to enable adb over wifi.  
 * NOTE: Persists till reboot

substitute-dir
 * Preparation
   * create ext4 partition on a thumb drive with label "PHOTOS-OVERLAY"
     * e.g., mkfs.ext4 -L PHOTOS-OVERLAY /dev/block/sdg1 
 * in Magisk module view press action button to mount it.
   * drive is mounted to /mnt/photos-overlay
   * first time /data/data/com.android.providers.media and /data/data/com.google.android.apps.photos are copied to overlay
   * overlay is bind mounted on top of /data/data/com.android.providers.media and /data/data/com.google.android.apps.photos 
 * NOTE: persists till reboot

