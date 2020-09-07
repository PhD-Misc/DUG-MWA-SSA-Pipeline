#!/bin/bash  
#SBATCH --export=NONE
#SBATCH -M zeus
#SBATCH -p workq
#SBATCH --time=16:00:00
#SBATCH --ntasks=12
#SBATCH --mem=20GB
#SBATCH -J satSearch
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user sirmcmissile47@gmail.com
#SBATCH -q high

start=`date +%s`

module load python/3.6.3

set -x

{

obsnum=OBSNUM
base=BASE
datadir=${base}processing/${obsnum}
cd ${datadir}

## clear up files

for ((i=0;i<10;i++));
do
    rm *${i}-image.fits
done

## run sat search and run dep jobs

satSearch.py --obs ${obsnum} --t1 1 --t2 55 --user "steverajprabu@gmail.com" --passwd "Qwertyuiop1234567890" --debug=True

Tvar=$(<t.txt)
array1=(`echo $Tvar | sed 's/ /\n/g'`)
array=()
for m in "${array1[@]}";
do
    if [[ ! " ${array[@]} " =~ ${m} ]];
    then
        array+=(${m})
    fi

    n=$((m+1))
    if [[ ! " ${array[@]} " =~ ${n} ]];
    then
        array+=(${n})
    fi

    p=$((m-1))
    if [[ ! " ${array[@]} " =~ ${p} ]];
    then
        array+=(${p})
    fi
done



## submit high angular resolution jobs

# cd ${base}
# channels=768
# job_array=""
# #for q in "${array[@]}";
# for q in $(seq 55)
# do

#    # submit job for timestep 
#    script="${base}queue/args_hrimage_${obsnum}_timeStep${q}.sh"
#    cat ${base}bin/arg_hrimage.sh > ${script}
#    output="${base}queue/logs/args_hrimage_${obsnum}_timeStep${q}.o%A"
#    error="${base}queue/logs/args_hrimage_${obsnum}_timeStep${q}.e%A"
#    sub="sbatch --begin=now+15 --output=${output} --error=${error} -A pawsey0345 ${script} -o ${obsnum} -b ${base} -t ${q}"
#    jobid=($(${sub}))
#    jobid=${jobid[3]}

#    # rename the err/output files as we now know the jobid
#    error=`echo ${error} | sed "s/%A/${jobid}/"`
#    output=`echo ${output} | sed "s/%A/${jobid}/"`
#    job_array=${job_array}:${jobid}

# done
#
#echo "the dependent job arrray is " ${job_array:1}

## submit jobs for obrinfo
 

## submit jobs to clear files

end=`date +%s`
runtime=$((end-start))
echo "the job run time ${runtime}"

}
