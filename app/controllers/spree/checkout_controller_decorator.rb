module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :load_data, only: :check_webpay
      base.before_action :check_webpay, only: :update
    end

    private
      def check_webpay
         if @order.payment?
          payment_method = Spree::PaymentMethod.find_by(type: "Spree::Gateway::WebpayGateway")
          redirect_to webpay_path if !payment_method.nil? && (payment_method.type.to_s == "Spree::Gateway::WebpayGateway") && (payment_method.id == payment_method_id = params[:order][:payments_attributes].first[:payment_method_id].to_i) 
          return
        end
      end

  end
end

if ::Spree::CheckoutController.included_modules.exclude?(Spree::CheckoutControllerDecorator)
  ::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
end
