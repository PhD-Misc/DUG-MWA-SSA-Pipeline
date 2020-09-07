#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus
#SBATCH -p workq
#SBATCH --time=10:00:00
#SBATCH --ntasks=28
#SBATCH --mem=122GB
#SBATCH -J arg_hrimage
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

source /group/mwa/software/module-reset.sh
module use /group/mwa/software/modulefiles
module load MWA_Tools/mwa-sci
module list

set -x
{

obsnum=
base=
timeStep=

while getopts 't:b:o:' OPTION
do
    case "$OPTION" in
        t)
            timeStep=${OPTARG}
            ;;
        b)
            base=${OPTARG}
            ;;
        o)
            obsnum=${OPTARG}
            ;;
    esac
done



datadir=${base}processing/${obsnum}
channels=768


cd ${datadir}

mem=115

#mkdir ${timeStep}

t1=$((timeStep*1))
t2=$((t1+1))

for f in `seq 0 767`;
do
    f1=$((f*1))
    f2=$((f+1))
    while [[ $(jobs | wc -l) -ge 28 ]]
    do
        wait -n $(jobs -p)
    done
    mkdir temp_${t1}_${f1}
    name=`printf %04d $f`
    wsclean -quiet -name ${obsnum}-2m-${t1}-${name} -size 5000 5000 -temp-dir temp_${t1}_${f1}\
            -abs-mem 4 --interval ${t1} ${t2} -channel-range ${f1} ${f2}\
            -weight natural  -scale 1.25amin  ${obsnum}.ms &
    
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


for ((i=0; i<10; i++));
do
    rm ${obsnum}-2m-${t1}-*${i}-image.fits
done


}

