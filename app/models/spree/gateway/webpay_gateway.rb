module Spree
  class Gateway::WebpayGateway < Gateway
    def actions
      %w[capture void]
    end

    def auto_capture?
      true
    end

    def source_required?
      false
    end

    def supports?(source)
      true
    end

    def provider_class
      self.class
    end

    def method_type
      "webpay"
    end

    def can_capture?(payment)
      ["checkout", "pending"].include?(payment.state)
    end

    def provider
      provider_class
    end

    def self.STATE
      "webpay"
    end

    def purchase(amount, transaction_details, options = {})
      ActiveMerchant::Billing::Response.new(true, "success", {}, {})
    end

    def capture(money_cents, response_code, gateway_options)
      ActiveMerchant::Billing::Response.new(true, "Transacción Aprobada", {}, {})
    end

    def perform_payment(payment_id)
      Rails.logger.info("[WEBPAY] PERFORM PAYMENT => payment_id: #{payment_id}")
      payment = Spree::Payment.find payment_id
      return unless payment
      order = payment.order

      begin
        payment.started_processing!
        payment.complete!(order.total)
        order.next! unless order.state == "completed"
        Rails.logger.info("[WEBPAY] PERFORM PAYMENT => order_id:#{order.id}, current_order_state: #{order.state}")
        Rails.logger.info("[WEBPAY] PERFORM PAYMENT => order_payments:#{order.payments.size}")
      rescue => e
        Rails.logger.error("[WEBPAY] perform_payment error on  #{order.number} enforcer processing")
        Rails.logger.error e
        false
      end
    end

    def modify_url_by_payment_type(url)
      return url if !["manual", "simplified"].include? preferred_payment_type

      url.sub! "/payment/show/", "/payment/#{preferred_payment_type}/"
    end

    def cancel(order_id)
      ActiveMerchant::Billing::Response.new(true, "Order has been cancelled.")
    end

    private

    def order_exists?(order_id)
      Spree::Order.exists?(number: order_id)
    end

    def order_paid? order_id
      order = Spree::Order.find_by_number(order_id)
      order.paid? || order.payments.completed.any?
    end
  end
end
