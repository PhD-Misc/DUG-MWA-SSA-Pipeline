#! /bin/bash -l
#SBATCH --export=NONE
#SBATCH -M zeus
#SBATCH -p workq
#SBATCH --time=6:00:00
#SBATCH --ntasks=28
#SBATCH --mem=124GB
#SBATCH -J lrimage
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com

start=`date +%s`

source /group/mwa/software/module-reset.sh
module load singularity


set -x
{

mem=115

obsnum=OBSNUM
base=BASE
timeSteps=
channels=767
while getopts 't:s:f:' OPTION
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

timeSteps=$((timeSteps+1))
datadir=${base}processing/${obsnum}
cd ${datadir}


for g in `seq 0 ${timeSteps}`;
do
	i=$((g*1))
	j=$((i+1))

	for f in `seq 0 ${channels}`;
	do
		f1=$((f*1))
		f2=$((f+1))

		while [[ $(jobs | wc -l) -ge 28 ]]
		do
			wait -n $(jobs -p)
		done

		mkdir temp_${g}_${f1}
		name=`printf %04d $f`
		singularity exec /pawsey/mwa/singularity/wsclean/wsclean_2.9.2.img wsclean -quiet\
		        -name ${obsnum}-2m-${i}-${name} -size 1400 1400 -temp-dir temp_${g}_${f1} \
				-abs-mem ${mem} -interval ${i} ${j} -channel-range ${f1} ${f2}\
				-weight natural -scale 5amin -abs-mem 30 ${obsnum}.ms &

	done
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

for ((k=0 ; k<10; k++))
do
	rm *${k}-image.fits
done

rm -r temp*
rm ${obsnum}.metafits
rm *.zip
rm *gpubox*

end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"


}

