module Clickhouse
  class Connection
    module Query
      def exists_table(name)
        execute("EXISTS TABLE #{name}").strip == '1'
      end

      def optimize_table(name)
        execute("OPTIMIZE TABLE #{name}")
      end

      def drop_table?(name)
        execute("DROP TABLE IF EXISTS #{name}")
      end

      # CREATE TABLE default.test ( date Date,  a Int32,  b String) ENGINE = MergeTree(date, (a), 8192)
      # insert_rows :test, rows: [[Date.today, 1, :a], [Date.today, 2, :b]]
      # insert_rows :test, rows: [{date: Date.today, a: 1, b: :a}, {date: Date.today, a: 2, b: :b, what: :ever}] # take names from first hash
      # insert_rows :test, names: [:a, :b], rows: [[3, :a], [4, :b]]
      # insert_rows :test, names: [:a, :b], rows: [{a: 5, b: :a, x: 0}, {a: 6, b: :b, y: 0}]
      # insert_rows(:test) { |rows| rows  << {a: 1, b: 2} }
      # insert_rows(:test) { |rows| rows  << [Date.today, 1, :a] }
      def insert_rows(table, options = {})
        options[:csv] ||= begin
          options[:rows]  ||= yield([])
          options[:names] ||= options[:rows].any? && options[:rows].first.is_a?(Hash) && options[:rows].first.keys
          generate_csv options[:rows], options[:names]
        end

        query = <<-SQL
          INSERT INTO #{table} #{ "(#{options[:names].join(?,)})" if options[:names] } 
          FORMAT #{  options[:rows][0].is_a?(Array) && !options[:names] ? 'CSV' : 'CSVWithNames'}
        SQL
        execute(query, options[:csv])
      end
    end
  end
end
