class SubscriptionsMailbox < ApplicationMailbox

  def process

    identifiers = {
      'Netflix' => ['netflix.com', 'netflix.com/YourAccount'],
      'Pipedrive' => ['pipedrive.com', 'zarin.pipedrive.com/settings/subscription/churn-shield?cancellation=true'],
    }

    image_url = ClearbitServices.new(identifiers[mail.subject].first, mail.subject).call

    subscription_hash = {
      title: mail.subject,
      start_date: Date.today,
      sub_type: regex_data[:sub_type],
      price: regex_data[:price].to_i,
      currency: regex_data[:currency],
      category: regex_data[:category],
      link: identifiers[mail.subject].last,
      image_url: image_url,
      notify_before: 1
    }

    create_subscriptions(user, subscription_hash)

  end

  private

  def create_subscriptions(user, subscription_hash)
    new_subscription = user.subscriptions.create!(subscription_hash)
    SendWhatsappMessage.new(user, "Chill Out, I'll take care of the **#{new_subscription.title}** subscription! \n Enjoy! ").call
  end

  def user
    @user ||= User.find_by(email: mail.from)
  end

  def regex_data
    @regex_data ||= mail.text_part.body.decoded.match(/(?<sub_type>(annual|monthly)).+(?<price>\d+.\d+).+(?<currency>(USD|EUR|AED)).+(?<category>(Entertainment|Education|Finance))/m)
  end

end

  # def process
  #   update_comments(task, mail.decoded)
  # rescue
  #   # Proper error handler here.
  # end

#   def update_comments(task, comment_string)
#     task.comments.create!(note: comment_string)
#   end

#   def find_task(subject)
#     task_id = subject.split("-").last.to_i
#     Task.find(task_id)
#   end
# end
