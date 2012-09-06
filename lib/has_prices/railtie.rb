module HasPrices
  class Railtie < Rails::Railtie
    initializer 'has_prices.model_prices_additions' do
      ActiveSupport.on_load :active_record do
        include ModelPricesAdditions
      end
    end
  end
end
