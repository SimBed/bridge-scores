module ApplicationHelper
  def sortable(column, coltitle = nil)
    # e.g. 'name'.titleize  => "Name"
    # use a specified column title (if given) or else use the name of the database column formatted as a title ('titleized')
    coltitle ||= column.titleize
    # sort_colum and sort_direction are private methods of the controller
    css_class = column == sort_column ? "current #{sort_direction}" : "notcurrent"
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to coltitle, {sort: column, direction: direction}, {class: css_class}
end
end
