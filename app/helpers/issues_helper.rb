module IssuesHelper
  require 'sanitize'
  def sanitize_text(html_code)
    Sanitize.fragment(html_code,
                      :elements => ['div', 'style','img','p','br','pre'],
                      :attributes => {'div' => ['style'],'img' => ['src','style'], 'pre'=>['class','data-pbcklang','data-pbcktabsize']},
                      :css => {:properties => ['height','width','float','background','border','solid','padding']})

  end
  def sanitize_text2(html_code)
    truncate(Sanitize.fragment(html_code), length: 50)
  end
end
