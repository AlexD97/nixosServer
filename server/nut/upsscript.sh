#!/run/current-system/sw/bin/sh
case $1 in
  onbatt)
    shutdown -h +0;;
  battleer)
    upssched fsd;;
  *)
    logger -t upssched "Falscher Parameter";;
esac
