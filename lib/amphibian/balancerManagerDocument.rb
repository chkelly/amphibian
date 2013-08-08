module Amphibian
  class BalancerManager

    def initialize(balancer_manager_url, dry_run = false)
      @balancer_manager_url = balancer_manager_url
      @dry_run = dry_run

      if !balancer_manager_url.match("127.0.0.1") && !dry_run
        @dry_run = true
        log_error
        log_error "Not running on localhost: Performing dry-run"
        log_error
      end
    end

    # Disables a host from the balancer.
    def disable_host(host)
      # TODO: Check Status
      toggle_host(host, 'Disable')
    end

    # Enables a host in the balancer
    def enable_host(host)
      # TODO: Check Status
      toggle_host(host, 'Enable')
    end

    # Returns an array of strings indicated the balancer members parsed out of the BalancerManager page.
    def hosts
      @hosts ||= (get_doc/'a').select{|a_tag| a_tag.inner_text =~ /^http:/}.map{|a_tag| a_tag.inner_text}
    end

    # Get an array of hosts that are in 'Ok' state
    #---
    # TODO: Optionally force refresh
    #+++
    def enabled_hosts
      hosts_array = []
      hosts_with_status.select{|host,state| state == 'Ok'}.each{|host, state| hosts_array << host}
      hosts_array
    end

    # Get an array of hosts that are not in 'Ok' state
    #---
    # TODO: Optionally force refresh
    #+++
    def disabled_hosts
      hosts_array = []
      hosts_with_status.select{|host,state| state != 'Ok'}.each{|host, state| hosts_array << host}
      hosts_array
    end

    # Returns the name of the balancer on the BalancerManager page.
    def balancer_name
      @balancer_name ||= (get_doc/'a').select{|a_tag| a_tag.inner_text =~ /^balancer:/}.map{|a_tag| a_tag.inner_text}[0].sub('balancer://', '')
    end

    # Returns the url of the BalancerManager page.
    def balancer_manager_url
      @balancer_manager_url
    end

    # TODO: Optionally force refresh
    def host_enabled?(host)
      enabled_hosts.include?(host)
    end

    # TODO: Optionally force refresh
    def host_disabled?(host)
      !enabled_hosts.include?(host)
    end

    def dry_run?
      @dry_run
    end

    def hosts_with_status
      host_to_status = {}
      (get_doc/'a').select{|a_tag| a_tag.inner_text =~ /^http:/}.each do |a_tag|
        host_to_status[a_tag.inner_text] = (a_tag.parent.parent.children[6].inner_text.strip)
      end
      host_to_status
    end

private

    # Sets the state of the host to the specified state
    def toggle_host(host, state)
      log_error("#{state} is an invalid state") if state != "Enable" && state != "Disable"
      run "curl -s -o /dev/null #{@balancer_manager_url}\?b=#{balancer_name}\\&w=#{host}\\&dw=#{state}"
      # TODO: Check status
    end

    # runs a command if not in a dry_run? mode.
    def run(cmd)
      #puts "#{dry_run? ? 'Dry ' : ''}Running: #{cmd}"
      if !dry_run?
        `#{cmd}`
      end
    end

    def log_error(error = "")
      puts "ERROR: #{error}"
    end

    # Returns the Hpricot document of the BalancerManager page.
    def get_doc
      @doc ||= begin
        Hpricot(open(@balancer_manager_url))
      rescue Exception => e
        if e =~ /403/
          log_error "Balancer Manager is getting a 403: Forbidden response.  Make sure it is accessable from this location."
        else
          log_error "Error opening the balancer manager: #{e}"
        end
        nil
      end
    end
  end
end

