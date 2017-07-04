#!/bin/sh

#locale
sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime
sudo locale-gen ja_JP.UTF-8
sudo /usr/sbin/update-locale LANG=ja_JP.UTF-8

#php
phpver=7.1
phppath=/etc/php/${phpver}

grep '^date.timezone = "Asia/Tokyo"' ${phppath}/fpm/php.ini
if [ $? -eq 1 ]; then
    # FPM
    sudo sed -i.org -e 's/date.timezone = UTC/date.timezone = \"Asia\/Tokyo\"/g' ${phppath}/fpm/php.ini
    sudo sed -i.org -e 's/;mbstring.language = Japanese/mbstring.language = Japanese/g' ${phppath}/fpm/php.ini
    # CLI
    sudo sed -i.org -e 's/date.timezone = UTC/date.timezone = \"Asia\/Tokyo\"/g' ${phppath}/cli/php.ini
    sudo sed -i.org -e 's/;mbstring.language = Japanese/mbstring.language = Japanese/g' ${phppath}/cli/php.ini
fi

# xdebug
sudo sed -i '$a xdebug.remote_autostart=1' /etc/php/7.1/mods-available/xdebug.ini

sudo service nginx restart
sudo service php${phpver}-fpm restart

#laravel-dusk
sudo apt-get update
sudo apt-get -y install \
     libxpm4 \
     libxrender1 \
     libgtk2.0-0 \
     libnss3 \
     libgconf-2-4 \
     chromium-browser \
     xvfb \
     gtk2-engines-pixbuf \
     xfonts-cyrillic \
     xfonts-100dpi \
     xfonts-75dpi \
     xfonts-base \
     xfonts-scalable \
     imagemagick \
     x11-apps \
     fonts-ipafont-gothic \
     fonts-ipafont-nonfree-uigothic \

sudo tee /etc/systemd/system/Xvfb.service > /dev/null <<EOF
[Unit]
Description=X Virtual Frame Buffer Service
After=network.target

[Service]
ExecStart=/usr/bin/Xvfb :0 -screen 0 1280x960x24

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable Xvfb.service
sudo systemctl start Xvfb.service

