# 数据定期清理
# 改变数据动作：
#   * 新增(check)
#   * 更新数量
#   * 选择或更换优惠券
#   * 选择服务
module RailsTrade::Cart
  extend ActiveSupport::Concern

  included do
    attribute :retail_price, :decimal, default: 0, comment: '汇总：原价'
    attribute :discount_price, :decimal, default: 0, comment: '汇总：优惠'
    attribute :bulk_price, :decimal, default: 0, comment: ''
    attribute :total_quantity, :decimal, default: 0
    attribute :deposit_ratio, :integer, default: 100, comment: '最小预付比例'
    attribute :payment_strategy_id, :integer

    belongs_to :organ, optional: true
    belongs_to :user
    belongs_to :member, optional: true
    belongs_to :address, optional: true
    belongs_to :payment_strategy, optional: true
    has_many :orders, dependent: :nullify
    has_many :promote_carts, -> { valid }, dependent: :destroy
    has_many :promotes, through: :promote_carts

    validates :deposit_ratio, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  end

  def compute_amount
    #self.retail_price = trade_items.checked.sum(:retail_price)
    #self.discount_price = trade_items.checked.sum(:discount_price)
    #self.bulk_price = self.retail_price - self.discount_price
    #self.total_quantity = trade_items.checked.sum(:original_quantity)

    self.item_amount = trade_items.checked.sum(:amount)
    self.overall_additional_amount = trade_promotes.default_where('amount-gte': 0).sum(:amount)
    self.overall_reduced_amount = trade_promotes.default_where('amount-lt': 0).sum(:amount)
    self.amount = item_amount + overall_additional_amount + overall_reduced_amount
  end

  class_methods do

    def default
      find_by(default: true)
    end

  end

end
