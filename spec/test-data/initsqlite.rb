require "sqlite3"
require "../test_data_setup.rb"

SQLITE_DB = File.join(File.dirname(__FILE__), "test.db")

# Open a database
init_db = !File.exists?(SQLITE_DB)

db = SQLite3::Database.new SQLITE_DB
if init_db
  puts "Executing DDL..."
  db.execute <<-SQL
  create table companies (
    idx int primary key,
    active char,
    name varchar(50),
    founded int,
    slogan varchar(75),
    biz_id int,
    contact varchar(50),
    contactid int,
    unknown0 varchar(10),
    street varchar(50),
    city varchar(30),
    state varchar(2),
    zipcode varchar(10),
    areacode varchar(3),
    phone varchar(12),
    note varchar(100),
    unknown1 varchar(13)
  );
  SQL
  db.execute <<-SQL
  create table employees (
    idx int primary key,
    active char,
    honorific varchar(10),
    firstname varchar(25),
    lastname varchar(25),
    email varchar(50),
    unknown0 varchar(10),
    street varchar(50),
    city varchar(30),
    state varchar(2),
    zipcode varchar(10),
    areacode varchar(3),
    home_phone varchar(12),
    mobile_phone varchar(12),
    note varchar(100),
    salary int,
    companyid int,
    unknown1 varchar(13)
  );
  SQL
end

puts "Clearing tables..."
db.execute "delete from companies"
db.execute "delete from employees"

puts "Inserting companies..."
FlatFiles::ProviderRegistry[:bindata][:company].relation(FlatFiles::Util::FileResource.new(TENK_COMPANIES)).each do |row|
  attrs = *(row.header)
  cols = attrs.map(&:name)
  cols[0] = :idx # :index -> :idx
  db.execute "insert into companies (#{cols.join(',')}) values (#{['?'] * cols.length * ','})", row.to_ary
end

puts "Inserting employees..."
FlatFiles::ProviderRegistry[:bindata][:employee].relation(FlatFiles::Util::FileResource.new(FORTYK_EMPLOYEES)).each do |row|
  attrs = *(row.header)
  cols = attrs.map(&:name)
  cols[0] = :idx # :index -> :idx
  db.execute "insert into employees (#{cols.join(',')}) values (#{['?'] * cols.length * ','})", row.to_ary
end
