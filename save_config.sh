#!/bin/sh
datetime=`date +%Y%m%d-%T`

mkdir ./tmp/config/${datetime}
cp .config ./tmp/config/${datetime}/config
cp build_dir/target-aarch64_generic_musl/linux-rockchip_armv8/linux-5.4.71/.config  ./tmp/config/${datetime}/kernel_config
echo 'save success'
