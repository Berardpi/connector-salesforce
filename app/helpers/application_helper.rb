module ApplicationHelper

  def current_tenant
    return default_tenant unless session[:tenant]

    case session[:tenant]
    when 'nab'
      {nid: 'nab', name: 'NAB', copyright: '© NAB something'}
    else
      default_tenant
    end
  end

  def default_tenant
    {nid: 'maestrano', name: 'Maestrano', copyright: '© Copyright 2016 Maestrano Pty Ltd (ABN: 80 152 564 424). All rights reserved. Various trademarks held by their respective owners.'}
  end
end
