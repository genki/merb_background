if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  dependency 'merb-slices', :immediate => true
  Merb::Plugins.add_rakefiles "merb_background/merbtasks", "merb_background/slicetasks", "merb_background/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :merb_background
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:merb_background][:layout] ||= :merb_background
  
  # All Slice code is expected to be namespaced inside a module
  module MerbBackground

    # Slice metadata
    self.description = "a merb slice for background-fu"
    self.version = "0.0.1"
    self.author = "maiha"

    Config = Mash.new(
                      :cleanup_interval => :on_startup,
                      :monitor_interval => 10
                      )
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      require 'merb_background/job'
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(MerbBackground)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :merb_background_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # example of a named route
      scope.match('/index(.:format)').to(:controller => 'main', :action => 'index').name(:index)
      # the slice is mounted at /merb_background - note that it comes before default_routes
      scope.match('/').to(:controller => 'main', :action => 'index').name(:home)
      # enable slice-level default routes by default
      scope.default_routes
    end
    
  end
  
  # Setup the slice layout for MerbBackground
  #
  # Use MerbBackground.push_path and MerbBackground.push_app_path
  # to set paths to merb_background-level and app-level paths. Example:
  #
  # MerbBackground.push_path(:application, MerbBackground.root)
  # MerbBackground.push_app_path(:application, Merb.root / 'slices' / 'merb_background')
  # ...
  #
  # Any component path that hasn't been set will default to MerbBackground.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  MerbBackground.setup_default_structure!
  
  # Add dependencies for other MerbBackground classes below. Example:
  # dependency "merb_background/other"
  
end
