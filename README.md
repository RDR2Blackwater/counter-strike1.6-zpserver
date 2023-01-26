# counter-strike1.6-zpserver
Based on the counter-strike1.6 image from [archont94](https://hub.docker.com/r/archont94/counter-strike1.6), this is a docker image a dedicated Counter-Strike 1.6 server with metamod, amxmodx, fast download, PodBot and ZPA plugins.

**About Usage**

*Solutions provided by [archont94](https://hub.docker.com/r/archont94/counter-strike1.6) can also be used in this image, so I'll just give some additional instructions here*

Pull this image with command

    docker pull handsomejeck/counter-strike1.6-zpserver

You may deploy this server easily by pulling the image down and run it like:

    docker run --name cs16-server -p 27015:27015/udp -p 27015:27015 -p 8803:80 handsomejeck/counter-strike1.6-zpserver:latest

*Note:I rewrote the fast download port as `8803`, you can change this port and modify the path in /hlds/cstrike/server.cfg after executing the contain*

But it is recommended to disable core dumps by using --ulimit core=0 before running.If not, every core dumps would be recorded in docker commit.

Recommended running:

    docker run --name cs16-server -p 27015:27015/udp -p 27015:27015 -p 8803:80 --ulimit core=0 handsomejeck/counter-strike1.6-zpserver:latest

or to write a docker-compose.yml like:

```
version: "3.3"
services:
    counter-strike1.6-zpserver:
        container_name: cs16-server
        ports:
            - 27015:27015/udp
            - 27015:27015
            - 8803:80
        ulimits:
            core: 0
        image: handsomejeck/counter-strike1.6-zpserver:latest
```

**About Server Configurations**

This server has added PodBot(Well, working badly in Counter-Strike1.6...) and would swap 20 Bots on server started. Bots can be modified in `/hlds/addons/podbot/podbot.cfg`.
Besides ZPA, some plugins like CSO Weapons were added as extra items, players could buy them via ZP buy menu.To disable plugins, add ";" before plugin lines in 
`/hlds/cstrike/addons/amxmodx/configs/plugins-zplague.ini`

To make any weapons affordable for every players, configuration file has been rewritten, you can customize the properties about ZPA in  
`/hlds/cstrike/addons/amxmodx/configs/zombie_plague_advance.cfg`

Server is using Build 8684, ReHLDS & reunion are required to support Protocol 47, if you do not want non-steam players to join, add ";" before `linux addons/reunion/reunion_mm_i386.so` in `/hlds/cstrike/addons/metamod/plugins.ini` to disable reunion.

**Dockerfile**

Most of Dockerfile about counter-strike1.6 server cannot work now due to improper configurations about SteamCMD, so I write a [Dockerfile][Dockerfile] as example.
