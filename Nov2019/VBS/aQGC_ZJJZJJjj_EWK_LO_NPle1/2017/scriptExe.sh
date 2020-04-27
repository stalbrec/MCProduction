#!/bin/bash
echo "================= CMSRUN starting jobNum=$1 ====================" | tee -a job.log

lsb_release -a 

echo "================= CURL GRIDPACK ===================="| tee -a job.log
curl --insecure https://salbrech.web.cern.ch/salbrech/gridpacks/aQGC_ZJJZJJjj_EWK_LO_NPle1_slc6_amd64_gcc630_CMSSW_9_3_16_tarball.tar.xz --retry 2 -o ./aQGC_ZJJZJJjj_EWK_LO_NPle1_slc6_amd64_gcc630_CMSSW_9_3_16_tarball.tar.xz

ls -ltr 

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc530

BASE=$PWD

echo "================= CMSRUN setting up CMSSW_9_3_1 ===================="| tee -a job.log
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_9_3_1/src ] ; then 
     echo release CMSSW_9_3_1 already exists
 else
     scram p CMSSW CMSSW_9_3_1
 fi
 cd CMSSW_9_3_1/src
 eval `scram runtime -sh`

cd $BASE
echo "================= CMSRUN starting Step 1 ====================" | tee -a job.log
cmsRun -j GenSimAODSim_step1.log step1.py jobNum=$1

echo "================= CMSRUN setting up CMSSW_9_4_0_patch1 ===================="| tee -a job.log

if [ -r CMSSW_9_4_0_patch1/src ] ; then 
    echo release CMSSW_9_4_0_patch1 already exists
else
    scram p CMSSW CMSSW_9_4_0_patch1
fi
cd CMSSW_9_4_0_patch1/src
eval `scram runtime -sh`

cd $BASE

echo "================= CMSRUN starting Step 2 ====================" | tee -a job.log
cmsRun -j GenSimAODSim_step2.log step2.py 

echo "================= CMSRUN starting Step 3 ====================" | tee -a job.log
cmsRun -j Reco_step3.log step3.py 


echo "================= CMSRUN setting up CMSSW_9_4_9 ===================="| tee -a job.log
export SCRAM_ARCH=slc6_amd64_gcc630
if [ -r CMSSW_9_4_9/src ] ; then 
    echo release CMSSW_9_4_9 already exists
else
    scram p CMSSW CMSSW_9_4_9
fi
cd CMSSW_9_4_9/src
eval `scram runtime -sh`


scram b
cd ../../
cd $BASE

echo "================= CMSRUN starting Step 4 ====================" | tee -a job.log
#cmsRun -j MiniAODSim_Step2.log Step2.py 
cmsRun -e -j FrameworkJobReport.xml step4.py 

echo "================= CMSRUN finished ====================" | tee -a job.log

ls -ltr | tee -a job.log
