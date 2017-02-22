#!/bin/bash
# -------------------------------------------------------
#  Command line script to handle Firefox and Thunderbird extensions
#  Manage installation and uninstallation
#  Handle global and per-user extensions
#  
#  Depends on unzip and wget
#
#  Manual available at http://bernaerts.dyndns.org/linux/74-ubuntu/271-ubuntu-firefox-thunderbird-addon-commandline
#
#  Parameters :
#    --install : install extension
#    --remove  : remove extension
#    --user    : extension as per-user
#    --global  : extension global to system
#    https://addons.mozilla.org/... : URL of extension
#
#  26/03/2013, V1.0 - Creation by N. Bernaerts
#  08/11/2015, V2.0 - Complete rewrite
#                     Add install/remove
#                     Add global/per-user
#  28/12/2016, V2.1 - Add Fedora compatibility thanks to Cedric Brandenbourger
# -------------------------------------------------------

# -------------------------------------------------------
#   Check tools availability
# -------------------------------------------------------

command -v unzip >/dev/null 2>&1 || { zenity --error --text="Please install unzip"; exit 1; }
command -v wget >/dev/null 2>&1 || { zenity --error --text="Please install wget"; exit 1; }

# ------------------------------------------------------
#   Constants
# ------------------------------------------------------

# set default add-ons URL base
URL_FIREFOX="https://addons.mozilla.org/firefox/"
URL_THUNDER="https://addons.mozilla.org/thunderbird/"

# installation path for user extensions
PATH_USER_FIREFOX="$HOME/.mozilla/firefox/"
PATH_USER_THUNDER="$HOME/.thunderbird/"

# ------------------------------------------------------
#   Set installation path according to distribution
# ------------------------------------------------------

# detect architecture
ARCHITECTURE=$(arch)

# set installation path for debian based distribution (Debian, Ubuntu, ...)
if [ -f /etc/debian_version ]
then
  # OLD PATH_GLOBAL_FIREFOX="/usr/lib/firefox-addons/extensions"
  PATH_GLOBAL_FIREFOX="/usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/"
  PATH_GLOBAL_THUNDER="/usr/share/mozilla/extensions/{3550f703-e582-4d05-9a08-453d09bdfdc6}/"

# else, set for Fedora 64
elif [ "${ARCHITECTURE}" = "x86_64" ]
then
  PATH_GLOBAL_FIREFOX="/usr/lib64/firefox/extensions/"
  PATH_GLOBAL_THUNDER="/usr/lib64/thunderbird/extensions/"
  
# else set for Fedora 32 
else
  PATH_GLOBAL_FIREFOX="/usr/lib/firefox/extensions/"
  PATH_GLOBAL_THUNDER="/usr/lib/thunderbird/extensions/"
fi

# -------------------------------------------------------
#   Default values
# -------------------------------------------------------

# extension family (firefox or thunder)
EXT_FAMILY=""

# extension .xpi URL
EXT_URL=""

# extension installation path
EXT_PATH=""

# extension type (global or per user)
EXT_TYPE="user"

# action to be performed (install or remove)
EXT_ACTION="install"

# -------------------------------------------------------
#   Parameters
# -------------------------------------------------------

for PARAM in "$@"
do
  # action according to parameter
  case "${PARAM}" in
    "--user")    EXT_TYPE="user" ;;
    "--global")  EXT_TYPE="global" ;;
    "--install") EXT_ACTION="install" ;;
    "--remove")  EXT_ACTION="remove" ;;
    *)
      # get extension URL
      EXT_URL="${PARAM}"

      # determine if we are dealing with firefox extension
      RESULT=$(echo "${PARAM}" | grep "${URL_FIREFOX}")
      [ "${RESULT}" != "" ] && EXT_FAMILY="firefox"  
  
      # determine if we are dealing with thunderbird extension
      RESULT=$(echo "${PARAM}" | grep "${URL_THUNDER}")
      [ "${RESULT}" != "" ] && EXT_FAMILY="thunder"
      ;;
  esac
done

# -------------------------------------------------------
#   Product family
# -------------------------------------------------------

