#!/bin/sh

./scripts/feeds update -a
./scripts/feeds install -a
make download
git checkout -- .config  
#如果自己在menuconfig中修改了配置，使用#把第6行注释掉再执行此脚本