module TrogdirAPI
  def self.pinglish_block
    Proc.new do |ping|
      ping.check :mongodb do
        Mongoid.default_client.command(ping: 1).documents.any?{|d| d == {'ok' => 1}}
      end
    end
  end
end
