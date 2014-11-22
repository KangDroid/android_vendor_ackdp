for combo in $(curl -s https://raw.githubusercontent.com/KangDroid/Vendorsetup/master/ackdp-build-target | sed -e 's/#.*$//' | grep cm-11.0 | awk {'print $1'})
do
    add_lunch_combo $combo
done
