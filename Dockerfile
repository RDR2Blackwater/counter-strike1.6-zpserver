FROM debian:8

# define default env variables
ENV PORT=27015
ENV MAP=de_dust2
ENV MAXPLAYERS=32
ENV SV_LAN=0

# install dependencies & add user for non-root installation of SteamCMD
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get -qqy --force-yes install lib32gcc1 libsdl2-2.0-0:i386 curl nginx nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -d /home/steamTemp -m steamTemp \
    && mkdir -p /SteamCMD/Steam /SteamCMD/.steam /hlds \
    && chown -R steamTemp:steamTemp /hlds \
    && chown -R steamTemp:steamTemp /SteamCMD \
    && chmod 760 /hlds \
    && chmod 760 /SteamCMD
USER steamTemp

# create directories, download steamcmd and copy zp server files to the directory
# DO NOT LOGIN AS "anonymous", THIS WILL CAUSE UNEXPECTABLE PAUSE WHILE INSTALLING
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar -zxf - -C /SteamCMD/Steam \
    && /SteamCMD/Steam/steamcmd.sh +force_install_dir /hlds/ +login user password Guard_Code +app_set_config 90 mod cstrike +app_update 90 validate +quit || true \
    && rm -r /hlds/steamapps/* \
#   if second installation failed, remove "#" in front of the next line
#   && curl -s https://raw.githubusercontent.com/dgibbs64/HLDS-appmanifest/master/CounterStrike/appmanifest_90.acf -o /hlds/steamapps/appmanifest_90.acf \
    && /SteamCMD/Steam/steamcmd.sh +force_install_dir /hlds/ +login user password Guard_Code +app_update 90 validate +quit

USER root
RUN rm -r /SteamCMD

#directory hlds contains my plugins, bots, configs, etc.
#this step can be replaced by the installation of any other plugins 
COPY hlds /hlds/

# configure nginx to allow for FastDownload
# FastDownload configurations have been written into server.cfg, check /hlds/cstrike/server.cfg for more information
RUN mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup \
    && bash -c "mkdir -p /srv/cstrike/{gfx,maps,models,overviews,sound,sprites}/nothing-here"
COPY nginx_config.conf /etc/nginx/sites-available/default

WORKDIR /hlds
ENTRYPOINT service nginx start; ./hlds_run -game cstrike -strictportbind -ip 0.0.0.0 -port $PORT +sv_lan $SV_LAN +map $MAP -maxplayers $MAXPLAYERS
