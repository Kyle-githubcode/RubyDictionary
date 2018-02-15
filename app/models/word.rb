class Word < ApplicationRecord
	validates_presence_of :name
	validates_length_of :name, :within => 2..100
	validates_format_of :name, with: /[^\s]+/i
	validates_presence_of :definition
	validates_length_of :definition, :within => 2..200
end
