# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }

  watch(%r{^manifests/(.+)\.pp$}) { |m| ["spec/classes/#{m[1]}_spec.rb", "spec/defines/#{m[1]}_spec.rb"] }
end

