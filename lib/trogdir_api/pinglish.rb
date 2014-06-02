require 'pinglish'

module TrogdirAPI
  def self.pinglish_block
    Proc.new do |ping|
      ping.check :mongodb do
        Mongoid.default_session.command(ping: 1).has_key? 'ok'
      end
    end
  end
end