#
# Framework detection methods
#
module WrapIt
  def self.framework
    return @framework unless @framework.nil?
    gems = Gem.loaded_specs.keys
    if gems.include?('rails')
      @framework = :rails
    elsif gems.include?('sinatra')
      @framework = :sinatra
    else
      @framework = :unknown
    end
  end

  def self.rails?
    framework == :rails
  end

  def self.sinatra?
    framework == :sinatra
  end
end
