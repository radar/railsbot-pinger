require 'bundler'
Bundler.setup
require 'summer'
require 'pry'

class Bot < Summer::Connection
  def did_start_up
    sleep(30) # wait for nickserv auth
    ping_command
  end

  def nick
    'helpa'
  end

  def ping_command
    privmsg("!ping", nick)
    @ping_thread = Thread.new do
      puts "Waiting to hear back from #{nick}..."
      sleep(30)
      if @helpa_dead
        puts "Committing Seppuku!!"
        Process.kill("HUP", File.read("/tmp/summer-#{config[:nick]}.pid").to_i)
      else
        puts "#{nick} is DEAD! LONG LIVE #{nick}!"
        @helpa_dead = true
        Process.kill("HUP", File.read("/tmp/summer-#{nick}.pid").to_i)
        puts "WAITING FOR PING..."
        STDOUT.flush
        wait_and_ping
      end
    end
    @ping_thread.abort_on_exception = true
  end

  def pong_command(sender, channel, message)
    puts "helpa is ALIVE!"
    @helpa_dead = false
    @ping_thread.kill
    wait_and_ping
  end

  def wait_and_ping
    timeout = 60 # adjustable because debugging
    puts "Waiting #{timeout} seconds before attempting new ping."
    sleep(timeout)
    ping_command
  end
end

Bot.new(ARGV[0])
