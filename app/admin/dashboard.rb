ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    div do
      panel "Welcome to the F3 Admin Control Panel" do
        span "Service Metrics"
      end

      panel "Quick Administrator Links" do
        div "Server Load Averages"
        div "Find User"
        div "Find Phrase"
      end
    end

    columns do
      column do
        panel "Recent Topics" do
          ul do
            Topic.order(created_at: :desc).limit(5).map do |topic|
              li link_to(topic.title, topic_path(topic))
            end
          end
        end
      end

      column do
        panel "Info" do
          para "Set me up!"
        end
      end
    end
  end # content
end
