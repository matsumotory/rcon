def __main__(argv)
  opts = Getopts.getopts("",
                         "cpu:30",
                         "memory:#{512 * 1024 * 1024}",
                         "read:#{10 * 1024 * 1024}",
                         "write:#{10 * 1024 * 1024}",
                         "group:rcon",
                         "user:",
                         "pids:",
                         "command:",
                         "dev:8:0",
                         "version",
                         "help",
                         "dry-run").each_with_object({}) {|ary,opts| opts[ary[0].to_sym] = ary[1] }

  raise ArgumentError, "\n\n#{Rconner::USAGE}\n" if opts.has_key?(:"?")

  if opts.has_key? :version
    puts "v#{Rconner::VERSION}"
    exit
  end

  if opts.has_key? :help
    puts Rconner::USAGE
    exit
  end

  if opts.has_key? :"dry-run"
    p opts
    exit
  end

  raise ArgumentError, "command or pids not found: --command or --pids" if opts[:command].empty? && opts[:pids].empty?
  raise ArgumentError, "don't use both --command and --pids" if ! opts[:command].empty? && ! opts[:pids].empty?
  raise ArgumentError, "don't use both --user and --pids" if ! opts[:user].empty? && ! opts[:pids].empty?
  raise ArgumentError, "user not found: --user" if opts[:user].empty? && opts[:pids].empty?

  Rcon.new({
    :command  => opts[:pids].empty? ? opts[:command] : nil,
    :pids     => opts[:pids].empty? ? nil : opts[:pids].split(" ").map(&:to_i),
    :user     => opts[:pids].empty? ? opts[:user] : nil,
    :resource => {
      # if you use oom event callbakc, you should set your cgroup root dir.
      # since libcgroup don't support oom event callback.
      :root       => "/cgroup",
      :group      => opts[:group],
      :cpu_quota  => opts[:cpu].to_i * 1000,
      :blk_dvnd   => opts[:dev],
      :blk_rbps   => opts[:read].to_i,
      :blk_wbps   => opts[:write].to_i,
      :mem        => opts[:memory].to_f,
      :oom        => true,
    },
  }).run
  opts
end
