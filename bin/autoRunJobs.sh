#!/bin/bash

usage()
{
echo "autoSubmitJobs.sh [-c calibration] [-o obsnum] [-a account] [-f channels] [-s timeSteps] [-d download link]
        -c calibration          : path to calibration solution
        -a account              : pawsey Account to use
        -f channels             : the number of channels in ms, default=768
        -s timeSteps            : the number of timeSteps in ms, default=56
        -d download link        : the ASVO link to download observation
        -o obsnum               : the obsid" 1>&2;
exit 1;
}

calibrationPath=
account="mwasci"
channels=768
timeSteps=55
obsnum=
link=

while getopts 'c:o:a:f:s:d:' OPTION
do
    case "$OPTION" in
        d)
            link=${OPTARG}
            ;;
        f)
            channels=${OPTARG}
            ;;
        s)
            timeSteps=${OPTARG}
            ;;
        c)
            calibrationPath=${OPTARG}
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

### submit the download job 
script="${base}queue/asvo_${obsnum}.sh"
cat ${base}bin/asvo.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/asvo_${obsnum}.o%A"
error="${base}queue/logs/asvo_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} ${script} -l ${link} "
jobid0=($(${sub}))
jobid0=${jobid0[3]}

echo "Submitted asvo job as ${jobid0}"

## run cotter ##
script="${base}queue/cotter_${obsnum}.sh"
cat ${base}/bin/cotter.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/cotter_${obsnum}.o%A"
error="${base}queue/logs/cotter_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} --dependency=afterok:${jobid0} -A ${account} ${script} -c ${calibrationPath} "
jobid1=($(${sub}))
jobid1=${jobid1[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid1}/"`
output=`echo ${output} | sed "s/%A/${jobid1}/"`

echo "Submitted cotter job as ${jobid1}"


## run low res imaging ##
script="${base}queue/lrimage_${obsnum}.sh"
cat ${base}/bin/lrimage.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/lrimage_${obsnum}.o%A"
error="${base}queue/logs/lrimage_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} --dependency=afterok:${jobid1} -A ${account}  ${script} -s ${timeSteps} -f ${channels}"
jobid2=($(${sub}))
jobid2=${jobid2[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid2}/"`
output=`echo ${output} | sed "s/%A/${jobid2}/"`

echo "Submitted lrimage job as ${jobid2}"



## run RFISeeker ##
script="${base}queue/rfiseeker_${obsnum}.sh"
cat ${base}/bin/rfiseeker.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/rfiseeker_${obsnum}.o%A"
error="${base}queue/logs/rfiseeker_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} --dependency=afterok:${jobid2} ${script} -s ${timeSteps} -f ${channels}"
jobid3=($(${sub}))
jobid3=${jobid3[3]}
### rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid3}/"`
output=`echo ${output} | sed "s/%A/${jobid3}/"`
echo "Submitted RFISeeker job as ${jobid3}"


# ## run satSeach job ##
# script="${base}queue/satSearch_${obsnum}.sh"
# cat ${base}/bin/satSearch.sh | sed -e "s:OBSNUM:${obsnum}:g" \
#                                  -e "s:BASE:${base}:g" > ${script}
# output="${base}queue/logs/satSearch_${obsnum}.o%A"
# error="${base}queue/logs/satSearch_${obsnum}.e%A"
# sub="sbatch --begin=now+15 --output=${output} --error=${error} -A ${account} --dependency=afterok:${jobid3} ${script}"
# jobid4=($(${sub}))
# jobid4=${jobid4[3]}
# ## rename the err/output files as we now know the jobid
# error=`echo ${error} | sed "s/%A/${jobid4}/"`
# output=`echo ${output} | sed "s/%A/${jobid4}/"`

# echo "Submitter satSearch job as ${jobid4}"



