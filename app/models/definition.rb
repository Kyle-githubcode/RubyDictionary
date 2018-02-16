class Definition < ApplicationRecord
	has_many :word_definitions
	has_many :words, through: :word_definitions

end
