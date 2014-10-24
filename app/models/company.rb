class Company < ActiveRecord::Base
	has_and_belongs_to_many :users
	has_many :courses, inverse_of: :company
	belongs_to :partner, inverse_of: :companies
end