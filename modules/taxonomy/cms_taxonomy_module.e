note
	description: "[
			Taxonomy module managing vocabularies and terms.
		]"
	date: "$Date: 2015-05-22 15:13:00 +0100 (lun., 18 mai 2015) $"
	revision: "$Revision 96616$"

class
	CMS_TAXONOMY_MODULE

inherit
	CMS_MODULE
		rename
			module_api as taxonomy_api
		redefine
			register_hooks,
			initialize,
			install,
			uninstall,
			taxonomy_api
		end

	CMS_HOOK_MENU_SYSTEM_ALTER

	CMS_HOOK_RESPONSE_ALTER

create
	make

feature {NONE} -- Initialization

	make
		do
			version := "1.0"
			description := "Taxonomy solution"
			package := "core"
--			add_dependency ({CMS_NODE_MODULE})
		end

feature -- Access

	name: STRING = "taxonomy"

feature {CMS_API} -- Module Initialization			

	initialize (api: CMS_API)
			-- <Precursor>
		do
			Precursor (api)
			create taxonomy_api.make (api)
		end

feature {CMS_API} -- Module management

	install (api: CMS_API)
		do
				-- Schema
			if attached {CMS_STORAGE_SQL_I} api.storage as l_sql_storage then
				l_sql_storage.sql_execute_file_script (api.module_resource_location (Current, (create {PATH}.make_from_string ("scripts")).extended ("install").appended_with_extension ("sql")), Void)
				if l_sql_storage.has_error then
					api.logger.put_error ("Could not install database for taxonomy module", generating_type)
				end
				Precursor (api)
			end
		end

	uninstall (api: CMS_API)
			-- (export status {CMS_API})
		do
			if attached {CMS_STORAGE_SQL_I} api.storage as l_sql_storage then
				l_sql_storage.sql_execute_file_script (api.module_resource_location (Current, (create {PATH}.make_from_string ("scripts")).extended ("uninstall").appended_with_extension ("sql")), Void)
				if l_sql_storage.has_error then
					api.logger.put_error ("Could not remove database for taxonomy module", generating_type)
				end
			end
			Precursor (api)
		end

feature {CMS_API} -- Access: API

	taxonomy_api: detachable CMS_TAXONOMY_API
			-- <Precursor>

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
			if attached taxonomy_api as l_taxonomy_api then
				configure_web (a_api, l_taxonomy_api, a_router)
			else
					-- Issue with api/dependencies,
					-- thus Current module should not be used!
					-- thus no url mapping
			end
		end

	configure_web (a_api: CMS_API; a_taxonomy_api: CMS_TAXONOMY_API; a_router: WSF_ROUTER)
			-- Configure router mapping for web interface.
		local
			l_taxonomy_handler: TAXONOMY_HANDLER
			l_uri_mapping: WSF_URI_MAPPING
		do
			create l_taxonomy_handler.make (a_api, a_taxonomy_api)
				-- Let the class BLOG_HANDLER handle the requests on "/taxonomys"
			create l_uri_mapping.make_trailing_slash_ignored ("/taxonomy", l_taxonomy_handler)
			a_router.map (l_uri_mapping, a_router.methods_get)

				-- We can add a page number after /taxonomys/ to get older posts
			a_router.handle ("/taxonomy/{vocabulary}", l_taxonomy_handler, a_router.methods_get)

				-- If a user id is given route with taxonomy user handler
				--| FIXME: maybe /user/{user}/taxonomys/  would be better.
			a_router.handle ("/taxonomy/{vocabulary}/{termid}", l_taxonomy_handler, a_router.methods_get)
		end

feature -- Hooks

	register_hooks (a_response: CMS_RESPONSE)
		do
			a_response.hooks.subscribe_to_menu_system_alter_hook (Current)
			a_response.hooks.subscribe_to_response_alter_hook (Current)
		end

	response_alter (a_response: CMS_RESPONSE)
		do
			a_response.add_style (a_response.url ("/module/" + name + "/files/css/taxonomy.css", Void), Void)
		end

	menu_system_alter (a_menu_system: CMS_MENU_SYSTEM; a_response: CMS_RESPONSE)
		do
				-- Add the link to the taxonomy to the main menu
--			create lnk.make ("Taxonomy", "taxonomy/")
--			a_menu_system.primary_menu.extend (lnk)
		end

end
