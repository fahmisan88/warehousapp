task :check_expiry => :environment do
  start_time = Time.now
  users_count = User.count
  users_renew = User.where(["expiry < :time and status = 1", { time: start_time }]).count
  log = ActiveSupport::Logger.new("log/account_renewal_#{start_time.strftime('%v')}.log")

  log.info "Task started at #{start_time}"
  log.info "Users need renew: #{users_renew}/#{users_count}\n"

  User.where(["expiry < :time and status = 1", { time: start_time }]).find_each(batch_size: users_renew) do |user|
    user.update_attribute(:status, 4)
    user.update_attribute(:bill_id, nil)
    user.update_attribute(:bill_url, nil)
    user.update_attribute(:package, nil)
    log.info "User ID: #{user.ezi_id} - Email: #{user.email}"
  end

  end_time = Time.now
  duration = (end_time - start_time)/1.minute
  log.info "\nTask finished at #{end_time} and last #{duration} minutes."

end
