require 'open3'

BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/rcon")

assert('argv') do
  output, status = Open3.capture2("sudo", BIN_PATH, "--user", "daemon", "--command", "id -u", "--dry-run")
  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "{:user=>\"daemon\", :command=>\"id -u\", :\"dry-run\"=>\"\", :cpu=>\"30\", :memory=>\"536870912\", :read=>\"10485760\", :write=>\"10485760\", :group=>\"rcon\", :dev=>\"8:0\"}\n"
end

assert('argv all') do
  output, status = Open3.capture2("sudo", BIN_PATH, "--user", "daemon", "--command", "id -u", "--dry-run", "--cpu", "20", "--memory", "512", "--write", "1024", "--read", "1024", "--group", "hoge", "--dev", "9:0")
  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "{:user=>\"daemon\", :command=>\"id -u\", :\"dry-run\"=>\"\", :cpu=>\"20\", :memory=>\"512\", :write=>\"1024\", :read=>\"1024\", :group=>\"hoge\", :dev=>\"9:0\"}\n"
end

assert('version') do
  output, status = Open3.capture2(BIN_PATH, "--version")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v0.0.1"
end
