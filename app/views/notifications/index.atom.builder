unless @notifications.blank?
  atom_feed do |feed|
    feed.title("Notifications for #{@app.name} - Kandypot")
    feed.updated(@notifications.first.created_at)

    for notification in @notifications
      feed.entry(notification, :url => app_notification_url(@app, notification)) do |entry|
        entry.title(notification.title)
        entry.content(notification.body, :type => 'text')
        entry.category(notification.category)
      
        entry.author do |author|
          author.name('Kandypot')
          author.email("contact@kandypot.com")
        end
      
      end
    end
  end
end

