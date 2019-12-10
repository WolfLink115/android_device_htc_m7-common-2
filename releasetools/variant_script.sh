#!/sbin/sh

set -e

# Helper functions
copy()
{
  LD_LIBRARY_PATH=/system/lib /sbin/busybox cp -c "$1" "$2"
}

# Detect variant and copy its specific-blobs
modelid=`getprop ro.boot.mid`

case $modelid in
    "PN0731000") variant="vzw" ;;
    "PN0720000") variant="spr" ;;
    "PN0710000") variant="gsm" ;;
    *)           variant="gsm" ;;
esac

# Skip copying blobs in case of Dual SIM variants because the files are already in the proper location
if [ "$variant" == "vzw" ] || [ "$variant" == "spr" ] || [ "$variant" == "gsm" ]; then
  basedir="/system/system/vendor/blobs/$variant/"
  if [ -d $basedir ]; then
    cd $basedir

    for file in `find . -type f` ; do
      mkdir -p `dirname /system/system/vendor/$file`
      copy $file /system/system/vendor/$file
    done

    for file in bin/* ; do
      chmod 755 /system/system/vendor/$file
    done
  else
    echo "Expected source directory does not exist!"
    exit 1
  fi
fi

exit 0
