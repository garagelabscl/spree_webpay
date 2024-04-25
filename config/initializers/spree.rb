# Configure Spree Preferences
#

# Configure Spree Dependencies
#
# Note: If a dependency is set here it will NOT be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will make the dependency value go away.
#
Rails.application.config.after_initialize do
  Rails.application.config.spree.payment_methods << Spree::Gateway::WebpayGateway
end
