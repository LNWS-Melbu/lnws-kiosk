#!/bin/bash

# be new
apt-get update

# get software
apt-get install \
	unclutter \
    xorg \
    chromium \
    openbox \
    lightdm \
    locales \
    -y

# dir
mkdir -p /home/lnws/.config/openbox

# create group
groupadd lnws

# create user if not exists
id -u lnws &>/dev/null || useradd -m lnws -g lnws -s /bin/bash 

# rights
chown -R lnws:lnws /home/lnws

# remove virtual consoles
if [ -e "/etc/X11/xorg.conf" ]; then
  mv /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
fi
cat > /etc/X11/xorg.conf << EOF
Section "ServerFlags"
    Option "DontVTSwitch" "true"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"	
EndSection
EOF

# create config
if [ -e "/etc/lightdm/lightdm.conf" ]; then
  mv /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup
fi
cat > /etc/lightdm/lightdm.conf << EOF
[SeatDefaults]
autologin-user=lnws
user-session=openbox
EOF

# create autostart
if [ -e "/home/lnws/.config/openbox/autostart" ]; then
  mv /home/lnws/.config/openbox/autostart /home/lnws/.config/openbox/autostart.backup
fi
cat > /home/lnws/.config/openbox/autostart << EOF
#!/bin/bash

unclutter -idle 0.1 -grab -root &

while :
do
  xrandr --auto
  chromium \
    --no-first-run \
    --start-maximized \
    --disable \
    --disable-translate \
    --disable-infobars \
    --disable-suggestions-service \
    --disable-save-password-bubble \
    --disable-session-crashed-bubble \
    --incognito \
    --start-fullscreen \
    --lnws "http://scada.melbu.leroy.no/data/perspective/client/Klokke"
  sleep 5
done &
EOF

echo "Done!"
