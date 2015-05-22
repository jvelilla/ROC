note
	description: "Request handler related to /blogs."
	author: "Dario B�sch <daboesch@student.ethz.ch>"
	date: "$Date: 2015-05-18 13:49:99 +0100 (lun., 18 mai 2015) $"
	revision: "$966167$"

class
	BLOG_HANDLER

inherit
	CMS_BLOG_CONFIG

	CMS_BLOG_HANDLER

	WSF_URI_HANDLER
		rename
			execute as uri_execute,
			new_mapping as new_uri_mapping
		end

	WSF_URI_TEMPLATE_HANDLER
		rename
			execute as uri_template_execute,
			new_mapping as new_uri_template_mapping
		select
			new_uri_template_mapping
		end

	WSF_RESOURCE_HANDLER_HELPER
		redefine
			do_get
		end

	REFACTORING_HELPER

create
	make

feature -- execute

	execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute request handler
		do
			execute_methods (req, res)
		end

	uri_execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute request handler
		do
			execute (req, res)
		end

	uri_template_execute (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Execute request handler
		do
			execute (req, res)
		end


feature -- HTTP Methods	
	do_get (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- <Precursor>
		local
			l_page: CMS_RESPONSE
			s: STRING
			n: CMS_NODE
			lnk: CMS_LOCAL_LINK
			hdate: HTTP_DATE
			page_number:NATURAL_16
		do
				-- At the moment the template is hardcoded, but we can
				-- get them from the configuration file and load them into
				-- the setup class.

			--Check if a page is given, if not start with page 1
			if req.path_info.ends_with_general ("/blogs") then
				-- No page number given, set to 0
				page_number := 1
			else
				-- Read page number from get variable
				page_number := page_number_path_parameter (req)
			end

			-- Ensure that page is never 0 (happens if /blogs/ is routed)
			if page_number = 0 then page_number := 1 end

			create {GENERIC_VIEW_CMS_RESPONSE} l_page.make (req, res, api)
			l_page.add_variable (node_api.nodes, "nodes")


			-- Output the title. If more than one page, also output the current page number
			create s.make_from_string ("<h2>Blog")
			if more_than_one_page then
				s.append (" (Page " + page_number.out + " of " + pages.out + ")")
				-- Get the posts from the current page (limited by entries per page)
			end
			s.append ("</h2>")


			if attached node_api.blogs_order_created_desc_limited (entries_per_page, (page_number-1) * entries_per_page) as lst then
				-- Filter out blog entries from all nodes
				--if n.content_type.is_equal ("blog") then
					s.append ("<ul class=%"cms-blog-nodes%">%N")
					across
						lst as ic
					loop
						n := ic.item
						lnk := node_api.node_link (n)
						s.append ("<li class=%"cms_type_"+ n.content_type +"%">")

						-- Post date (creation)
						if attached n.creation_date as l_modified then
							create hdate.make_from_date_time (l_modified)
							s.append (hdate.yyyy_mmm_dd_string)
							s.append (" ")
						end

						-- Author
						if attached n.author as l_author then
							s.append ("by ")
							s.append (l_author.name)
						end

						-- Title with link
						s.append (l_page.link (lnk.title, lnk.location, Void))

						-- Summary
						if attached n.summary as l_summary then
							s.append ("<p class=%"blog_list_summary%">")
							if attached api.format (n.format) as f then
								s.append (f.formatted_output (l_summary))
							else
								s.append (l_page.formats.default_format.formatted_output (l_summary))
							end
							s.append ("<br />")
							s.append (l_page.link ("See more...", lnk.location, Void))
							s.append ("</p>")
						end

						s.append ("</li>%N")
					end
					s.append ("</ul>%N")

					-- Show the pagination if there are more than one page
					if more_than_one_page then
						s.append ("<ul class=%"pagination%">")

					end
				--end
			end

			l_page.set_main_content (s)
			l_page.add_block (create {CMS_CONTENT_BLOCK}.make ("nodes_warning", Void, "/blogs/ is not yet fully implemented<br/>", Void), "highlighted")
			l_page.execute
		end

feature {NONE} -- Query

	more_than_one_page : BOOLEAN
			-- Checks if all posts fit on one page (FALSE) or if more than one page is needed (TRUE)
		do
			Result := entries_per_page < node_api.blogs_count
		end


	pages : NATURAL_16
			-- Returns the number of pages needed to display all posts
		require
			entries_per_page > 0
		local
			tmp: REAL_32
		do
			tmp := node_api.blogs_count.to_real / entries_per_page.to_real;
			Result := tmp.ceiling.to_natural_16
		end

	page_number_path_parameter (req: WSF_REQUEST): NATURAL_16
			-- Returns the page number from the path /blogs/{page}. It's an unsigned integere since negative pages are not allowed
		local
			s: STRING
		do
			if attached {WSF_STRING} req.path_parameter ("page") as p_page then
				s := p_page.value
				if s.is_natural_16 then
					Result := s.to_natural_16
				end
			end
		end

end
