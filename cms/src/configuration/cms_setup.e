note
	description: "Summary description for {CMS_SETUP}."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	CMS_SETUP

feature -- Access

	configuration: CMS_CONFIGURATION
			-- cms configuration.

	layout: CMS_LAYOUT
			-- CMS layout.

	is_html: BOOLEAN
			--  api with progressive enhancements css and js, server side rendering.
		deferred
		end

	is_web: BOOLEAN
			-- web: Web Site with progressive enhancements css and js and Ajax calls.
		deferred
		end

	modules: CMS_MODULE_COLLECTION
			-- List of available modules.
		deferred
		end

feature -- Access: Site

	site_id: READABLE_STRING_8

	site_name: READABLE_STRING_32

	site_email: READABLE_STRING_8

	site_url: READABLE_STRING_8

	site_dir: PATH

	site_var_dir: PATH

	files_location: PATH

	front_page_path: detachable READABLE_STRING_8
			-- Optional path defining the front page.
			-- By default "" or "/".

feature -- Access: Theme	

	themes_location: PATH

	theme_location: PATH

	theme_resource_location: PATH
			--

	theme_information_location: PATH
			-- theme informations.
		do
			Result := theme_location.extended ("theme.info")
		end

	theme_name: READABLE_STRING_32
			-- theme name

end