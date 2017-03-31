# name: discourse-theoreticalbot
# about: Brings the theoreticalbot account on allies.theoreticalaccountability.fm to life.
# version: 0.1
# author: Joe Buhlig joebuhlig.com
# url: https://www.github.com/joebuhlig/discourse-theoreticalbot

enabled_site_setting :theoreticalbot_enabled

add_admin_route 'theoreticalbot.title', 'theoreticalbot'

register_asset "stylesheets/theoreticalbot.scss"

Discourse::Application.routes.append do
	get '/admin/plugins/theoreticalbot' => 'admin/plugins#index', constraints: StaffConstraint.new
end

load File.expand_path('../lib/theoreticalbot/engine.rb', __FILE__)