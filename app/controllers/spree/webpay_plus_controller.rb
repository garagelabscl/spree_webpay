module Spree
    class WebpayPlusController < StoreController
        skip_before_action :verify_authenticity_token
        before_action :load_data, only: %i[success failure, commit]

        def initialize
            super 
            @transaction = ::Transbank::Webpay::WebpayPlus::Transaction.new(::Transbank::Common::IntegrationCommerceCodes::WEBPAY_PLUS, ::Transbank::Common::IntegrationApiKeys::WEBPAY, :integration)
            @ctrl = "webpay_plus"

        end
        
        def create
            @buy_order = current_order&.number
            @session_id = "#{@buy_order}_#{rand(1_111_111..9_999_999).to_s}"
            @amount = current_order&.webpay_amount
            @return_url = "#{root_url}#{@ctrl}/commit"
            @response = @transaction.create(@buy_order, @session_id, @amount, @return_url)
            token = @response['token']
            url   = @response['url']
            if token.present? && url.present?
                current_order&.create_webpay_payment if !current_order.payments.any?
                @response = Net::HTTP.post_form(URI(url.to_s), token_ws: token.to_s)
                @payment = current_order.payments.order(:id).last if current_order
                @payment&.update(provider_token: token)
                render html: @response.body.html_safe
            else
                redirect_to webpay_failure_path({TBK_ORDEN_COMPRA: @buy_order})
            end
            nil
        end
        
        def commit
          if @order.blank?
            @payment = Spree::Payment.find_by(provider_token: params[:token_ws])
            @order = @payment.order if @payment
          end
          redirect_to completion_route and return if @order.completed?
          token_tbk = params[:token_ws]
          provider = Spree::Gateway::WebpayGateway.new
          begin
            webpay_results = @transaction.commit(token_tbk)
          rescue => e
            Rails.logger.error "[WEBPAY] Error in Payment (provider) #{e.message}"
            redirect_to webpay_failure_path(webpay_params(params)) and return
          end
            if webpay_results
                if webpay_results["status"] == "AUTHORIZED" && webpay_results["response_code"] == 0
                  @order = Spree::Order.find_by(number: webpay_results["buy_order"].to_s)
                  @payment = @order.payments.order(:id).last if @order
                  unless %w[failed invalid].include?(@payment.state)
                    @payment.update(public_metadata: webpay_results)
                    Rails.logger.info "payment_state:#{@payment.state} || order_state:#{@order.state}" if @payment && @order
                    success_payment = provider.perform_payment(@payment.id)
        
                    if !success_payment
                      Rails.logger.error "[WEBPAY] processing perform_payment error order: #{@order.number} NOTE: show complete to client"
                    end
        
                    @token = token_tbk
                    redirect_to webpay_success_path(webpay_params(params).merge(object_id: @order.number)) and return
                  end
                else
                  Rails.logger.error "[WEBPAY] Error in Payment (webpay_results) #{@payment.try(:id)} - #{@payment.try(:order).try(:number)}"
                  redirect_to webpay_failure_path(webpay_params(params)) and return
                end
            end
        end
        
        def refund
            @token = params[:token]
            @amount = params[:amount]
            @resp = @transaction.refund(@token, @amount)
            redirect_to webpay_plus_refund_path(token: @token, amount: @amount, resp: @resp)
        end
        
        def show_refund
            @token = params[:token]
            @amount = params[:amount]
            @resp = params[:resp]
        end
        
        def status
            @req = params.as_json
            @token = params[:token]
            @resp = @transaction.status(@token)
  
        end

        
        # GET spree/webpay/failure
        def failure
            @rejected = params[:rejected] == "true"
            @order = Spree::Order.find_by(number: params[:TBK_ORDEN_COMPRA]) if params[:TBK_ORDEN_COMPRA].present?
    
            if @order.nil?
              @payment = Spree::Payment.find_by provider_token: params[:token_ws] if params[:token_ws]
              @order = @payment.order if @payment
            end
        end

        def success
            session[:order_id] = nil
            @current_order = nil
      
            redirect_to root_path and return if @payment.blank?
      
            Rails.logger.info "payment_state:#{@payment.state} || order_state:#{@order.state}" if @payment && @order
            Rails.logger.info "[WebpayController : Success] - Order: #{@order.number}" if @order
            Rails.logger.info "[WebpayController : Success] - Order: #{@order.state}" if @order
      
            if @payment.failed?
              if current_order.present?
                redirect_to webpay_failure_path(webpay_params(params).merge(rejected: true)) and return
              end
            elsif @order.completed?
              flash.notice = Spree.t(:order_processed_successfully)
              redirect_to completion_route and return
            else
              redirect_to webpay_failure_path(webpay_params(params).merge(rejected: true)) and return
            end
          end

        private
            def webpay_params(params)
              params.permit(:object_id, :token_ws, :TBK_TOKEN, :TBK_ORDEN_COMPRA, :TBK_ID_SESION)
            end
            # Same as CheckoutController#completion_route
            def completion_route
                spree.order_path(@order)
            end

            def load_data
                @order = Spree::Order.find_by number: params[:TBK_ORDEN_COMPRA]
                @payment = @order.payments.order(:id).last if @order
                if @payment.nil?
                  @payment = Spree::Payment.find_by provider_token: params[:token_ws] if params[:token_ws]
                  @order = @payment.order if @payment
                end
            end
    
    end
end