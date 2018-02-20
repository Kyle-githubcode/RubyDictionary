require 'csv'
class Word < ApplicationRecord
	validates :name, :uniqueness => true, :presence => true
	validates_length_of :name, :within => 2..100
	validates_format_of :name, with: /[^\s]+/i

	has_many :word_definitions
	has_many :definitions, through: :word_definitions
	accepts_nested_attributes_for :definitions

	def self.import(file, name_header, definition_header)
		log = {:word_errors => {}}
		if file.path.end_with?('.csv')
			begin
				log[:words_imported] = 0
				log[:words_updated] = 0
				log[:words_created] = 0
				file_parameters = {:headers => true, :row_sep => :auto, :encoding => 'ISO-8859-1', skip_blanks: true, skip_lines: /[\n\r]+/}
				log[:word_total] = CSV.read(file.path, file_parameters).length rescue 0
				CSV.foreach(file.path, file_parameters) do |row|
					word = Word.find_by_name(row[name_header])
					if word.present?
						word.update(definitions_attributes: [text: row[definition_header]])
						log[:words_updated] += 1
					else
						word = Word.new(name: row[name_header], definitions_attributes: [text: row[definition_header]])
						log[:words_created] += 1
					end
					word.set_unique_definitions
					if word.save
						log[:words_imported] += 1
					else
						log[:word_errors][row[name_header]] = word.errors.full_messages
					end
				end
			rescue CSV::MalformedCSVError => csv_error
				log[:file_error] = csv_error.message
				raise csv_error, log.to_s, csv_error.backtrace
			end
		elsif file.path.end_with? '.xml'
			#code for importing xml data
		else
			log[:file_error] = 'File type not supported'
		end
		log
	end

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

	def set_unique_definitions
		unique_definitions = []
    	definitions.each do |original_definition|
      		matching_definition = Definition.find_by_text(original_definition.text)
      		if matching_definition.present?
        		unique_definitions << matching_definition
      		else
        		unique_definitions << original_definition
      		end
      	end
      	self.definitions = unique_definitions.uniq
	end

	def self.search(term)
	  if term
	    where('name LIKE ?', "%#{term}%")
	  else
	    all
	  end
	end

end
