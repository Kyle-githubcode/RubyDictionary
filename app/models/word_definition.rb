class WordDefinition < ApplicationRecord
	belongs_to :word
    belongs_to :definition
    validates_presence_of :word
    validates_presence_of :definition
    accepts_nested_attributes_for :definition

end
