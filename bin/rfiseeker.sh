#! /bin/bash -l
#SBATCH --export=NONE 
#SBATCH -p workq
#SBATCH --time=10:00:00
#SBATCH --ntasks=28
#SBATCH --mem=40GB
#SBATCH -J RFISeeker
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`

set -x
{

#module load python/3.6.3
module load singularity

obsnum=OBSNUM
base=BASE
timeSteps=
channels=
neg="0"

while getopts 's:f:n:' OPTION
do
    case "$OPTION" in
        s)
            timeSteps=${OPTARG}
            ;;
        f)
            channels=${OPTARG}
            ;;
        n)
            neg="1"
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
  singularity exec /astro/mwasci/sprabu/singularity_images/rfiseeker_1.0-build-1.sif RFISeeker --obs ${obsnum} --freqChannels ${channels} --seedSigma 6 --floodfillSigma 1 --timeStep ${q} --prefix 6Sigma1Floodfill --DSNRS=False --imgSize 1400&

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

if [[ "${neg}" != "1" ]]; then
  ## do rfiSeeker for the tail as well
  echo "running rfiseeker for tail as well...comming soon."
fi


## combine data and make it into a vo table
combinedMeasurements.py --t1 1 --t2 55 --obs ${obsnum} --prefix 6Sigma1Floodfill --hpc pawsey

cp ${obsnum}-pawsey-measurements.fits /astro/mwasci/sprabu/rfiseekerLog


end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"


}
