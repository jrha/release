#!/bin/bash 

usage () {
  echo ""
  echo "Usage: $(basename $0) [--list|--force] release_number"
  exit 1
}

list_release_rpms=0
force=0

while [ -n "`echo $1 | grep '^--'`" ]
do
  case $1 in
  --force)
        force=1
        ;;

  --list)
        list_release_rpms=1
        ;;

  esac

  shift
done

if [ -z "$1" ]
then
  echo "Error: no release specified"
  usage
fi

release=$1

release_dir=/var/www/yum-quattor/${release}
nexus_dir=/var/lib/sonatype-work/nexus/storage/quattor-releases/

if [ ${list_release_rpms} -eq 0 ]
then
  if [ -d ${release_dir} -a ${force} -eq 0 ]
  then
    echo "Error: release already exists. Use --force to proceed anyway."
    exit 2
  else
    mkdir -p ${release_dir}
  fi
fi

cd ${release_dir}

release_rpms=$(find ${nexus_dir} -name \*${release}\*.rpm)

if [ ${list_release_rpms} -eq 1 ]
then
  echo "===== List of RPMs in release ${release} ====="
  echo
fi 

for filename in ${release_rpms}
do
  pkgname=`rpm -qp --qf "%{N}-%{V}-%{R}.%{ARCH}.rpm" ${filename}`
  if [ ${list_release_rpms} -eq 1 ]
  then
    echo ${pkgname}
  else
    cp ${filename} ${pkgname}
  fi
done

if [ ${list_release_rpms} -eq 0 ]
then
  createrepo .
fi 



