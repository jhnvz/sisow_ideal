require 'sisow_ideal'
require 'vcr'

extend VCR::RSpec::Macros

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.ignore_hosts '127.0.0.1', 'localhost'
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end