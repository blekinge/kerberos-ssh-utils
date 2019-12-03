#!/usr/bin/env bash

#Get the custom conda installer
wget https://repo.continuum.io/archive/Anaconda3-2019.03-Linux-ppc64le.sh

# Run it
bash Anaconda3-2019.03-Linux-ppc64le.sh -p $LOCALHOME/anaconda3

#source the result
source ~/.bashrc

#Set conda to use strict channel_priority to ensure that the WML CE channel is always used when packages of the same name exist in other channels.
conda config --set channel_priority strict

#Pin the conda package (within Anaconda) to a known good version of conda tested with WML CE:
echo "conda=4.6.11" >> $LOCALHOME/anaconda3/conda-meta/pinned


#In some instances, the Anaconda environment can incorrectly select a package from the general free channel instead of the higher priority WML CE channel, potentially causing an undesired package variant to be installed. You can avoid this action by overriding the Anaconda default_channel by running the following config commands:
conda config --add default_channels https://repo.anaconda.com/pkgs/main
conda config --add default_channels https://repo.anaconda.com/pkgs/r


#If using Anaconda3 the base environment is Python 3.7, which is not supported with WML CE.
conda install python=3.6


#The WML CE MLDL packages are distributed as conda packages in an online conda repository. conda must be configured to give priority to installing packages from this channel.
#Add the WML CE channel to the conda configuration by running the following command:
conda config --prepend channels \
https://public.dhe.ibm.com/ibmdl/export/pub/software/server/ibm-ai/conda/


echo "For example, to create an environment named wmlce_env with Python 3.6:"
echo "conda create --name wmlce_env python=3.6"
echo "conda activate wmlce_env"

echo "All the MLDL frameworks can be installed at the same time by using the powerai meta-package"
echo "conda install powerai"


#For at få tensorflow-test til at virke, se https://github.com/openssl/openssl/issues/10015 og
conda install openssl=1.1.1c


echo 'if ! echo $LD_LIBRARY_PATH | $GREP -q $CONDA_PREFIX/lib; then
LD_LIBRARY_PATH=$LD_LIBRARY_PATH${LD_LIBRARY_PATH:+:}$CONDA_PREFIX/lib
fi
export LD_LIBRARY_PATH
' > $LOCALHOME/anaconda3/envs/tf/etc/conda/activate.d/activate-tensorflow-extra.sh


echo 'path_remove() {
  local LPATH=$1
  if [[ ! -z "$LPATH" && ! -z "$2" ]]; then
    if echo $LPATH | $GREP -q $2; then
      LPATH=${LPATH//":$2:"/":"} # Delete any instance in the middle
      LPATH=${LPATH/#"$2:"/} # Delete any instance at the beginning
      LPATH=${LPATH/%":$2"/} # Delete any instance at the end
      if [[ $LPATH == "$2" ]]; then
        LPATH=""
      fi
    fi
  fi
  echo "$LPATH"
}

SYS_PYTHON_MAJOR=$(python -c "import sys;print(sys.version_info.major)")
SYS_PYTHON_MINOR=$(python -c "import sys;print(sys.version_info.minor)")
COMPONENT="tensorflow"
TF_PKG_PATH=${CONDA_PREFIX}/lib/python${SYS_PYTHON_MAJOR}.${SYS_PYTHON_MINOR}/site-packages/$COMPONENT
GREP=`type -P grep`

LD_LIBRARY_PATH=$(path_remove $LD_LIBRARY_PATH $TF_PKG_PATH)
if [ ! -z "$LD_LIBRARY_PATH" ]; then
  export LD_LIBRARY_PATH
else
  unset LD_LIBRARY_PATH
fi
'

#Conda kan have issues med din ~/.local folder. Lettest bare at fjerne den