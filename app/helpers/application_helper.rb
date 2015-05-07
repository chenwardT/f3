module ApplicationHelper

  # obj can be a Topic or Forum instance that is the last breadcrumb
  # i.e. user is currently viewing obj
  def breadcrumbs(obj)
    breadcrumb = []

    breadcrumb.push(obj)

    while obj.forum.present?
      obj = obj.forum
      breadcrumb.push(obj)
    end

    breadcrumb.reverse
  end
end
