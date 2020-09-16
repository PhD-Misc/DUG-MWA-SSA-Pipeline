#! /bin/bash -l
#BATCH --export=NONE
#SBATCH -p workq
#SBATCH --time=2:00:00
#SBATCH --ntasks=2
#SBATCH --mem=10GB
#SBATCH -J clear
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`

module load singularity


set -x 

{
obsnum=OBSNUM
base=BASE

datadir=${base}processing/${obsnum}

cd ${datadir}

for ((i=0;i<10;i++));
do
    rm *${i}-dirty.fits
done



end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"

}
