def __main__(argv)
  opts = Getopts.getopts("", "cpu:30", "mem:#{512 * 1024 * 1024}", "read:#{10 * 1024 * 1024}", "write:#{10 * 1024 * 1024}", "group:rcon", "user:", "command:", "dev:8:0", "version", "help").each_with_object({}) {|ary,opts| opts[ary[0].to_sym] = ary[1] }

  raise ArgumentError, "\n\n#{Rconner::USAGE}\n" if opts.has_key?(:"?")

  if opts.has_key? :version
    puts "v#{Rconner::VERSION}"
    exit
  end

  if opts.has_key? :help
    puts Rconner::USAGE
    exit
  end

  raise ArgumentError, "command not found: --command" if opts[:command].empty?
  raise ArgumentError, "user not found: --user" if opts[:user].empty?

  Rcon.new({
    :command => opts[:command],
    :user => opts[:user],
    :resource => {
      # centos "/cgroup" by default
      # ubuntu "/sys/fs/cgroup"
      :root => "/cgroup",
      :group => opts[:group],
      # CPU [msec] exc: 30000 -> 30%
      :cpu_quota => opts[:cpu].to_i * 1000,
      # IO [Bytes/sec]
      :blk_dvnd => opts[:dev],
      :blk_rbps => opts[:read].to_i,
      :blk_wbps => opts[:write].to_i,
      # Memory [Bytes]
      :mem => opts[:mem].to_f,
      :oom => true,
    },
  }).run
end
