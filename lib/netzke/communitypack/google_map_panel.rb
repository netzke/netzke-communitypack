# Creates a google map panel. The panel additionaly has the options of google maps, i.e.:
# * +zoom_level+ - The initial zoom level
# * +gmap_type+ - 
# * +map_conf_opts+ - 
# * +map_controlls+ -
# * +set_center+ - The initial map position
# * +markers+ - Initial markers on the page
# ...
class Netzke::Communitypack::GoogleMapPanel < ::Netzke::Base
  js_base_class 'Ext.ux.GMapPanel'
  
	js_include "#{File.dirname(__FILE__)}/google_map_panel/javascript/GMapPanel.js"
	
	# default configuration
	def configuration
	  super.merge({
	    :zoom_level => 14,
			:gmap_type => 'map',
			:layout => :fit,
			:map_conf_opts => ['enableScrollWheelZoom','enableDoubleClickZoom','enableDragging'],
			:map_controls => ['GSmallMapControl','GMapTypeControl','NonExistantControl'],
			:set_center => {
				:geo_code_addr => 'Flottwellstr. 4-5, 10785 Berlin, Germany',
				:marker => {
					:title => 'pme Familienservice GmbH'
				}
			}
	  })
	end
end