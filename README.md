## quick guide to build neutrino (mp) for PC (x86) ##

* check preqs (debian):

```bash
$:~ sudo apt-get install autoconf libtool libtool-bin g++ gdb libavformat-dev libswscale-dev libswresample-dev libao-dev libopenthreads-dev libglew-dev freeglut3-dev libcurl4-gnutls-dev libfreetype6-dev libid3tag0-dev libmad0-dev libogg-dev libpng12-dev libgif-dev libjpeg-dev libvorbis-dev libsigc++-2.0-dev libflac-dev libblkid-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev libfribidi-dev libass-dev python-dev lua5.2 lua5.2-dev lua-json lua-expat lua-posix lua-socket lua-soap lua-curl clutter-1.0
```

```bash
$:~ git clone https://github.com/mohousch/nmp-pc.git
```
```bash
$:~ cd nmp-pc
```

* build lua:
```bash
$:~ make lua
```

* build ffmpeg:
```bash
$:~ make ffmpeg
```

* build libdvbsi:
```bash
$:~ make libdvbsi
```

* step 1:
```bash
$:~ make init
```

step 2:
```bash
$:~ make neutrino
```

* step 3:
```bash
$:~ make run
```

* if you want to choose other neutrino flavour:
```bash
$:~ make clean
```

* then start with step 1








