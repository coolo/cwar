class MainController < ApplicationController

  skip_before_filter :require_user, :only => [:index, :set_user]
  
  def index
    if session[:current_user_id]
      redirect_to :current
    else
      @user = User.new
    end
  end
  
  def set_user
    @user = User.find(params[:user][:id])
    if @user.password && @user.password != params[:user][:password]
      Rails.logger.debug "Password '#{@user.password}' != '#{params[:user][:password]}'"
      redirect_to action: :index, password_required: 1, user: @user.id
      return
    end
    session[:current_user_id] = @user.id
    redirect_to :current
  end

  def logout
    session.delete :current_user_id
    redirect_to :index
  end
  
  def current_plan
    war=War.last
    if war.started
      redirect_to plan_war_path(war)
    elsif war.done
      redirect_to done_war_path(war)
    else
      redirect_to :current
    end
  end

  def war
    @war = War.last
    if @war.started
      redirect_to plan_war_path(@war) and return
    end
    @estimates = Hash.new
    @war.warriors.each do |w|
      @estimates[w] = { 0 => [], 1 => [], 2 => [], 3 => [] }
      w.estimates.where(user: @user).each do |e|
        @estimates[w][e.stars].append(e.base)
      end
    end
  end

  def fillin(estimates, value, range)
    return false if range.blank?
    range.split(',').each do |r|
      if r.end_with? '-'
        r = r[0, r.length-1].to_i
        while r <= estimates.size
          estimates[r] = value
          r = r +1
        end
      else
        estimates[r.to_i] = value
      end
    end
    return true
  end
  
  def estimate
    @war = War.find(params[:war_id])
    @war.warriors.each do |w|
      estimates = Hash.new
      @war.warriors.size.times { |i| estimates[i+1] = 0 }
      seenone = fillin(estimates, 2, params[:twos][w.id.to_s])
      seenone = fillin(estimates, 3, params[:threes][w.id.to_s]) || seenone
      w.transaction do
        w.estimates.where(user: @user).delete_all
        if seenone
          estimates.each_pair do |base,value|
            w.estimates.build user: @user, base: base, stars: value
          end
          w.save
        end
      end
    end
    redirect_to :current
  end
  
end
