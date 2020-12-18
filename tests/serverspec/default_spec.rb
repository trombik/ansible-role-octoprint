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
          when "freebsd"
            ["dialer"]
          else

            # linux
            ["dialout"]
          end
ports   = [5000]
home_dir = case os[:family]
           when "freebsd"
             "/usr/local/octoprint"
           else
             "/home/octoprint"
           end

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
  end

  describe file "/usr/local/etc/rc.d/#{service}" do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should match(/Managed by ansible/) }
  end
when "ubuntu"
  describe file("/etc/default/#{service}") do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    its(:content) { should match(/Managed by ansible/) }
  end
  describe file("/lib/systemd/system/#{service}.service") do
    it { should exist }
    it { should be_file }
    it { should be_mode 755 }
    its(:content) { should match(/Managed by ansible/) }
  end
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
  its(:stdout) { should match(%r{<title .*OctoPrint.*</title>}) }
end
