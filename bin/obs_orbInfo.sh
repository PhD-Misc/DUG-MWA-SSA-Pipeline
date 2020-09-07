#!/bin/bash

usage()
{
echo "obs_orbInfo.sh [-o obsnum] [-a account] [-d dependancy]
        -a account		: account
        -d dependancy   : the dependant job id
        -o obsnum       : the obsid" 1>&2;
exit 1;
}

obsnum=
account="mwasci"
depJob=

while getopts 'o:a:d:' OPTION
do
    case "$OPTION" in
        d)
            depJob=${OPTARG}
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

# set the obsid to be the first non option
shift  "$(($OPTIND -1))"


# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi

if [[ -z ${depJob} ]]
then
    dep="--dependency=afterok:${depJob}"
else
    dep=""
fi

base=/astro/mwasci/sprabu/satellites/DUG-MWA-SSA-Pipeline/

script="${base}queue/orbInfo_${obsnum}.sh"
cat ${base}/bin/orbInfo.sh  > ${script}
output="${base}queue/logs/orbInfo_${obsnum}.o%A"
error="${base}queue/logs/orbInfo_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} ${script} -o ${obsnum} -b ${base}"
jobid=($(${sub}))
jobid=${jobid[3]}

## rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitter orbInfo job as ${jobid}"



