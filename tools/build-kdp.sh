#!/bin/bash
#
# build-kdp.sh: Build scripts for All devices.
# Copyright (C) 2015 The KangDroid-Project
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#

usage() {
    echo -e "${bldblu}Usage:${bldcya}"
    echo -e "  build-kdp.sh [options] device"
    echo ""
	echo -e "${bldblu}  Options:${bldcya}"
	echo -e "	--prefix=#  Set Out directory"
	echo -e "	--clean=yes|no  Clean build before compile new rom(Default yes)"
	echo -e "	-j# set make jobs"
	echo -e "	--reset=yes|no  Reset repository before build(Default yes)"
	echo -e "	--sync=yes|no  Sync repository before build(Default yes)"
	echo -e "	--block=yes|no  no block update on ota zip.(Defualt NO)"
	echo -e "${bldblu}  Example:${bldcya}"
    echo -e "    ./build-kdp.sh --clean --reset --sync -j32 shamu"
}

# Figure out the output directories
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default Options
ARG_PREFIX_DIR=$DIR/out
ARG_CLEAN_OPT=yes
ARG_RESET_OPT=yes
ARG_SYNC_OPT=yes
ARG_BLOCK_OTA=no
ARG_JTHREAD_OPT=$(grep "^processor" /proc/cpuinfo -c)

# Check directories
if [ ! -d ".repo" ]; then
    echo -e "${bldred}No .repo directory found.  Is this an Android build tree?${rst}"
    echo ""
    exit 1
fi
if [ ! -d "vendor/kdp" ]; then
    echo -e "${bldred}No vendor/kdp directory found.  Is this a proper KDP build tree?${rst}"
    echo ""
    exit 1
fi

while [ $# -gt 0 ]; do
  ARG=$1
  ARG_PARMS="$ARG_PARMS '$ARG'"
  shift
  case "$ARG" in
    --prefix=*)
      ARG_PREFIX_DIR="${ARG#*=}"
      ;;
    --clean=yes | --clean=no)
      ARG_CLEAN_OPT="${ARG#*=}"
      ;;
    --reset=yes | --reset=no)
      ARG_RESET_OPT="${ARG#*=}"
      ;;
    --sync=yes | --sync=no)
      ARG_SYNC_OPT="${ARG#*=}"
      ;;
    --block=yes | --block=no)
      ARG_BLOCK_OTA="${ARG#*=}"
      ;;
    -j*)
      ARG_JTHREAD_OPT="${ARG#*=}"
      ;;
    *)
      error "Unrecognized parameter $ARG"
	  usage
      ;;
  esac
done

shift $((OPTIND-1))
if [ "$#" -ne 1 ]; then
    usage
fi
device="$1"

# Set Out directory
export OUT_DIR=${ARG_PREFIX_DIR}
echo "Out directory set to: ($ARG_PREFIX_DIR)"

# Cleaning options
if [ "x${ARG_CLEAN_OPT}" = "xyes" ]; then
	cd ${DIR}
	make -j${ARG_JTHREAD_OPT} clobber
fi

# Sync Repository
if [ "x${ARG_SYNC_OPT}" = "xyes" ]; then
	echo "Syncing repository"
	repo sync -j${ARG_JTHREAD_OPT}
fi

# Reset Repository
if [ "x${ARG_RESET_OPT}" = "xyes" ]; then
	echo "Resettings whole source tree."
	repo forall -c "git reset --hard HEAD; git clean -qf"
fi

# Starting build
echo "Starting build for ($device)"

if [ "x${ARG_BLOCK_OTA}" = "xyes" ]; then
	cd $DIR
	. build/envsetup.sh block
else
	cd $DIR
	. build/envsetup.sh
fi

lunch kdp_${device}-userdebug
mka bacon -j${ARG_JTHREAD_OPT}


