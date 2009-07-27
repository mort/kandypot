# Learn more: http://github.com/javan/whenever

set :cron_log, File.expand_path(File.dirname(__FILE__) + "/log/cron.log")

every 1.hour do
  rake "kandypot:update_kandy_caches"
end
