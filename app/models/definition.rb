class Definition < ApplicationRecord
	validates :text, :presence => true, :uniqueness => true
	has_many :word_definitions
	has_many :words, through: :word_definitions

end
