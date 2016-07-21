describe command('chef-client -v') do
  its('stdout') { should_not match(/11.14/) }
  its('exit_status') { should eq 0 }
end
