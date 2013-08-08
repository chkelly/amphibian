require 'net/smtp'

module Amphibian
  class Runner
    # TODO: log everything, and set log level, so we don't have to print anything
    # TODO: Email at the end

    def initialize(balancer_manager_url, test_page='/', test_regex=nil, dry_run=false)
      @balancer_manager_url = balancer_manager_url
      @test_page = test_page
      @test_regex = test_regex
      @dry_run = dry_run
      @errors = []

      @balancer_manager = BalancerManager.new(@balancer_manager_url, @dry_run)

      @min_hosts = -1
    end

    def do_check
      check
    end

private

    # Checks the balancer members, enabling/disabling each depending on the status.
    def check
      puts
      puts "Load Apache Balancer-Manager at '#{@balancer_manager_url}'"
      puts
      puts "Loading Details"
      puts
      puts "  Balancer: #{get_balancer_manager.balancer_name}"
      puts
      get_balancer_manager.hosts_with_status.each{|h,s| puts "  #{h} => #{s}"}

      @live_hosts = get_balancer_manager.enabled_hosts
      puts
      puts "Checking #{@live_hosts.size} live hosts"
      puts

      @live_hosts.each do |host, state|
        status = check_host(host, @test_page)
        puts "  #{host} is #{status ? 'OK' : 'not responsive. Disabling via BalancerManager.'}"
        disable_host(host) if !status
      end
      puts
      puts "#{@live_hosts.size}/#{get_balancer_manager.hosts.size} hosts are enabled"
      puts
    end

    def log_error(error)
      @errors << error
      puts "ERROR: #{error}"
    end

    # Returns the BalancerManager object.
    def get_balancer_manager
      @balancer_manager
    end

    # Checks a host with an optional path.
    # Checks for a 200 response, and that the body of the response matches the test regex, if defined.
    def check_host(host, path = '/', timeout = 5)
      begin
        status = Timeout::timeout(timeout) do
          Net::HTTP.start(URI.parse(host).host) do |http|
            response = http.get(path)

            if not response.code.match(/200/)
              log_error("Web Server down or not responding: #{response.code} #{response.message}")
              return false;
            end

            if @test_regex && ! response.body.match(@test_regex)
              log_error("The response did not contain the regex '#{@test_regex}'")
              return false
            end
          end
        end
      rescue SocketError => socket_error
        log_error("Error Connecting To Web: #{socket_error}")
        return false;
      rescue TimeoutError => timeout_error
        log_error("Timeout occured checking #{host}#{path} after #{timeout} seconds.")
        return false;
      rescue Exception => e
        log_error("An unknown error occured checking #{host}#{path}: #{e}")
        return false;
      end

      return true
    end

    # Disables a host from the balancer.
    def disable_host(host)
      if @live_hosts.size <= @min_hosts
        puts "Will not take #{host} down, alreay at lower limit #{@min_hosts}"
        return
      end

      #puts "Disabling host '#{host}'"
      get_balancer_manager.disable_host(host)
    end
  end
end

