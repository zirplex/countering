FROM debian:jessie

ARG steam_user=anonymous
ARG steam_password=
ARG metamod_version=1.20
ARG amxmod_version=1.8.2

RUN apt update && apt install -y lib32gcc1 curl

# Install SteamCMD
RUN mkdir -p /opt/steam && cd /opt/steam && \
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Install HLDS
RUN mkdir -p /opt/hlds
# Workaround for "app_update 90" bug, see https://forums.alliedmods.net/showthread.php?p=2518786
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 70 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 10 validate +quit || :
RUN /opt/steam/steamcmd.sh +login $steam_user $steam_password +force_install_dir /opt/hlds +app_update 90 validate +quit
RUN mkdir -p ~/.steam && ln -s /opt/hlds ~/.steam/sdk32
RUN ln -s /opt/steam/ /opt/hlds/steamcmd
ADD files/steam_appid.txt /opt/hlds/steam_appid.txt
ADD hlds_run.sh /bin/hlds_run.sh
RUN chmod +x /bin/hlds_run.sh

# Add default config
ADD files/server.cfg /opt/hlds/cstrike/server.cfg

# Add maps
ADD maps/* /opt/hlds/cstrike/maps/
ADD files/mapcycle.txt /opt/hlds/cstrike/mapcycle.txt

# Install metamod
RUN mkdir -p /opt/hlds/cstrike/addons/metamod/dlls
RUN curl -sqL "http://prdownloads.sourceforge.net/metamod/metamod-$metamod_version-linux.tar.gz?download" | tar -C /opt/hlds/cstrike/addons/metamod/dlls -zxvf -
ADD files/liblist.gam /opt/hlds/cstrike/liblist.gam
# Remove this line if you aren't going to install/use amxmodx and dproto
ADD files/plugins.ini /opt/hlds/cstrike/addons/metamod/plugins.ini

# Add bots
COPY podbot /opt/hlds/cstrike/addons/podbot


# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
ADD files/maps.ini /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini

COPY files/amx_gore_ultimate.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/amx_gore_ultimate.amxx
COPY files/amx_parachute.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/amx_parachute.amxx
COPY files/f_ultimate_sounds.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/f_ultimate_sounds.amxx

COPY files/parachute.mdl /opt/hlds/cstrike/models/parachute.mdl

RUN mkdir -p /opt/hlds/cstrike/sound/misc/female
RUN mkdir -p /opt/hlds/cstrike/addons/amxmodx/configs/csdm


COPY female/* /opt/hlds/cstrike/sound/misc/female/
COPY configs/* /opt/hlds/cstrike/addons/amxmodx/configs/
COPY modules/* /opt/hlds/cstrike/addons/amxmodx/modules/
COPY plugins/* /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY scripting/* /opt/hlds/cstrike/addons/amxmodx/scripting/
COPY configs/csdm/* /opt/hlds/cstrike/addons/amxmodx/configs/maps/
COPY configs/csdm/* /opt/hlds/cstrike/addons/amxmodx/configs/csdm/

RUN   echo "amx_gore_ultimate.amxx ;" >> /opt/hlds/cstrike/addons/amxmodx/configs/plugins.ini
RUN   echo "amx_parachute.amxx ;" >> /opt/hlds/cstrike/addons/amxmodx/configs/plugins.ini
RUN   echo "f_ultimate_sounds.amxx ;" >> /opt/hlds/cstrike/addons/amxmodx/configs/plugins.ini


# Cleanup
RUN apt remove -y curl

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
