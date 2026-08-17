function fix-tray --description 'Re-disable kded6 tray module after pacman updates'
    set -l plugin /usr/lib/qt6/plugins/kf6/kded/statusnotifierwatcher.so

    if not test -f $plugin
        echo "fix-tray: $plugin not present -- already disabled, nothing to do."
        return 0
    end

    sudo mv $plugin $plugin.disabled; or return 1

    kbuildsycoca6
    pkill kded6
    kded6 &
    echo "kded6 tray module disabled and kded6 restarted."
end
