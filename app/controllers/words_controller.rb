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
    @definition = @word_definition.build_definition
  end

  # GET /words/1/edit
  def edit
    @word = Word.find(params[:id])
    @word_definitions = @word.word_definitions
  end

  # POST /words
  # POST /words.json
  def create
    @word = Word.new(word_params)
    @definition = Definition.find_by_text(params["word"]["word_definition"]["definition"]["text"])
    definition_id = @definition.present? ? @definition.id : nil
    @word_definition = @word.word_definitions.build(definition_id: definition_id)
    @definition = @word_definition.build_definition if @definition.blank?

    respond_to do |format|
      if @word.save
        if @definition.text.blank?
          @definition.update(definition_params)
        end

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
        #change this to batch update later
        @word.definitions.first.update(definition_params)
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

    #defines required parameters
    def word_params
      params.require(:word).permit(:name,
        word_definition_attributes: [:id,
          definition_attributes: [:id, :text]])
    end

    def definition_params
      params["word"]["word_definition"].require(:definition).permit(:text)
    end
end
