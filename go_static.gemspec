Gem::Specification.new do |s|
  s.name              = "go_static"
  s.version           = "0.0.4"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Render views in Ruby on Rails written in html to an image (png, ...)"
  s.homepage          = "http://github.com/lleirborras/go_static"
  s.email             = "lleir@llegeix.me"
  s.authors           = [ "Lleir Borras Metje" ]

  s.files             = %w( README.md Rakefile MIT-LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
GoStatic uses the shell utility wkhtmltoimage to serve an image file to a user from HTML.
You simply write an HTML view as you would normally, and let GoStatic take care of the hard stuff.
desc
end
