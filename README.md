## quick guide to build neutrino (mp) for PC (x86) ##

```bash
$:~ git clone https://github.com/mohousch/nmp-pc.git
```
```bash
$:~ cd nmp-pc
```

* check preqs (debian):
```bash
$:~ sudo bash prepare-for-nmp-pc.sh
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
or make
```

* step 3:
```bash
$:~ make run
```

* if you want to choose other neutrino flavour start again with step 1

## updating source ##
```bash
$:~ make update
```

* then start with step 2

## clean build ##
```bash
$:~ make clean
```








