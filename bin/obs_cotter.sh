#!/bin/bash

usage()
{
echo "obs_cotter.sh [-o obsnum] [-a account] [-c calibrationSolution]
        -a account              : pawsey Account to use
        -c calibrationSolution  : the calibration solution to be used
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

account="mwasci"
calibration=
obsnum=


while getopts 'o:a:c:' OPTION
do
    case "$OPTION" in
        c)
            calibration=${OPTARG}
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

## run calibration job ##
script="${base}queue/cotter_${obsnum}.sh"
cat ${base}/bin/cotter.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/cotter_${obsnum}.o%A"
error="${base}queue/logs/cotter_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} ${script} -c ${calibration} "
jobid=($(${sub}))
jobid=${jobid[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitted cotter job as ${jobid}"

