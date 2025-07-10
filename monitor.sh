#!/bin/bash

# Architecture
arch=$(uname -a)

# Physical CPUs qty
physical_cpu=$(grep "physical id" /proc/cpuinfo | wc -l)

# Virtual CPUs
virtual_cpu=$(grep processor /proc/cpuinfo | wc -l)

# RAM
total_ram=$(free --mega | awk '$1 == "Mem:" {print $2}')
used_ram=$(free --mega | awk '$1 == "Mem:" {print $3}')
ram_percentage=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk usage
disk_size=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{d_size += $2} END {printf("%.1f GB\n"), d_size/1024}')
disk_usage=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{d_usage += $3} END {print d_usage}')
disk_percentage=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{used += $3} {total += $2} END {printf("(%.2f%%)\n", used/total*100)}')

# CPU load
cpu_load=$(vmstat 1 2 | tail -1 | awk '{print $15'})
cpu_op=$(expr 100 - $cpu_load)
cpu_fin=$(printf "%.1f" $cpu_op)

# Last Boot
last_boot=$(who -b | awk '{print $4 " - " $5}')

# Is LVM in use?
lvm_used=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo Yes; else echo No; fi)

# TCP Connections
tcp_conn=$(ss -ta | grep ESTAB | wc -l)

# Users logged in
users_logged=$(users | wc -w)

# Network info
ip=$(hostname -I | awk '{print $1}')
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# SUDO commands
cmm=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

wall "  Architecture:   $arch
        CPU Sockets:    $physical_cpu
        Virtual CPU:    $virtual_cpu
        Memory Usage:   $used_ram/${total_ram}MB ($ram_percentage)
        Disk Usage:     $disk_usage/${disk_size} ($disk_percent%)
        CPU load:       $cpu_fin%
        Last Boot:      $last_boot
        LVM Used:       $lvm_used
        TCP Conn:       $tcp_conn ESTABLISHED
        Users Logged:   $users_logged
        Network Info:   IP $ip - MAC $mac
        Sudo count:     $cmm commands"