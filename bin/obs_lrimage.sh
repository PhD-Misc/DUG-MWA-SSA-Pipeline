#!/bin/bash

usage()
{
echo "obs_lrimage.sh [-o obsnum] [-a account] [-t timeStep]
        -a account              : pawsey Account to use
        -t timeSteps            : the number of timeSteps in ms, default=55
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

account="mwasci"
timeSteps=55
obsnum=


while getopts 'o:a:t:' OPTION
do
    case "$OPTION" in
        t)
            timeSteps=${OPTARG}
            ;;
        o)
            obsnum=${OPTARG}     
            ;;
        a)
            account=${OPTARG}
            ;;
        ? | : | h)
            usage
            ;;
    esac
done

# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi

base=/astro/mwasci/sprabu/satellites/DUG-MWA-SSA-Pipeline/

## run low res imaging ##
script="${base}queue/lrimage_${obsnum}.sh"
cat ${base}/bin/lrimage.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/lrimage_${obsnum}.o%A"
error="${base}queue/logs/lrimage_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account}  ${script} -s ${timeSteps} -f ${channels}"
jobid=($(${sub}))
jobid=${jobid[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitted lrimage job as ${jobid}"

