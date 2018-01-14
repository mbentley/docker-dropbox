mbentley/dropbox
================

docker image for Dropbox based off of debian:stretch

To pull this image:
`docker pull mbentley/dropbox`

Example usage:
```
docker run -d \
  --name dropbox \
  --net=host \
  -e DBOX_USERNAME=default \
  -e DBOX_GROUP=default \
  -e DBOX_UID=1000 \
  -e DBOX_GID=1000 \
  -v /data/dropbox:/home/default/Dropbox \
  -v /data/dropbox-config:/home/default/.dropbox \
  mbentley/dropbox
```

You *must* use volumes for `~/.dropbox` and `~/Dropbox` otherwise you will see data corruption every time Dropbox starts.

Startup environment variables:
  * `DBOX_USERNAME` - (default: `default`) username to use inside the container
  * `DBOX_GROUP` - (default: `default`) group name to use inside the container
  * `DBOX_UID` - (default: `1000`) UID of the new user inside the container; this is important if you want to have the UID outside the container match inside
  * `DBOX_GID` - (default: `1000`) GID of the new user's group inside the container; this is important if you want to have the GID outside the container match inside
