note
	description: "Summary description for {HOME_CMS_RESPONSE}."
	date: "$Date$"
	revision: "$Revision$"

class
	HOME_CMS_RESPONSE

inherit

	CMS_RESPONSE
		redefine
			custom_prepare
		end

create
	make

feature -- Generation

	custom_prepare (page: CMS_HTML_PAGE)
		do
			page.register_variable (setup.api_service.recent_nodes (0, 5), "nodes")
		end

feature -- Execution

	process
			-- Computed response message.
		do
			set_title ("Home")
			set_page_title (Void)
		end
end

