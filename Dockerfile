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
RUN echo "linux addons/podbot/podbot_mm_i386.so" > opt/hlds/cstrike/addons/metamod/plugins.ini


# Install AMX mod X
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-base-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
RUN curl -sqL "http://www.amxmodx.org/release/amxmodx-$amxmod_version-cstrike-linux.tar.gz" | tar -C /opt/hlds/cstrike/ -zxvf -
ADD files/maps.ini /opt/hlds/cstrike/addons/amxmodx/configs/maps.ini

# Add CSDM
RUN mkdir -p /opt/hlds/cstrike/addons/amxmodx/configs/csdm
ADD csdm/* /opt/hlds/cstrike/addons/amxmodx/configs/csdm/

COPY csdm.cfg /opt/hlds/cstrike/addons/amxmodx/configs/
COPY plugins-csdm.ini /opt/hlds/cstrike/addons/amxmodx/configs/

COPY csdm_amxx_i386.so /opt/hlds/cstrike/addons/amxmodx/modules/
COPY csdm_amxx.dll /opt/hlds/cstrike/addons/amxmodx/modules/
RUN mkdir -p /opt/hlds/cstrike/addons/amxmodx/modules/src
ADD src/* /opt/hlds/cstrike/addons/amxmodx/modules/src/


COPY csdm_equip.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_ffa.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_itemmode.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_main.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_misc.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_protection.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_spawn_preset.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_stripper.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/
COPY csdm_tickets.amxx /opt/hlds/cstrike/addons/amxmodx/plugins/

RUN mkdir -p /opt/hlds/cstrike/addons/amxmodx/scripting
ADD scripting/* /opt/hlds/cstrike/addons/amxmodx/scripting/


# Cleanup
RUN apt remove -y curl

WORKDIR /opt/hlds

ENTRYPOINT ["/bin/hlds_run.sh"]
