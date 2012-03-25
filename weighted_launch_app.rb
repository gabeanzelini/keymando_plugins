require 'yaml'


class WeightedLaunchApp
  attr_accessor :file_name

  def initialize( apps )
    self.apps = apps
  end
  
  def apps=( apps )
    @file_name = File.join Preferences.keymando_directory, ".weighted_launch_app"
    weights = load_rankings
    @apps = apps.map{ |app| { app => weights[app.original] || 0 } }.reduce(&:merge)
  end

  def apps
    Hash[@apps.to_a.sort_by{ |pair| pair[1] }.reverse].keys
  end

  def load_rankings
    YAML.load_file @file_name
  end

  def save_rankings
    ranking = @apps.map{ |display_item, value| { display_item.original => value } }.reduce( &:merge )
    File.open( @file_name, 'w' ){ |f| f.puts ranking.to_yaml }
  end

  def run_using( item )
    @apps[item] += 1
    save_rankings
    LaunchApp.new.run_using( item )
  end
end

def get_apps
  apps = []
  ["#{ENV['HOME']}/Applications","/Applications", "/Developer/Applications","/System/Library/CoreServices"].each do|catalog|
    find_all_items(catalog,".app",3){|item| apps << item}
  end
  apps
end

def weighted_launch_app
  command "Weighted Launch Application" do
    @weighted_launch_app ||= WeightedLaunchApp.new get_apps
    app = Accessibility::Gateway.get_active_application
    apps = @weighted_launch_app.apps.reject{ |a| a.to_s == app.title }
    trigger_item_with(apps, @weighted_launch_app)
  end
end
