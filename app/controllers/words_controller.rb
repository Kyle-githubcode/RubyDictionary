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

  def import
    if params[:file].present?
      notice = 'CSV data was successfully uploaded.'
      begin
        log = Word.import(params[:file], params[:name_header], params[:definition_header])
      rescue Exception => error
        if error.message.match?(/\{.+\}/).present?
          log = eval error.message
        else
          log = {file_error: error.message}
        end
      end
      if log[:file_error].present?
        notice = ' Error processing file: ' + log[:file_error]
      end
      notice += "<br>" + log[:words_imported].to_s + " out of " + log[:word_total].to_s + " words imported" if log[:words_imported].present?
      notice += "<br>" + log[:words_updated].to_s + " words updated" if log[:words_updated].present?
      notice += "<br>" + log[:words_created].to_s + " words created" if log[:words_created].present?
      if log[:word_errors].present?
        notice += "<br> Word errors: <ul>" + log[:word_errors].keys.map{|name| '<li>' + name + ': ' + log[:word_errors][name].join + '</li>'}.join + '</ul>'
      end
      respond_to do |format|
        format.html { redirect_to words_url, notice: notice}
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to words_url, notice: 'CSV file not selected' }
        format.json { head :no_content }
      end
    end
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
    @word = Word.find_by_name(word_params[:name])
    if @word.present?
      @word.update(definitions_attributes: word_params[:definitions_attributes])
    else
      @word = Word.new(word_params)
    end
    @word.set_unique_definitions

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
