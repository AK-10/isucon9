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

mysql2_client = Mysql2::Client.new(
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



def mysql2_result
  result = mysql2_client.query(QUERY)
  puts "class of result: #{result.class}"

  rows = result.to_a.first
  puts rows
end

def mysql2_bench
  Benchmark.bm 100 do |r|
    r.report "mysql2 benchmark 100 iteration" do
      (1..100).each do
        mysql2_client.query(QUERY)
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
