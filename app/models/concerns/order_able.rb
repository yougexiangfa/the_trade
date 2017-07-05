module OrderAble
  extend ActiveSupport::Concern

  included do
    belongs_to :buyer, polymorphic: true

    has_many :payment_orders, dependent: :destroy
    has_many :payments, through: :payment_orders
    has_many :order_items, dependent: :destroy, autosave: true

    enum payment_status: {
      unpaid: 0,
      part_paid: 1,
      all_paid: 2,
      refunded: 3
    }

    after_initialize if: :new_record? do |o|
      self.uuid = UidHelper.nsec_uuid('OD')
    end
  end


  def unreceived_amount
    self.amount - self.received_amount
  end

  def pending_payments
    Payment.where.not(id: self.payment_orders.pluck(:payment_id)).where(payment_method_id: self.buyer.payment_method_ids, state: ['init', 'part_checked'])
  end

end


