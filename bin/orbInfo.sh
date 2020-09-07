#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus  
#SBATCH -p workq 
#SBATCH --time=12:00:00
#SBATCH --ntasks=28
#SBATCH --mem=120GB
#SBATCH -J OrbInfo
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`

set -x
{

module load python/3.6.3

obsnum=
base=
timeSteps=55
channels=768


while getopts 'o:b:' OPTION
do
    case "$OPTION" in
        o)
            obsnum=${OPTARG}
            ;;
        b)
            base=${OPTARG}
            ;;
    esac
done

datadir=${base}processing/${obsnum}
cd ${datadir}


## get timeSteps
Tvar=$(<t.txt)
array=(`echo $Tvar | sed 's/ /\n/g'`)

# extract heads
# the below scipt parrallel spaws 28 python scipts on the requested 28 cores. 
#for q in "${array[@]}";
for q in $(seq 55)
do
  while [[ $(jobs | wc -l) -ge 28 ]]
  do
    wait -n $(jobs -p)
  done
  RFISeeker --obs ${obsnum} --freqChannels ${channels} --seedSigma 6 --floodfillSigma 1 --timeStep ${q} --prefix 6Sigma1Floodfilllr14 --DSNRS=False --debug=True --imgSize 1400&

done

i=0
for job in `jobs -p`
do
        pids[${i}]=${job}
        i=$((i+1))
done
for pid in ${pids[*]}; do
        wait ${pid}
done


# extract tails
#for q in "${array[@]}";
for q in $(seq 55)
do
  while [[ $(jobs | wc -l) -ge 28 ]]
  do
    wait -n $(jobs -p)
  done
  RFISeeker --obs ${obsnum} --freqChannels ${channels} --seedSigma 6 --floodfillSigma 1 --timeStep $((q+1)) --prefix 6Sigma1Floodfilllr14 --DSNRS=False --streak Tail --debug=True --imgSize 1400&

done

i=0
for job in `jobs -p`
do
        pids[${i}]=${job}
        i=$((i+1))
done
for pid in ${pids[*]}; do
        wait ${pid}
done






end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"


}
