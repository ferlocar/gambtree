class RandomGenerator
  include HTTParty
  base_uri 'random.org'
  
  def self.get_random_int max
    get("/integers", :query => {:num => 1, :min => 1, :max => max, :col => 1, :base => 10, :format => "plain", :rnd => "new"}).body.to_i
  end
end