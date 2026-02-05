class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Soft delete functionality: marks a record as deleted instead of removing it from DB.
  def soft_delete
    update(deleted_at: Time.current) if has_attribute?(:deleted_at)
  end

  # We can't use 'default_scope' easily because it's hard to bypass,
  # but we can add a helper that models can use.
  def self.kept
    where(deleted_at: nil)
  end
end
