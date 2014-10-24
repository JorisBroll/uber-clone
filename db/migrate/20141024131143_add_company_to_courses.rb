class AddCompanyToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :company_id, :integer, default: 0
  end
end
