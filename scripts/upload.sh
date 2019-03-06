UPLOAD_FLAG=uploadDone
if [ ! -f $UPLOAD_FLAG ]; then
    echo "First boot after update detected"
    sleep 5 #Give iobroker time to start
    echo "Uploading adapter files"
    iobroker upload all
    date > $UPLOAD_FLAG
    echo "First Boot pre-init done!"
fi
