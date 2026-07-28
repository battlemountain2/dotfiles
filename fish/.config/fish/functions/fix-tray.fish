function fix-tray --description 'Re-disable kded6 tray module after pacman updates'
    sudo mv /usr/lib/qt6/plugins/kf6/kded/statusnotifierwatcher.so /usr/lib/qt6/plugins/kf6/kded/statusnotifierwatcher.so.disabled
    kbuildsycoca6
    pkill kded6
    kded6 &
    echo "kded6 tray module disabled and kded6 restarted."
end
