# coding: utf-8

require 'test_helper'

class ActiveRecordTest < ActiveSupport::TestCase
  def setup
    ActionMailer::Base.deliveries = []
  end

  def test_save_is_false_when_is_a_spam
    form = ActiveRecordForm.new(name: 'Carlos', email: 'is.valid@email.com', nickname: 'not_blank')
    assert form.valid?
    assert form.spam?
    assert !form.save
    assert_empty ActionMailer::Base.deliveries
  end

  def test_save_is_false_when_is_invalid
    form = ActiveRecordForm.new(name: 'Carlos', email: 'is.com')
    assert form.invalid?
    assert form.not_spam?
    assert !form.save
    assert_empty ActionMailer::Base.deliveries
  end

  def test_save_is_true_when_is_not_spam_and_valid
    form = ActiveRecordForm.new(name: 'Carlos', email: 'is.valid@email.com')
    assert form.valid?
    assert form.not_spam?
    assert form.save
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
