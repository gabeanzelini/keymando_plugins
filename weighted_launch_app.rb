class WeightedLaunchApp
  def initialize( apps )
    @apps = apps.map{ |app| { app => 0 } }.reduce(&:merge)
  end

  def apps
    Hash[@apps.to_a.sort_by{ |pair| pair[1] }.reverse].keys
  end

  def run_using( item )
    @apps[item] += 1
    LaunchApp.new.run_using( item )
  end
end

def weighted_launch_app
  apps = []
  ["#{ENV['HOME']}/Applications","/Applications", "/Developer/Applications","/System/Library/CoreServices"].each do|catalog|
    find_all_items(catalog,".app",3){|item| apps << item}
  end

  @weighted_launch_app ||= WeightedLaunchApp.new apps

  command "Weighted Launch Application" do
    trigger_item_with(@weighted_launch_app.apps, @weighted_launch_app)
  end
end
