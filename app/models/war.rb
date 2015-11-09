class War < ActiveRecord::Base
  has_many :warriors, dependent: :delete_all
  has_many :estimates

  def count
    @count || @count = self.warriors.size
  end
  
  def set_order(order)
    self.warriors = []
    index = 1
    order.each do |id|
      self.warriors.build(user: User.find(id), order: index)
      index = index + 1
    end
  end
  
  def update(params)
    set_order(params.delete :order)
    super
  end

  def _warrior_busy(bases)
    bases.each do |b|
      return true if b == 'sure'
    end
    false
  end
  
  def strategy(taken)
    @ret = Hash.new
    sorted = self.warriors.sort { |a,b| b.index_avg <=> a.index_avg }
    attacked = Array.new
    taken.each do |w, bases|
      bases.each_with_index do |b,index|
        attacked[index] = 1 if b == 'sure'
      end
    end
    sorted.each do |w|
      next if _warrior_busy(taken[w])
      next_base = 1
      while next_base <= self.count && (taken[w][next_base] == "no" || attacked[next_base] || w.average(next_base-1) < 2.5)
        next_base += 1
      end
      next if next_base > self.count
      attacked[next_base] = 1
      @ret[w] = next_base
    end
    @ret
  end
end
