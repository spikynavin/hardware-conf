#!/bin/bash

#set -x

CWD=$(pwd)

PROGNAME=$(readlink -f ${BASH_SOURCE[0]})

function usage()
{
	echo -e "\nusage: source ${PROGNAME} <arguments>
\narguments:
	-h | --help  : script help
	-f | --fresh : argument for fresh build without using own-mirrors
	-b | --build : argument for build with using own-mirrors & cache\n"

}

function clean_up()
{
	unset NCPU CWD TEMPLATES SHORTOPTS LONGOPTS ARGS MIRRORS CODENAME
	unset MACHINE DISTRO TEMPLATECONF PROGNAME BB_GENERATE_MIRROR_TARBALLS
	unset SOURCE
}

function machine_conf_select()
{
	echo -e "\nSupported machines:\n"

	ls --hide=include \
		--hide=raspberrypi.conf \
		--hide=raspberrypi0.conf \
		--hide=raspberrypi-cm.conf \
		--hide=raspberrypi-cm3.conf \
		--hide=raspberrypi0-wifi.conf \
		--hide=raspberrypi2.conf \
		--hide=raspberrypi0-2w-64.conf \
		--hide=raspberrypi0-2w.conf \
		${CWD}/sources/meta-raspberrypi/conf/machine/ | cut -f 1 -d "." > list

	mapfile -t options < list
	#options+=("Quit")

	for i in "${!options[@]}"
	do
		echo "$((i+1)).${options[$i]}"
	done

	while true; do
		read -rep $'\nSelect machine you want to export: ' choice

		if [[ ${choice} =~ ^[0-9]+$ ]];then
			#echo "check the choice is with in the range"
			if ((choice >= 1 && choice <= ${#options[@]}));then
				if [ ${choice} -eq ${#options[@]} ];then
					echo -e "\nGoodbye!"
					break
				else
					selected_options=${options[$((choice-1))]}
					echo -e "\nYou selected: $selected_options machine"
					MACHINE=${selected_options}
					break
				fi
			else
				echo -e "\nInvalid choice. Please select a valid option."
				break
			fi
		else
			echo -e "\nInvalid input. Please enter a number."
			echo -e "\n"
			break
		fi
	done
}

function cpu_check()
{
	cpus=$(nproc)
	rcpus=$((cpus / 2))

	read -rep $'\nDo you want to override cpus [yes|no]: ' override

	case ${override} in
		y | yes | Y | Yes)
			read -rep $'\nEnter a number of cpus needs to used: ' ncpus
			echo ${ncpus}
			;;
		n | no | N | No)
			echo ${rcpus}
			;;
	esac
}

function fresh_build()
{
	local build_dir=$1
	local ncpus=$2

	export MACHINE=${MACHINE}
	export DISTRO=poky
	export BB_GENERATE_MIRROR_TARBALLS=1
	export TEMPLATECONF=$(pwd)/sources/meta-elinux/conf/hardware-conf
	source sources/meta-elinux/conf/setup-embedded-linux-rpi ${build_dir} --use-cpus ${ncpus}
}

function mirror_build()
{
	local build_dir=$1
	local ncpus=$2

	export MACHINE=${MACHINE}
	export DISTRO=poky
	export BB_GENERATE_MIRROR_TARBALLS=1
	export MIRRORS=True
	export SOURCE=/mnt/d/yocto_mirrors
	export CODENAME=kirkstone
	export TEMPLATECONF=$(pwd)/sources/meta-elinux/conf/hardware-conf
	source sources/meta-elinux/conf/setup-embedded-linux-rpi ${build_dir} --use-cpus ${ncpus}
}

function main()
{
	SHORTOPTS="f,b,h"
	LONGOPTS="fresh,build,help"

	ARGS=$(getopt --options ${SHORTOPTS} --longoptions ${LONGOPTS} --name ${PROGNAME} -- "$@")

	if [ $? -ne 0 -o $# -lt 1 ];then
		usage && clean_up
		return 1
	fi

	eval set -- "${ARGS}"

	while true; do
		case $1 in
			-h | --help)
				usage && clean_up
				return 0
				shift
				;;
			-f | --fresh)
				machine_conf_select
				ret=$(cpu_check)
				read -rep $'\nEnter build-dir name: ' build_dir
				fresh_build "${build_dir}" "${ret}"
				shift 2
				break
				;;
			-b | --build)
				machine_conf_select
				ret=$(cpu_check)
				read -rep $'\nEnter build-dir name: ' build_dir
				mirror_build "${build_dir}" "${ret}"
				break
				;;
			*)
				echo -e "\nInvalid option passed"
				shift
				break
				;;
		esac
	done
}

main $@

#set +x
