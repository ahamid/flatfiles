require 'flatfiles'
require 'flatfiles/util/resource'

Dir[File.expand_path(File.dirname(__FILE__) + '/providers/*.rb')].each {|f| require f }

ONE_EMPLOYEE = File.expand_path("./test-data/1-employee.dat", File.dirname(__FILE__))
ONE_COMPANY = File.expand_path("./test-data/1-company.dat", File.dirname(__FILE__))
FORTYK_EMPLOYEES = File.expand_path("./test-data/40000-employees.dat", File.dirname(__FILE__))
TENK_COMPANIES = File.expand_path("./test-data/10000-companies.dat", File.dirname(__FILE__))