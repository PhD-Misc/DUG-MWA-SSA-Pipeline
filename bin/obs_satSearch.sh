#!/bin/bash

usage()
{
echo "obs_satSearch.sh [-o obsnum] [-a account]
        -a account		: account
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

obsnum=
account="mwasci"

while getopts 'o:a:' OPTION
do
    case "$OPTION" in
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


base=/astro/mwasci/sprabu/satellites/DUG-MWA-SSA-Pipeline/

script="${base}queue/satSearch_${obsnum}.sh"
cat ${base}/bin/satSearch.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/satSearch_${obsnum}.o%A"
error="${base}queue/logs/satSearch_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} ${script}"
jobid=($(${sub}))
jobid=${jobid[3]}

## rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid}/"`
output=`echo ${output} | sed "s/%A/${jobid}/"`

echo "Submitter satSearch job as ${jobid}"



