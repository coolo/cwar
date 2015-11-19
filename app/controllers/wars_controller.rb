class WarsController < ApplicationController
  before_action :set_war, only: [:show, :edit, :update, :destroy,
                                 :plan, :update_attack, :ajax_plan,
                                 :freeze, :result, :done, :set_done]
  before_action :require_password, only: [:edit, :index, :create, :update, :freeze]

  def require_password
    unless @user.password
      redirect_to :index
    end
  end
  
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
        plan.user = @user
        plan.save
      end
    end
    set_war
    ajax_plan
  end

  def _calc_plan
    @plan = Array.new
    taken = Hash.new
    @warriors.each do |w|
      taken[w] = Array.new(@war.count, nil)
      w.plans.each do |p|
        hash = {index: w.index, base: p.base, state: p.state}
        hash[:stars] = p.stars if p.state == 'done'
        @plan.append(hash)
        taken[w][p.base] = p.state
      end
    end
    taken
  end
  
  def ajax_plan
    taken = _calc_plan
    @war.strategy(taken).each do |w,b|
      next if taken[w][b]
      @plan.append({index: w.index, base: b, state: 'sug'})
    end

    @missing = Array.new
    done_bases = Array.new
    nr_finished = Hash.new
    @plan.select { |p| p[:state] == 'done' }.each do |p|
      nr_finished[p[:index]] = (nr_finished[p[:index]] || 0) + 1
      done_bases << p[:base] if p[:stars] == 3
    end
    @finished = Array.new
    nr_finished.each { |index, nr|
      @finished << index if nr == 2 
    }
    @war.count.times do |i|
      i += 1
      if @plan.select { |p| p[:index] == i && p[:state] != 'no' }.empty?
        @missing.append("#index_#{i}")
      end
      
      if @plan.select { |p| p[:base] == i && %w(sure sug).include?(p[:state]) }.empty?
        next if done_bases.include? i
        @missing.append("#base_#{i}")
      end
    end
    render :ajax_plan
  end
  
  def plan
    if @war.done
      redirect_to done_war_path(@war) and return
    end
    @plan = []
  end

  def set_done
    unless @war.started && @user.name == 'Troyz'
      Rails.logger.error "not allowing set_done for #{@user.name}"
      redirect_to :current and return
    end

    @war.warriors.each do |w|
      keep = Array.new
      w.plans.each do |p|
        keep << w.estimates.where(base: p.base).all
      end
      keep.flatten!
      w.estimates.where.not(id: keep).delete_all
    end
    @war.done = true
    @war.save
    redirect_to done_war_path(@war)
  end
  
  def done
    unless @war.done
      redirect_to :current
    end
  end

  def freeze
    taken = _calc_plan
    @war.strategy(taken).each do |w,b|
      plan = w.plans.create(base: b, state: 'sure')
    end
    # ignore blacklist
    Plan.where(warrior_id: @war.warriors, state: 'no').delete_all
    @war.started = true
    @war.save
    redirect_to plan_war_path(@war)
  end

  def result
    plan = Plan.where(warrior_id: params[:index], base: params[:base]).first_or_create
    plan.state = 'done'
    plan.user = @user
    plan.th = params[:townhall] == 'true'
    plan.percent = params[:percent]
    plan.stars = 0
    if plan.percent == 100
      plan.stars = 3
      plan.th = true
    elsif plan.percent >= 50
      plan.stars = 1
      plan.stars += 1 if plan.th
    end
    plan.save
    render json: {}
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
