#!/bin/sh

AVERAGE_PARAMETER=10

apt update > /dev/null 2>&1
apt install sysbench bc -y > /dev/null 2>&1

echo "# $(hostname)"
echo
echo "## info"
echo
echo "- cpuinfo"
echo
echo '```'
echo "# cat /proc/cpuinfo"
cat /proc/cpuinfo
echo '```'
echo
echo "- memory"
echo
echo '```'
echo "# free"
free
echo '```'
echo
echo "- disk"
echo
echo '```'
echo "# df -h"
df -h
echo '```'
echo
echo "- 0: SSD, 1: HDD"
echo
echo '```'
echo "# cat /sys/block/sda/queue/rotational"
cat /sys/block/sda/queue/rotational
echo '```'
echo
echo "## bench"
echo
echo "- bench cpu (thread 1)"
echo
echo '```'
echo "# sysbench --test=cpu --num-threads=1 run"
sysbench --test=cpu --num-threads=1 run
echo '```'
echo
echo "- bench cpu (thread 4)"
echo
echo '```'
echo "# sysbench --test=cpu --num-threads=4 run"
sysbench --test=cpu --num-threads=4 run
echo '```'
echo
echo "- bench cpu (thread 64)"
echo
echo '```'
echo "# sysbench --test=cpu --num-threads=64 run"
sysbench --test=cpu --num-threads=64 run
echo '```'
echo
echo "- bench memory (thread 1)"
echo
echo '```'
echo "# sysbench --test=memory --num-threads=1 run"
sysbench --test=memory --num-threads=1 run
echo '```'
echo
echo "- bench memory (thread 4)"
echo
echo '```'
echo "# sysbench --test=memory --num-threads=4 run"
sysbench --test=memory --num-threads=4 run
echo '```'
echo
echo "- bench random Read/Write (thread 1)"
echo
echo '```'
echo "# sysbench --test=fileio --file-test-mode=rndrw --num-threads=1 run"
sysbench --test=fileio --file-test-mode=rndwr --num-threads=1 run > /dev/null 2>&1
sysbench --test=fileio --file-test-mode=rndrw --num-threads=1 run
echo '```'
echo
echo "- bench random Read/Write (thread 4)"
echo
echo '```'
echo "# sysbench --test=fileio --file-test-mode=rndrw --num-threads=4 run"
sysbench --test=fileio --file-test-mode=rndrw --num-threads=4 run
echo '```'
echo
echo "## bench * $AVERAGE_PARAMETER average"
echo
echo "- cpu: execution total time (thread 1)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=cpu --num-threads=1 run | grep "total time:" | awk '{print $3}' | sed "s/s//g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) sec"
echo
echo "- cpu: execution total time (thread 4)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=cpu --num-threads=4 run | grep "total time:" | awk '{print $3}' | sed "s/s//g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) sec"
echo
echo "- cpu: execution total time (thread 64)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=cpu --num-threads=64 run | grep "total time:" | awk '{print $3}' | sed "s/s//g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) sec"
echo
echo  "- memory: transferred mbps (thread 1)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=memory --num-threads=1 run | grep "transferred" | awk '{print $4}' | sed "s/(//g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) MB"
echo
echo  "- memory: transferred mbps (thread 4)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=memory --num-threads=4 run | grep "transferred" | awk '{print $4}' | sed "s/(//g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) MB"
echo
echo  "- diskI/O (random Read/Write): transferred mbps (thread 1)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=fileio --file-test-mode=rndrw --num-threads=1 run| grep "transferred" | awk '{print $8}' | sed "s/(\(.*\)M.*$/\1/g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) Mb"
echo
echo  "- diskI/O (random Read/Write): transferred mbps (thread 4)"
COUNT=0
for i in $(seq 1 $AVERAGE_PARAMETER); do
  COUNT=$(echo "$COUNT + $(sysbench --test=fileio --file-test-mode=rndrw --num-threads=4 run| grep "transferred" | awk '{print $8}' | sed "s/(\(.*\)M.*$/\1/g")" | bc)
done
echo "    - $(echo "$COUNT / $AVERAGE_PARAMETER" | bc -l) Mb"
sysbench --test=fileio cleanup > /dev/null 2>&1
echo
