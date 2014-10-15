guard 'rake', :task => 'spec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/.+\.rb$})
  watch('spec/spec_helper.rb')
  watch('spec/fixtures/.+$')
end

guard 'rake', :task => 'integration' do
  watch(%r{^spec/integration/.+_spec\.rb$})
end
