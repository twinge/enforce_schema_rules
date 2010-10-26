ENV["RAILS_ENV"] = "test"
$:.unshift File.join(File.dirname(__FILE__), '..', '..', '..', '..')

require 'config/environment'

ActiveRecord::Schema.define do
  create_table :enforce_schema_rules_test_table, :force => true do |t|
    t.column :string_column, :string, :limit => 5
    t.column :not_null_column, :integer, :null => false
    t.column :integer_column, :integer
    t.column :float_column, :float
    t.column :boolean_column, :boolean, :null => false
    t.column :not_null_foreign_key_id, :integer, :null => false
    t.column :created_at, :datetime
  end
  add_index(:enforce_schema_rules_test_table, :string_column, :unique => true)
end

module EnforceSchema
  class Model < ActiveRecord::Base
    set_table_name "enforce_schema_rules_test_table"
  end
  class AllRules < Model
    enforce_schema_rules :except => :created_at
  end
  class IntegerRule < Model
    enforce_integer_columns
  end
  class StringRule < Model
    enforce_column_limits :message => "custom message"
  end
  class NotNullRule < Model
    enforce_not_null
  end
  class UniqueRule < Model
    enforce_unique_indexes
  end
end


