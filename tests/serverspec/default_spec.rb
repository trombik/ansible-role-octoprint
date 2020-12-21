require "spec_helper"
require "serverspec"

service = "octoprint"
user    = case os[:family]
          when "openbsd"
            "_octoprint"
          else
            "octoprint"
          end
group   = user
groups  = case os[:family]
          when "freebsd", "openbsd"
            ["dialer"]
          else

            # linux
            ["dialout"]
          end
ports   = [5000]
octoprint_users = %w[root foo]
home_dir = case os[:family]
           when "freebsd", "openbsd"
             "/usr/local/octoprint"
           else
             "/home/octoprint"
           end
config_dir = "#{home_dir}/.octoprint"

describe file(home_dir) do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe user(user) do
  it { should exist }
  it { should belong_to_primary_group group }
  groups.each do |g|
    it { should belong_to_group g }
  end
  it { should have_home_directory home_dir }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/octoprint") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
    its(:content) { should match(/octoprint_extra_flags=-v/) }
  end

  describe file "/usr/local/etc/rc.d/#{service}" do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should match(/Managed by ansible/) }
  end

  describe command "ps axw" do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should be_empty }
    its(:stdout) { should match(%r{#{home_dir}/octoprint/bin/python3\s+.+octoprint serve -v}) }
  end
when "openbsd"
  describe file "/etc/rc.d/octoprint" do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should match(/Managed by ansible/) }
  end

  describe file "/etc/rc.conf.local" do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    its(:content) { should match(/pkg_scripts=#{service}$/) }
  end
when "ubuntu"
  describe file("/etc/default/#{service}") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
    its(:content) { should match(/EXTRA_FLAGS=-v/) }
  end

  describe file("/lib/systemd/system/#{service}.service") do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should match(/Managed by ansible/) }
  end

  describe command "ps axw" do
    its(:exit_status) { should eq 0 }
    its(:stderr) { should be_empty }
    its(:stdout) { should match(%r{#{home_dir}/octoprint/bin/python\s+.+octoprint serve -v}) }
  end
end

describe file config_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode 700 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file "#{config_dir}/config.yaml" do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/key:\s+5636381594984F8887F63F8E0CBD4F9D/) }
end

describe file "#{config_dir}/users.yaml" do
  it { should exist }
  it { should be_file }
  it { should be_mode 600 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/password:\s+accdeb2c4cf9536eba1bbc07d4128762d3391dc67a55b020c008fde5d0a6fb12605e090cd19da33a60d5ec850bb36c0328069834cb0013666ba9ccf2add83b4f/) }
end

describe file "#{config_dir}/data/appkeys/keys.yaml" do
  it { should exist }
  it { should be_file }
  it { should be_mode 640 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  its(:content) { should match(/api_key:\s+B9B058659A154060833F317BD947A030/) }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "curl -s http://127.0.0.1:5000" do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{<title>Redirecting\.\.\.</title>}) }
end
