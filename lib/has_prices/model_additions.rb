module HasPrices
  module ModelPricesAdditions
    extend ActiveSupport::Concern

    module ClassMethods
      def priced(currency_id)
        where(["#{self.has_prices_options[:price_class].table_name}.currency_id = ?", currency_id]).joins(:prices)
      end

      def has_prices(*attrs)
        new_options = attrs.extract_options!
        options = {
          :fallback => false,
          :reader => true,
          :writer => false,
          :nil => '',
          :autosave => new_options[:writer],
          :price_class => nil
        }.merge(new_options)

        price_class_name =  options[:price_class].try(:get_price) || "#{self.model_name}Price"
        options[:price_class] ||= price_class_name.constantize

        options.assert_valid_keys([:fallback, :reader, :writer, :nil, :autosave, :price_class])

        belongs_to = self.model_name.demodulize.underscore.to_sym

        class_attribute :has_prices_options
        self.has_prices_options = options

        # associations, validations and scope definitions
        has_many :prices, :class_name => price_class_name, :dependent => :destroy, :autosave => options[:autosave]
        options[:price_class].belongs_to belongs_to
        options[:price_class].validates_presence_of :currency_id
        options[:price_class].validates_uniqueness_of :currency_id, :scope => :"#{belongs_to}_id"

        # Optionals delegated readers
        if options[:reader]
          attrs.each do |name|
            send :define_method, name do |*args|
              currency_id = args.first || get_currency_id_from_i18n
              price_to_get = self.get_price(currency_id)
              price_to_get.try(name) || has_prices_options[:nil]
            end
          end
        end

        # Optionals delegated writers
        if options[:writer]
          attrs.each do |name|
            send :define_method, "#{name}_before_type_cast" do
              price_to_set = self.get_price(get_currency_id_from_i18n, false)
              price_to_set.try(name)
            end

            send :define_method, "#{name}=" do |value|
              price_to_set = find_or_build_price(get_currency_id_from_i18n)
              price_to_set.send(:"#{name}=", value)
            end
          end
        end

      end
    end

    def find_or_create_price(currency_id)
      (find_price(currency_id) || self.has_prices_options[:price_class].new).tap do |t|
        t.currency_id = currency_id
        t.send(:"#{self.class.model_name.demodulize.underscore.to_sym}_id=", self.id)
      end
    end

    def find_or_build_price(currency_id)
      (find_price(currency_id) || self.prices.build).tap do |t|
        t.currency_id = currency_id
      end
    end

    def get_price(currency_id, fallback=has_prices_options[:fallback])
      find_price(currency_id) || (fallback && !prices.blank? ? prices.detect { |t| t.currency_id == 1 } || prices.first : nil)
    end

    def all_prices
      t = CURRENCY_HASH.map do |l_str, l_id|
        [l_id, find_or_create_price(l_id)]
      end
      ActiveSupport::OrderedHash[t]
    end

    def has_price?(currency_id)
      find_price(currency_id).present?
    end

    def find_price(currency_id)
      prices.detect { |t| t.currency_id == currency_id } || prices[0]
    end


    def get_currency_id_from_i18n
      CURRENCY_HASH[I18n.t("number.currency.iso").to_sym] || CURRENCY_HASH[:cad]
    end
  end
end
