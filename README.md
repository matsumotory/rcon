# rcon [![Build Status](https://travis-ci.org/matsumoto-r/rcon.svg?branch=master)](https://travis-ci.org/matsumoto-r/rcon)

rcon is a lightweight resource virtualization tool for linux processes. rcon is one-binary.

## build

- require
  - libcgroup

```
rake
cp -p mruby/bin/rcon /path/to/bin-dir/.
```

## build packages

Create release binary considering glibc versions using Docker.

```
rake package
ls -l pkg/
```

## usage
```
 ./rcon --help
Usage: rcon [options] --user username --command "yes >> /dev/null"
    --cpu VAL
      default: 30 (%)
    --memory VAL
      default: 512000000 (Byte)
    --read VAL
      default: 10485760 (Byte/sec)
    --write VAL
      default: 10485760 (Byte/sec)
    --group VAL
      default: rcon
    --dev VAL
      default: 8:0
    --pids VAL
      default: nothing
    --version
```

## cpu example

#### no limit

- command
```
yes >> /dev/null
```

- cpu usage
```
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
27577 matsumot  20   0 98.5m  608  520 R 100.0  0.0   0:01.95 yes 
```

#### limitting cpu 10%

- command
```
sudo ./rcon --user matsumotory --command "yes >> /dev/null" --cpu 10
```

- cpu usage limitted 10% by rcon
```
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
23941 matsumot  20   0 98.5m  604  520 R  9.6  0.0   0:00.63 yes
```

### limitting already running process to cpu 30%

- command
```
yes >> /dev/null &
yes >> /dev/null &
sudo ./rcon --pids "`pgrep yes`"
```

- cpu usage
```
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND 
22531 vagrant   20   0 98.5m  612  524 R 15.6  0.0   0:16.16 yes
22532 vagrant   20   0 98.5m  612  524 R 14.3  0.0   0:15.47 yes
```

__Notice: pids optsion don't delete groups after running process was finished__

## io example

#### no limit

- command 
```
dd if=/dev/zero of=tempfile bs=1M count=1000 oflag=direct
```

- io usage
```
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
27569 be/4 matsumot    0.00 B/s   22.09 M/s  0.00 % 95.93 % dd if=/dev/zero of=tempfile bs=1M count=1000 oflag=direct
```

#### limitting write io 1MByte/sec

- command
```
sudo ./rcon --user matsumotory --command "dd if=/dev/zero of=tempfile bs=1M count=1000 oflag=direct" --write 1024000
```

- io usage limitted 1MByte/sec by rcon
```
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
24676 be/4 matsumot    0.00 B/s  995.77 K/s  0.00 % 99.99 % dd if=/dev/zero of=tempfile bs=1M count=1000 oflag=direct  
```

- find io dev id (--dev)
```
$ ls -l /dev/xvda | awk '{print $5 $6}' | sed 's/,/:/'
202:0
```

for `--dev` option. default `8:0`.
