#!/bin/bash --login
#$ -l h_rt=700000
#$ -j y
#$ -m a
#$ -o ./logfile/logfile_$JOB_NAME.log
#$ -cwd
#$ -pe mp 6
#$ -l mem_free=4G
#$ -l cpuflag_avx2=1
#$ -N network-opt

date
hostname

source venv/bin/activate
module add java/17

jar="matsim-berlin-6.x-SNAPSHOT.jar"
input="input/*"
network="network.xml.gz"
ft="network-ft.csv.gz"

command="java -cp ${jar} org.matsim.prepare.network.FreeSpeedOptimizer ${input} --network ${network} --input-features ${ft}"

echo ""
echo "command is $command"
echo ""

$command &

echo "Waiting to launch on 9090..."

while ! nc -z localhost 9090; do
  sleep 0.5
done

export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python

python3.9 -u -m matsim.scenariogen network-opt-freespeed