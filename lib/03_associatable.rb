require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.capitalize.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {
      foreign_key: "#{name}_id".to_sym,
      class_name: name.to_s.camelcase,
      primary_key: :id
    }

    options = default.merge(options)
    options.each { |var, value| self.instance_variable_set("@#{var}", value) }
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {
      foreign_key: "#{self_class_name.downcase}_id".to_sym,
      class_name: "#{name}".singularize.capitalize,
      primary_key: :id
    }

    options = default.merge(options)
    options.each { |var, value| self.instance_variable_set("@#{var}", value) }
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    assoc_options[name] = BelongsToOptions.new(name, options)
    fk = assoc_options[name].foreign_key

    define_method(name) do
      fk_value = self.send(fk)
      self.class.assoc_options[name].model_class.where(id: fk_value).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    fk = options.foreign_key
    define_method(name) do
      options.model_class.where(fk => self.id)
    end
  end

  def assoc_options
    @options ||= {}
  end
end

class SQLObject
  extend Associatable
end
