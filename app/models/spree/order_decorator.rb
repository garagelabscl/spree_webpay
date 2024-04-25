module Spree
  module OrderDecorator

    # Entrega en valor total en un formato compatible con el estandar de Webpay
    #
    # Return String instance
    def webpay_amount
      total.to_i
    end

    # Crea un pago con el metodo de pago Webpay
    def create_webpay_payment
      pay_method = Spree::PaymentMethod.find_by(type: "Spree::Gateway::WebpayGateway")
      unless pay_method.nil?
        if !payments.where(payment_method_id: pay_method.id).any?
          new_payment = Spree::Payment.new
          payments << new_payment
          new_payment.amount = self.total
          new_payment.payment_method_id = pay_method.id
          new_payment.save
        else
          payments.where(payment_method_id: pay_method.id).update_all(amount: self.total)
        end
      end
    end
  end
end
::Spree::Order.prepend Spree::OrderDecorator if ::Spree::Order.included_modules.exclude?(Spree::OrderDecorator)
