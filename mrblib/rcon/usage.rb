module Rconner
  USAGE =<<USAGE
Usage: rcon [options] --user username --command "yes >> /dev/null"
    --cpu VAL
      default: 30 (%)
    --mem VAL
      default: 512 (MiB)
    --read VAL
      defualt: 10485760 (Byte/sec)
    --write VAL
      defualt: 10485760 (Byte/sec)
    --group VAL
      defualt: rcon
    --dev VAL
      default: 202:0
    --version
USAGE
end
