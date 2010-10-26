require File.join(File.dirname(__FILE__), 'test_setup')

class TestTableTest < Test::Unit::TestCase
  
  def setup
    EnforceSchema::UniqueRule.delete_all
  end
  
  def test_column_limit
    model = EnforceSchema::AllRules.new
    model.string_column = "long string"
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "is too long (maximum is 5 characters)", model.errors.on(:string_column)
  end
  
  def test_not_null_attribute
    model = EnforceSchema::NotNullRule.new
    model.not_null_column = nil
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "can't be blank", model.errors.on(:not_null_column)
  end
  
  def test_not_null_foreign_key
    model = EnforceSchema::NotNullRule.new
    model.not_null_foreign_key_id = nil
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "can't be blank", model.errors.on(:not_null_foreign_key_id)
  end
  
  def test_integer_with_string
    model = EnforceSchema::AllRules.new
    model.integer_column = "i'm obviously not an int"
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "is not a number", model.errors.on(:integer_column)
  end
  
  def test_integer_with_float
    model = EnforceSchema::AllRules.new
    model.integer_column = 5.645
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "is not a number", model.errors.on(:integer_column)
  end
  
  def test_float_with_string
    model = EnforceSchema::AllRules.new
    model.float_column = "blah"
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "is not a number", model.errors.on(:float_column)
  end
  
  def test_float_with_int
    model = EnforceSchema::AllRules.new
    model.float_column = 5
    assert model.save
  end
  
  def test_custom_message
    model = EnforceSchema::StringRule.new
    model.string_column = "another long string"
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "custom message", model.errors.on(:string_column)
  end
  
  def test_unique
    EnforceSchema::UniqueRule.create(:string_column => 'blah')
    model = EnforceSchema::UniqueRule.new(:string_column => 'blah')
    assert !model.save
    assert_equal 1, model.errors.count
    assert_equal "has already been taken", model.errors.on(:string_column)
  end
  
  def test_created_at
    model = EnforceSchema::AllRules.new
    assert model.save
    assert_not_nil model.created_at
  end

end
