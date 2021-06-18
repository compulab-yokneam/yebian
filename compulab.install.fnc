PACKAGES=""
PACKAGES_FORCE=""
PACKAGES_REINSTALL=""
FEATURES=${FEATURES:-"EMPTY;"}

function method_install() {
    PACKAGES+=${packages}" "
}

function method_decide() {
    ischroot && chroot_arch=$(dpkg --print-architecture) || chroot_arch=${socarch}
    [[ ${chroot_arch} = ${socarch} ]] && PACKAGES+=${packages}" " || PACKAGES_FORCE+=${packages}" "
}

function method_force() {
    PACKAGES_FORCE+=${packages}" "
}

function method_reinstall() {
    PACKAGES_REINSTALL+=${packages}" "
}

function chroot_env() {
    for _p in ${OE2DEB[@]};do
        eval ${_p}
        packages=$(cat <<< ${packages} | tr ":" " ")
        packages=${packages} method_${method}
    done
}

function be_method_add() {
    PACKAGES+=${packages}" "
}

function be_method_reinstall() {
cat << eom
    Nothing to do with in the build environment.
eom
}

function build_env() {
    for _p in ${!OE2DEB[@]};do
        eval ${OE2DEB[${_p}]}
        command -v be_method_${method} && packages=${_p} be_method_${method} || packages=${_p} be_method_add
    done
}

declare -p OE2DEB &>/dev/null && rc=0 || rc=1
if [[ ${rc} -ne 0 ]];then
declare -A OE2DEB=()
OE2DEB+=(['linux-imx']='method="install";packages="kernel:kernel-modules:kernel-devicetree:"')
OE2DEB+=(['firmware-imx']='method="install";packages="firmware-imx-sdma:"')
fi

ischroot && chroot_env || build_env

export PACKAGES=${PACKAGES}
export PACKAGES_FORCE=${PACKAGES_FORCE}
export PACKAGES_REINSTALL=${PACKAGES_REINSTALL}
