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

* step 1:
```bash
$:~ make libs
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

* then start with step 2

## clean build ##
```bash
$:~ make clean
```

```bash
$:~ make distclean
```








