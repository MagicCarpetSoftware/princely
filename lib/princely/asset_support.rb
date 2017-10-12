module Princely
  module AssetSupport
    def localize_html_string(html_string, asset_path = nil)
      html_string = html_string.to_str
      # Make all paths relative, on disk paths...
      html_string.gsub!(".com:/",".com/") # strip out bad attachment_fu URLs
      html_string.gsub!( /src=["']+([^:]+?)["']/i ) do |m|
        asset_src = asset_path ? "#{asset_path}/#{$1}" : asset_file_path($1)
        %Q{src="#{asset_src}"} # re-route absolute paths
      end

      # Remove asset ids on images with a regex
      html_string.gsub!( /src=["'](\S+\?\d*)["']/i ) { |m| %Q{src="#{$1.split('?').first}"} }
      html_string
    end

    def asset_file_path(asset)
      # Remove /assets/ from generated names and try and find a matching asset
      Rails.application.assets ||= ::Sprockets::Railtie.build_environment(Rails.application)
      Rails.application.assets.find_asset(asset.gsub(%r{/assets/}, "")).try(:pathname) || asset
    end

    def asset_content(source)
      Rails.application.assets.find_asset(source).to_s
    end

    def pdf_stylesheet_link_tag(*sources)
      sources.collect do |source|
        source = asset_file_path(source)
        "<style type='text/css'>#{asset_content(source)}</style>"
      end.join("\n").html_safe
    end
  end
end
