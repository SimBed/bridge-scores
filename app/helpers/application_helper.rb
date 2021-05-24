module ApplicationHelper
  def sortable(column:, coltitle: nil, view: nil, direction: 'asc')
    # e.g. 'name'.titleize  => "Name"
    # use a specified column title (if given) or else use the name of the database
    # column formatted as a title ('titleized')
    # keyword arguments used
    coltitle ||= column.titleize
    # sort_colum and sort_direction are private methods of the controller
    css_class = column == sort_column(view) ? "current #{sort_direction(direction: direction)}" : 'notcurrent'
    if column == sort_column(view) && sort_direction(direction: direction) == direction
      direction = opp_direction(direction)
    end
    link_to coltitle, { sort: column, direction: direction }, { class: css_class }
  end

  def opp_direction(direction)
    return 'desc' if direction == 'asc'

    'asc'
  end
end
