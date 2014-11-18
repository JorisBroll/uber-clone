if Rails.env == "development"
    WickedPdf.config = {
      :wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
      :exe_path => '/usr/local/bin/wkhtmltopdf'
    }
end