class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.where(abandoned_at: nil)
        .where('updated_at < ?', THREE_HOURS)
        .update_all(abandoned_at: Time.current)

    Rails.logger.info "Marcados #{Cart.where.not(abandoned_at: nil).where('abandoned_at > ?', THREE_HOURS).count} carrinhos como abandonados."
  end

  def remove_old_abandoned_carts
    removed_count = Cart.where('abandoned_at < ?', SEVEN_DAYS).destroy_all.count
    Rails.logger.info "Removidos #{removed_count} carrinhos abandonados."
  end
end
