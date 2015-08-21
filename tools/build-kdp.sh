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
	echo -e "   --device=*  Set devices, only codename, etc --device=shamu"
	echo -e "	--rom-gcc-version=*	 Set ROM GCC Version(EG: --rom-gcc-version=4.9, default to 4.9)"
	echo -e "	--kernel-gcc-version=*	Set Kernel GCC Version(EG: --kernel-gcc-version=5.2, default to 5.2)"
	echo -e "${bldblu}  Example:${bldcya}"
    echo -e "    ./build-kdp.sh --clean=yes --reset=yes --sync=no -j32 --device=shamu"
}

# Figure out the output directories
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default Options
ARG_PREFIX_DIR=$DIR/out
ARG_CLEAN_OPT=yes
ARG_RESET_OPT=yes
ARG_SYNC_OPT=yes
ARG_BLOCK_OTA=no
ARG_DEVICE=
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
    --device=*)
      ARG_DEVICE="${ARG#*=}"
      ;;
	--rom-gcc-version=*)
	  ARG_ROM_GCC_VERSION="${ARG#*=}"
	  ;;
	--kernel-gcc-version=*)
   	  ARG_KERNEL_GCC_VERSION="${ARG#*=}"
	  ;;
    -j=*)
      ARG_JTHREAD_OPT="${ARG#*=}"
      ;;
    *)
      error "Unrecognized parameter $ARG"
	  usage
      ;;
  esac
done

# Set Out directory
export OUT_DIR=${ARG_PREFIX_DIR}
echo "Out directory set to: ($ARG_PREFIX_DIR)"

# Set SaberMod GCC Versoins
if [ "${ARG_ROM_GCC_VERSION}" = "4.8" ]; then
	echo "Settings Rom GCC version as 4.8."
	export TARGET_SM_AND=4.8
else if [ "${ARG_ROM_GCC_VERSION}" = "4.9" ]; then
	echo "Settings Rom GCC Version as 4.9"
	export TARGET_SM_AND=4.9
else if [ "${ARG_ROM_GCC_VERSION}" = "5.1" ]; then
	echo "Setting Rom GCC Version as 5.1"
	export TARGET_SM_AND=5.1
else if [ "${ARG_ROM_GCC_VERSION}" = "5.2" ]; then
	echo "Setting Rom GCC Version as 5.2"
	export TARGET_SM_AND=5.2
else if [ "${ARG_ROM_GCC_VERSION}" = "6.0" ]; then
	echo "WARNING: 6.0 ROM GCC IS NOT RECOMANDED, Setting Rom GCC Version as 6.0"
else
	echo "Setting Rom GCC as 4.9(Stable)"
fi

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
echo "Starting build for ($ARG_DEVICE)"

if [ "x${ARG_BLOCK_OTA}" = "xyes" ]; then
	cd $DIR
	. build/envsetup.sh block
else
	cd $DIR
	. build/envsetup.sh
fi

# Make changeLog
vendor/kdp/utils/gen_changelog
lunch kdp_${ARG_DEVICE}-userdebug
mka bacon -j${ARG_JTHREAD_OPT}


