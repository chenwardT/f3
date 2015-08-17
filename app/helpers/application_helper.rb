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

  # TODO: Cleanup this, or consider calling +breadcrumbs+ and replace last item
  def breadcrumbs_with_static_last(obj, last_item)
    breadcrumb = []
    breadcrumb.push(last_item)
    breadcrumb.push(obj.forum)
    obj = obj.forum

    while obj.forum.present?
      obj = obj.forum
      breadcrumb.push(obj)
    end

    breadcrumb.reverse
  end
end
