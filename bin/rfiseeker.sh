#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus  
#SBATCH -p knlq 
#SBATCH --time=10:00:00
#SBATCH --ntasks=28
#SBATCH --mem=40GB
#SBATCH -J RFISeeker
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`

set -x
{

module load python/3.6.3

obsnum=OBSNUM
base=BASE
timeSteps=
channels=

while getopts 's:f:' OPTION
do
    case "$OPTION" in
        s)
            timeSteps=${OPTARG}
            ;;
        f)
            channels=${OPTARG}
            ;;
    esac
done

datadir=${base}processing/${obsnum}
cd ${datadir}

# the below scipt parrallel spaws 28 python scipts on the requested 28 cores. 
for q in $(seq ${timeSteps})
do
  while [[ $(jobs | wc -l) -ge 28 ]]
  do
    wait -n $(jobs -p)
  done
  RFISeeker --obs ${obsnum} --freqChannels ${channels} --seedSigma 6 --floodfillSigma 1 --timeStep ${q} --prefix 6Sigma1Floodfill --DSNRS=False --imgSize 1400&

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
