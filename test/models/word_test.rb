require 'test_helper'

class WordTest < ActiveSupport::TestCase

	setup do
		@word  = Word.new({name: 'test-donotuse'})
  		@word_definition = @word.word_definitions.build
  		@definition = @word_definition.build_definition({text: 'testtext')
	end

	test "word_creation" do
		assert_equal "test-donotuse", @word.name
	end

	test "no_synonyms" do
	    assert_equal nil, @word.synonyms
	end

	test "search" do
		first_word = Word.first
		if first_word.present?
			assert Word.search(first_word.name).present?
		else
			assert true
		end
	end

end
