class AddProviderTokenToSpreePayments < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_payments, :provider_token, :string
  end
end
