Spree::Core::Engine.add_routes do
  # Add your extension routes here
  get '/webpay_plus/create', to: 'webpay_plus#create', as: :webpay
  get '/webpay_plus/commit', to: 'webpay_plus#commit'
  get '/webpay_plus/status', to: 'webpay_plus#status'
  post '/webpay_plus/refund', to: 'webpay_plus#refund'
  get '/webpay_plus/refund', to: 'webpay_plus#show_refund'
  get '/webpay_plus/failure', to: 'webpay_plus#failure', as: :webpay_failure
  get '/webpay_plus/success', to: 'webpay_plus#success', as: :webpay_success
end
