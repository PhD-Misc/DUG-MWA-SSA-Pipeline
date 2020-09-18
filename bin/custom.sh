#! /bin/bash -l
#SBATCH --export=NONE 
#SBATCH -p workq
#SBATCH --time=00:40:00
#SBATCH --ntasks=4
#SBATCH --mem=6GB
#SBATCH -J custom
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


# ## combine data and make it into a vo table
# combinedMeasurements.py --t1 1 --t2 55 --obs ${obsnum} --prefix 6Sigma1Floodfill --hpc pawsey

# cp ${obsnum}-pawsey-measurements.fits /astro/mwasci/sprabu/rfiseekerLog
timeLapse.py --obs ${obsnum} --t1 1 --t2 55 --user ${spaceTrackUser} --passwd ${spaceTrackPassword} --prefix 6Sigma1Floodfill


end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"


}