# firefox extension 
if [ "${EXT_FAMILY}" = "firefox" ]
then
  PATH_GLOBAL="${PATH_GLOBAL_FIREFOX}"
  PATH_USER="${PATH_USER_FIREFOX}"

# thunderbird extension
elif [ "${EXT_FAMILY}" = "thunder" ]
then
  PATH_GLOBAL="${PATH_GLOBAL_THUNDER}"
  PATH_USER="${PATH_USER_THUNDER}"
  
# none, error 
else
  zenity --error --text="Given parameter is neither a firefox nor a thunderbird extension"
  exit 1
fi

# -------------------------------------------------------
#   User or Global extension
# -------------------------------------------------------

# if global extension, set installation path
if [ "${EXT_TYPE}" = "global" ]
then
  EXT_PATH="${PATH_GLOBAL}"

# else determine installation path for user extensions
else
  # set profile.ini path
  PROFILE_INI="${PATH_USER}/profiles.ini"
  
  # get profile path
  PROFILE_PATH=$(grep "Path=" ${PROFILE_INI} | head -n 1 | cut -d'=' -f2)
  
  # set user profile path or exit if it doesn't exist
  [ "${PROFILE_PATH}" != "" ] && EXT_PATH="${PATH_USER}/${PROFILE_PATH}/extensions" || { zenity --error --text="User profile doesn't exist"; exit 1; }
fi   

# -------------------------------------------------------
#   Installation / Removal
# -------------------------------------------------------

# download extension
rm -f addon.xpi 
wget -O addon.xpi "${EXT_URL}"

# get extension UID from install.rdf
EXT_UID=$(unzip -p addon.xpi install.rdf | grep "<em:id>" | head -n 1 | sed 's/^.*>\(.*\)<.*$/\1/g')

# if .xpi file could not be read, exit
[ "${EXT_UID}" = "" ] && { zenity --error --text="Could not retrieve extension file from server"; exit 1; }

# action : installation
if [ "${EXT_ACTION}" = "install" ]
then
  # check if extension not already installed
  [ -d "${EXT_PATH}/${EXT_UID}" ] && { zenity --error --text="${EXT_TYPE} extension ${EXT_UID} is already installed"; exit 1; }

  # installation of global extension
  if [ "${EXT_TYPE}" = "global" ]
  then
    # make sure we're running as root
    if (( `/usr/bin/id -u` != 0 )); then { /bin/echo "Sorry, must be root to install extensions globally"; exit 1; } fi
    
    # copy .xpi to global extension path
    cp -f addon.xpi "${EXT_PATH}${EXT_UID}.xpi"

    # extract extension to global extension path
    unzip addon.xpi -d "${EXT_PATH}${EXT_UID}"

    # set permissions of extension for access by all users
    chmod -R g+rX,o+rX "${EXT_PATH}${EXT_UID}"

  # else, installation of extension for current user 
  else
    # copy .xpi to user profile extension path
    cp -f addon.xpi "${EXT_PATH}${EXT_UID}.xpi"

    # extract extension to user profile extension path
    unzip addon.xpi -d "${EXT_PATH}${EXT_UID}"
  fi

  # end message
  echo "${EXT_TYPE} extension ${EXT_UID} installed"

# action : removal
else
  # check if extension is installed
  [ -d "${EXT_PATH}${EXT_UID}" ] || { zenity --error --text="${EXT_TYPE} extension ${EXT_UID} was not installed"; exit 1; }

  # removal of a global extension
  if [ "${EXT_TYPE}" = "global" ]
  then
    # make sure we're running as root
    if (( `/usr/bin/id -u` != 0 )); then { /bin/echo "Sorry, must be root to install extensions globally"; exit 1; } fi

    # remove global extension directory
    rm "${EXT_PATH}${EXT_UID}.xpi"
    rm -R "${EXT_PATH}${EXT_UID}"

  # else, removal of extension for current user 
  else
    # remove user xpi file and extension directory
    rm "${EXT_PATH}${EXT_UID}.xpi"
    rm -R "${EXT_PATH}${EXT_UID}"
  fi

  # end message
  echo "${EXT_TYPE} extension ${EXT_UID} removed"
fi

# remove downloaded file
rm -f addon.xpi
