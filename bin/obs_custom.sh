#!/bin/bash

usage()
{
echo "custom.sh [-o obsnum] [-a account] [-m cluster]
        -a account 		: the account to process
        -m cluster      : the cluster to process data in, default=zeus
        -o obsnum       : the obsid" 1>&2;
exit 1;
}

account=
obsnum=
timeSteps=55
channels=768
cluster="zeus"



while getopts 'o:a:m' OPTION
do
    case "$OPTION" in
	a)
	    account=${OPTARG}
            ;;
    o)
        obsnum=${OPTARG}
            ;;
    m)
        cluster=${OPTARG}
            ;;
    ? | : | h)
            usage
            ;;
    esac
done

# set the obsid to be the first non option
shift  "$(($OPTIND -1))"

# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi

base=/astro/mwasci/sprabu/satellites/DUG-MWA-SSA-Pipeline/

## copy data ##
script="${base}queue/custom_${obsnum}.sh"
cat ${base}bin/custom.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/custom_${obsnum}.o%A"
error="${base}queue/logs/custom_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} -M ${cluster} ${script} -s ${timeSteps} -f ${channels} "
jobid=($(${sub}))
jobid=${jobid[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitter custom job as ${jobid}"
