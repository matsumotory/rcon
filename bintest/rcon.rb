require 'open3'

BIN_PATH = File.join(File.dirname(__FILE__), "../mruby/bin/rcon")

assert('user') do
  output, status = Open3.capture2("sudo", BIN_PATH, "--user", "daemon", "--command", "id -u")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "2\n"
end

assert('version') do
  output, status = Open3.capture2(BIN_PATH, "--version")

  assert_true status.success?, "Process did not exit cleanly"
  assert_include output, "v0.0.1"
end
