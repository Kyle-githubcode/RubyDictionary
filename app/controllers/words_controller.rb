class WordsController < ApplicationController
  before_action :set_word, only: [:show, :edit, :update, :destroy]

  # GET /words
  # GET /words.json
  def index
    @words = Word.search(params[:term]).sort_by{|word| word.name}
  end

  # GET /words/1
  # GET /words/1.json
  def show
    @word = Word.find(params[:id])
  end

  # GET /words/new
  def new
    @word = Word.new
    @word_definition = @word.word_definitions.build
    @definitions = [@word_definition.build_definition]
  end

  # GET /words/1/edit
  def edit
    @word = Word.find(params[:id])
    @definitions = @word.definitions
  end

  # POST /words
  # POST /words.json
  def create
    @word = Word.new(word_params)
    unique_definitions = []
    @word.definitions.each do |definition|
      matching_definition = Definition.find_by_text(definition.text)
      if matching_definition.present?
        unique_definitions << matching_definition
      else
        unique_definitions << definition
      end
    end
    @word.definitions = unique_definitions

    respond_to do |format|
      if @word.save

        format.html { redirect_to @word, notice: 'Word was successfully created.'}
        format.json { render :show, status: :created, location: @word }
      else
        format.html { render :new }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /words/1
  # PATCH/PUT /words/1.json
  def update
    respond_to do |format|
      if @word.update(word_params)
        format.html { redirect_to @word, notice: 'Word was successfully updated.' }
        format.json { render :show, status: :ok, location: @word }
      else
        format.html { render :edit }
        format.json { render json: @word.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /words/1
  # DELETE /words/1.json
  def destroy
    @word.destroy
    respond_to do |format|
      format.html { redirect_to words_url, notice: 'Word was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_word
      @word = Word.find(params[:id])
    end

    #defines parameters for word and definition models
    def word_params
      params.require(:word).permit(:name, 
        definitions_attributes: [:id, :text]
        )
    end
end
