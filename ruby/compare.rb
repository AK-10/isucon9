require 'benchmark'
require 'active_record'
require 'mysql2'

target = ARGV[0]
type = ARGV[1]


# https://qiita.com/aosho235/items/bca4a2117b78baa927d7#mysql
ActiveRecord::Base.establish_connection(
  adapter: "mysql2",
  host: "127.0.0.1",
  port: '3306',
  database: 'isucari',
  username: 'isucari',
  password: 'isucari',
  encoding: 'utf8mb4',
  database_timezone: :local,
  cast_booleans: true,
  reconnect: true
)


MYSQL2_CLIENT = Mysql2::Client.new(
  'host' => ENV['MYSQL_HOST'] || '127.0.0.1',
  'port' => ENV['MYSQL_PORT'] || '3306',
  'database' => ENV['MYSQL_DBNAME'] || 'isucari',
  'username' => ENV['MYSQL_USER'] || 'isucari',
  'password' => ENV['MYSQL_PASS'] || 'isucari',
  'charset' => 'utf8mb4',
  'database_timezone' => :local,
  'cast_booleans' => true,
  'reconnect' => true,
)

QUERY = <<~QUERY
  SELECT
    *
  FROM
    items as i
  INNER JOIN
    users as s
  LEFT OUTER JOIN
    users as b
  ON
    i.buyer_id = b.id
  WHERE
    (i.seller_id = 1 OR i.buyer_id = 1)
  ORDER BY
    i.created_at DESC
  LIMIT 100
QUERY

def activerecord_result
  conn = ActiveRecord::Base.connection
  result = conn.select_all(QUERY)
  puts "class of result:#{result.class}"

  rows = result.to_a.first
  puts rows
end

def activerecord_bench
  conn = ActiveRecord::Base.connection
  Benchmark.bm 100 do |r|
    r.report "ActiveRecord benchmark 10 iteration" do
      conn = ActiveRecord::Base.connection
      (1..10).each do
        conn.select_all(QUERY)
      end
    end
  end
end

def mysql2_result
  result = MYSQL2_CLIENT.query(QUERY)
  puts "class of result: #{result.class}"

  rows = result.to_a.first
  puts rows
end

def mysql2_bench
  Benchmark.bm 100 do |r|
    r.report "mysql2 benchmark 10 iteration" do
      (1..10).each do
        MYSQL2_CLIENT.query(QUERY)
      end
    end
  end 
end


# run command
if target == 'mysql2' && type == 'result'
  mysql2_result
elsif target == 'mysql2' && type == 'bench'
  mysql2_bench
elsif target == 'activerecord' && type == 'result'
  activerecord_result
elsif target == 'activerecord' && type == 'bench'
  activerecord_bench
else
  "target, type not found"
end
