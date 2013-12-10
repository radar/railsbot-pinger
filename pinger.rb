require 'bundler'
Bundler.setup
require 'summer'
require 'pry'

class Bot < Summer::Connection
  def did_start_up
    ping_command
  end

  def ping_command
    privmsg("!ping", "logga")
    @ping_thread = Thread.new do
      puts "Checking helpa's pulse..."
      sleep(30)
      if @helpa_dead
        puts "Committing Seppuku!!"
        Process.kill("HUP", File.read("/tmp/summer-#{config[:nick]}").to_i)
      else
        puts "helpa is DEAD! LONG LIVE helpa!"
        @helpa_dead = true
        Process.kill("HUP", File.read("/tmp/summer-logga.pid").to_i)
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
    sleep(300)
    ping_command
  end
end

Bot.new(ARGV[0])