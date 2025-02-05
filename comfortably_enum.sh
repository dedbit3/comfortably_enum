#!/bin/bash

# comfortably_enum
# @author: dedbit
# @last revision: Feb 05, 2025

# default options
VERBOSE_OUTPUT=false
VERSION_DETECTION=false

# probably don't enable these by default 
# these options must be used by themselves
PING_SWEEP=false
OS_DETECTION=false
AUTOMATED_SCAN_WITH_OUTPUT=false

# scan type (must have one scan type set to true)
SYN_SCAN=true

# check if nmap is present in the system
if ! command -v nmap 2>&1 >/dev/null
then
  echo -e "\n
    ERROR: NMAP is not installed in the system and required for this tool to work\n
    Please install nmap and try again\n
  "
  exit 1
fi

# take flags
while getopts "hAvoVLt:" flag; do
  case $flag in 
    h) # help 
      echo -e "\n
        comfortably_enum 
        Usage: comfortably_enum.sh [Options] -t {target specification}\n
        AUTOMATED SCAN: comfortably_enum.sh -A -t {target specification}\n
        *Run complete scan on target host/hosts and ouput enumeration files*\n
        1)identifies live hosts and ouputs them to live.txt
        2)identifies open ports on live hosts and outputs to ports.txt
        3)identifies OS as well as versions and ouputs them to enumerated.txt\n
        WARNING: This option must be ran by itself\n
        TARGET SPECIFICATION:
          Can pass hostnames, IP addresses, networks, etc.\n
          Example:
            192.168.0.0/24
            192.168.0.0-10
            192.168.0.2,3,4,5\n
        OPTIONS: \n
          -h : Displays help information
          -v : Enables verbose output
          -V : Enables version detection
          -t : set the target/targets ip\n
        OPTIONS [TO BE USED INDIVIDUALY]:\n
          -A : Run complete automated scan on target hosts and ouput enumeration files
          -L : scans the subnet for live hosts only
          -o : Enables OS detection\n
      "
      exit 0
    ;;
    A) # run complete scan on targets with file outputs
      AUTOMATED_SCAN_WITH_OUTPUT=true
    ;;
    v) # enable verbose output
      VERBOSE_OUTPUT=true
    ;;
    o) # enable OS detection
      OS_DETECTION=true
    ;;
    V) # enable version detection
      VERSION_DETECTION=true
    ;;
    L) # ping sweep subnet
      PING_SWEEP=true
    ;;
    t) # read target ip
      TARGET_IP=$OPTARG
    ;;
    \?) # error
      echo -e "\n
        ERROR: Invalid user input\n
        For execution options enter: ./comfortably_enum.sh -h\n
      "
      exit 1
    ;;
  esac
done

# proccess options
if $VERBOSE_OUTPUT; then VERBOSE_OUTPUT="--vv"; else VERBOSE_OUTPUT=""; fi
if $VERSION_DETECTION; then VERSION_DETECTION="V"; else VERSION_DETECTION="V"; fi
if $SYN_SCAN; then SYN_SCAN="S"; else SYN_SCAN=""; fi

# individual options if called disable everything else
if $OS_DETECTION; then OS_DETECTION="O" VERBOSE_OUTPUT="" VERSION_DETECTION="" PING_SWEEP=""; else OS_DETECTION=""; fi
if $PING_SWEEP; then PING_SWEEP="n" SYN_SCAN="" OS_DETECTION="" VERBOSE_OUTPUT="" VERSION_DETECTION=""; else PING_SWEEP=""; fi

# full automated scan option with ouput ignores all other options
if $AUTOMATED_SCAN_WITH_OUTPUT; 
then
  # run first sweep scan output live.txt
  echo -e "\nScanning for live hosts: outputing to live.txt\n"
  NMAP=$(nmap -sn $TARGET_IP | tee /dev/tty)
  LIVE_IP=$(echo "$NMAP" | awk '/Nmap scan report for/ {print $5}')
  echo "$LIVE_IP" > live.txt
  echo -e "\n"

  # run second port scan output ports.txt
  echo -e "\nScanning live host ports with version: outputing to ports.txt\n"
  LIVE_IP="10.1.20.1"
  NMAP=$(echo "$LIVE_IP" | xargs -n 1 nmap -sSV -p- | tee /dev/tty)
  echo "$NMAP" > ports.txt
  echo -e "\n"

  # run third version scan output enumerated.txt
  echo -e "\nRunning OS version enumeration: outputing to enumerated.txt\n"
  NMAP=$(echo "$LIVE_IP" | xargs -n 1 nmap -sO | tee /dev/tty)
  echo "$NMAP" > enumerated.txt
  echo -e "\n"

  # exit
  exit 0
fi

# display command
echo -e "\n\tNmap Command Executed:\n"
echo -e "\tnmap -s$PING_SWEEP$SYN_SCAN$OS_DETECTION$VERSION_DETECTION $TARGET_IP $VERBOSE_OUTPUT \n"

# execute nmap commands
echo -e "\nScan Output:\n"
NMAP=$(nmap -s$PING_SWEEP$SYN_SCAN$OS_DETECTION$VERSION_DETECTION $TARGET_IP $VERBOSE_OUTPUT | tee /dev/tty)
echo -e "\n"

# exit
exit 0
