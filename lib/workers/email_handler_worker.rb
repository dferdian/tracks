class EmailHandlerWorker < BackgrounDRb::MetaWorker
  set_worker_name :email_handler_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(1.minutes) { update }
  end
  
  def update
    Emailer.check_pop
  end


end

