require 'active_record'

module Jls
  module Validations #:nodoc:
    module EnforceSchemaRules #:nodoc:

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Call all enforcement methods
        def enforce_schema_rules(options = {})
          enforce_column_limits(options.dup)
          enforce_integer_columns(options.dup)
          enforce_not_null(options.dup)
          enforce_unique_indexes(options.dup)
        end
        
        # Enforce string column limits
        def enforce_column_limits(options = {})
          args = build_validation_args(options, :string, :too_long)
          options = args.pop
          validates_each(*args) do |record, attr, value|
            limit = record.class.columns_hash[attr.to_s].limit
            if limit
              message = options[:message] % limit
              record.errors.add(attr, message) unless value.nil? || value.size <= limit
            end
          end
        end
        
        # Enforce numericality of integer columns
        def enforce_integer_columns(options = {})
          # first get the non-integers
          options[:allow_nil] = true
          args = build_validation_args(options, :numeric, :not_a_number)
          validates_numericality_of(*args)
          # now do the integers
          options[:only_integer] = true
          args = build_validation_args(options, :integer, :not_a_number)
          validates_numericality_of(*args)
        end
        
        # Enfore "not null" columns settings
        def enforce_not_null(options = {})
          args = build_validation_args(options, :not_null, :blank)
          validates_presence_of(*args)
       end
        
        # Enfore unique indexes
        def enforce_unique_indexes(options = {})
          attrs = build_validation_args(options, false, :taken)
          options = attrs.pop
          connection.indexes(table_name).select { |index| index.unique && index.columns.size == 1 && attrs.include?(index.columns.first.to_sym) }.each do |index|
            validates_uniqueness_of(index.columns.first, options)
          end
        end
        
        def build_validation_args(options, col_type, validation_option = :invalid)
          # Merge given options with defaults
          options = ActiveRecord::Validations::ClassMethods::DEFAULT_VALIDATION_OPTIONS.merge(options)
          options[validation_option] = ActiveRecord::Errors.default_error_messages[validation_option]
          options[:message] ||= options[validation_option]
          exclusion_regexp = options[:exclusion_regexp] || /(_at|_on|_id)$|^(id|position|type)$/
          # Determine which columns to validate and symbolize their names
          condition = case col_type
                      when :numeric
                        lambda { |col| col.name !~ exclusion_regexp && col.number? && col.type != :integer }
                      when :not_null
                        # I have to exclude boolean types because of a "feature" of the way validates_presence_of 
                        # handles boolean fields
                        # See http://dev.rubyonrails.org/ticket/5090 and http://dev.rubyonrails.org/ticket/3334
                        lambda { |col| (col.name !~ exclusion_regexp || col.name =~ /_id$/) && !col.null && col.type != :boolean }
                      else
                        lambda { |col| col.name !~ exclusion_regexp && col_type == col.type }
                      end
          cols_to_validate = col_type ? columns.find_all { |col| condition[col] } : columns
          # exclude columns
          if except = options[:except]
            except = Array(except).collect { |attr| attr.to_s }
            cols_to_validate = cols_to_validate.reject { |col| except.include?(col.name) }
          end
          attrs = cols_to_validate.collect { |col| col.name.to_sym }
          attrs << options
          attrs
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include Jls::Validations::EnforceSchemaRules
end
