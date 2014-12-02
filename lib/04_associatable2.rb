require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)
    foreign_key = assoc_options[through_name].foreign_key
    through_options = assoc_options[through_name]
    through_table = through_options.model_class.table_name

    source_options = through_options.model_class.assoc_options[source_name]

    source_table = source_options.model_class.table_name

    define_method(name) do
      through_id = send(foreign_key)
      result = DBConnection.execute(<<-SQL, through_id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table} ON #{through_table}.#{source_options.foreign_key} = #{source_table}.id
        WHERE
          #{through_table}.id = ?
      SQL
      source_options.model_class.new(result.first)
    end

  end
end
