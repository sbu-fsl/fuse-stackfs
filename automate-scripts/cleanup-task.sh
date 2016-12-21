#!/bin/bash

umount /home/bvangoor/EXT4_FS
mkfs.ext4 -F -E  lazy_itable_init=0,lazy_journal_init=0 -O ^uninit_bg /dev/sdb > /dev/null
mount -t ext4 /dev/sdb /home/bvangoor/EXT4_FS/
