class Warrior < ActiveRecord::Base
   belongs_to :user
   belongs_to :war
   
   has_many :plans
   has_many :estimates

   default_scope { order(:order) }
   
   def index
     @index
   end

   def index=(i)
     @index = i
   end
   
   def user_name
     User.name_for(self.user_id)
   end
   
   def averages
     @averages || calc_averages
   end

   def average(base)
     averages[base]
   end

   def each_estimate(base)
     estimates.each do |e|
       next if e.base != base
       yield e
     end
   end

   def index_avg
     @index_avg || calc_index_avg
   end
   
   def calc_index_avg
     sum = 0
     averages.each do |a|
       sum += a
     end
     @index_avg = Integer((sum / averages.size) * 100 + 1)
   end

   def done_attacks
    done = 0
    plans.each do |p|
      done += 1 if p.state == 'done'
    end
    done
  end

   private
   
   def calc_averages
     @averages = []
     sums = Array.new(war.count, 0.0)
     count = Array.new(war.count, 0)
     estimates.each do |e|
       sums[e.base-1] += e.stars
       count[e.base-1] += 1
     end
     war.count.times do |i|
       if count[i] > 0
         @averages[i] = ((sums[i] / count[i] * 10).to_i / 10.0 + 0.55).floor
       else
         @averages[i] = 0
       end
     end
     @averages
   end
end
