class Word < ApplicationRecord
	validates_presence_of :name
	validates_length_of :name, :within => 2..100
	validates_format_of :name, with: /[^\s]+/i

	has_many :word_definitions
	has_many :definitions, through: :word_definitions
	accepts_nested_attributes_for :word_definitions

	def definition
		return '' if definitions.blank?
		definitions.first.text
	end

	def synonyms
		synonyms = []
		definitions.each do |definition_object|
			synonym_words = Word.select{|word| word.definitions.include?(definition_object)}
			synonym_words.each do |synonym|
				synonyms << synonym.name
			end
		end
		synonyms.delete(name)
		synonyms
	end

	def self.search(term)
	  if term
	    where('name LIKE ?', "%#{term}%").order('name')
	  else
	    all
	  end
	end

end
