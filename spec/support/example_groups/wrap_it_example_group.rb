#
# Helpers for WrapIt testing
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#
module WrapItExampleGroup
  def self.included(base)
    base.instance_eval do
      metadata[:type] = :wrap_it

      after { @successor = nil }

      let(:template) { Object.new }

      let(:successor_class) { Class.new described_class }

      let(:wrapper_class) do
        mod = described_class
        Class.new(WrapIt::Base) { include mod }
      end
    end
  end

  def successor(*args, &block)
    @successor ||= successor_class.new(template, *args, &block)
  end

  def wrapper(*args, &block)
    @wrapper ||= wrapper_class.new(template, *args, &block)
  end

  RSpec.configure do |config|
    config.include(
      self,
      type: :wrap_it,
      example_group: { file_path: /spec/ }
    )
  end
end
