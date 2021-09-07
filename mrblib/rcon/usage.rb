module Rconner
  USAGE =<<USAGE
Usage: rcon [options] --user username --command "yes >> /dev/null"
    --cpu VAL
      default: 30 (%)
    --memory VAL
      default: 512000000 (Byte)
    --read VAL
      default: 10000000 (Byte/sec)
    --write VAL
      default: 10000000 (Byte/sec)
    --group VAL
      default: rcon
    --dev VAL
      default: 8:0
    --pids VAL
      default: nothing
    --version
USAGE
end
