class WarsController < ApplicationController
  before_action :set_war, only: [:show, :edit, :update, :destroy,
                                 :plan, :update_attack, :ajax_plan]

  # GET /wars
  # GET /wars.json
  def index
    @wars = War.all
  end

  # GET /wars/1
  # GET /wars/1.json
  def show
  end

  # GET /wars/new
  def new
    @war = War.new
  end

  # GET /wars/1/edit
  def edit
  end

  # POST /wars
  # POST /wars.json
  def create
    filtered_params = war_params
    order = filtered_params.delete :order
    @war = War.new(filtered_params)
    @war.set_order(order)
    
    respond_to do |format|
      if @war.save
        format.html { redirect_to @war, notice: 'War was successfully created.' }
        format.json { render :show, status: :created, location: @war }
      else
        format.html { render :new }
        format.json { render json: @war.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wars/1
  # PATCH/PUT /wars/1.json
  def update
    respond_to do |format|
      if @war.update(war_params)
        format.html { redirect_to @war, notice: 'War was successfully updated.' }
        format.json { render :show, status: :ok, location: @war }
      else
        format.html { render :edit }
        format.json { render json: @war.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wars/1
  # DELETE /wars/1.json
  def destroy
    @war.destroy
    respond_to do |format|
      format.html { redirect_to wars_url, notice: 'War was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def update_attack
    @warriors.each do |w|
      next unless w.index.to_s == params[:index]
      if params[:state] == 'def'
        w.plans.where(base: params[:base]).delete_all
      else
        plan = w.plans.find_or_create_by(base: params[:base])
        plan.state = params[:state]
        plan.save
      end
    end
    set_war
    ajax_plan
  end

  def ajax_plan
    @plan = Array.new
    taken = Hash.new
    @warriors.each do |w|
      taken[w] = Array.new(@war.count, nil)
      w.plans.each do |p|
        @plan.append({index: w.index, base: p.base, state: p.state})
        taken[w][p.base] = p.state
      end
    end
    @war.strategy(taken).each do |w,b|
      next if taken[w][b]
      @plan.append({index: w.index, base: b, state: 'sug'})
    end
    @missing = Array.new
    @war.count.times do |i|
      i += 1
      if @plan.select { |p| p[:index] == i && p[:state] != 'no' }.empty?
        @missing.append("#index_#{i}")
      end
      if @plan.select { |p| p[:base] == i && p[:state] != 'no' }.empty?
        @missing.append("#base_#{i}")
      end
    end
    render :ajax_plan
  end
  
  def plan
    @plan = []
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_war
      @war = War.includes(:warriors, warriors: [:estimates, :plans]).find(params[:id])
      @warriors = @war.warriors
      @warriors.each_with_index do |w,i|
        w.index = i + 1
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def war_params
      params[:war].permit(:title, :order => [])
    end
end
