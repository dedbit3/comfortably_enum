                                           *comfortably_enum*

  Summary: This is a complete enumeration script writen in bash to be used in pentesting enumeration of hosts
  it is capable of running automated enumeration scans in an entire subnet and saving the outputs to files.

  NOTE: If you wish to change the default options of the script edit the default variables at the very top!

  Usage: ./comfortably_enum.sh -A -t {target ip}

  Flags:
    -h : Displays help information
    -v : Enables verbose output
    -V : Enables version detection
    -t : set the target/targets ip

  Flags [TO BE USED INDIVIDUALY]:
    -A : Run complete automated scan on target hosts and ouput enumeration files
    -L : scans the subnet for live hosts only
    -o : Enables OS detection

