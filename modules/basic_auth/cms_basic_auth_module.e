note
	description: "[
			This module allows the use of HTTP Basic Authentication to restrict access
			by looking up users in the given providers.
		]"
	date: "$Date: 2015-02-09 22:29:56 +0100 (lun., 09 févr. 2015) $"
	revision: "$Revision: 96596 $"

class
	CMS_BASIC_AUTH_MODULE

inherit
	CMS_AUTH_MODULE_I
		rename
			module_api as basic_auth_api
		redefine
			make,
			filters,
			setup_hooks
		end

	CMS_HOOK_BLOCK

create
	make

feature {NONE} -- Initialization

	make
		do
			Precursor
			version := "1.0"
			description := "Service to manage basic authentication"
		end

feature -- Access

	name: STRING = "basic_auth"

feature -- Access: auth strategy	

	login_title: STRING = "Basic Auth"
			-- Module specific login title.

	login_location: STRING = "account/auth/roc-basic-login"

	do_login_location: STRING = "roc-basic-login" -- IMPORTANT: it has to be at the root !

	logout_location: STRING = "roc-basic-logoff" -- IMPORTANT: it has to be at the root !

	is_authenticating (a_response: CMS_RESPONSE): BOOLEAN
			-- <Precursor>
		do
			if
				a_response.is_authenticated and then
				a_response.request.http_authorization /= Void
			then
				Result := True
			end
		end

feature {CMS_API} -- Access: API

	oauth20_api: detachable CMS_AUTH_API_I
			-- <Precursor>			

feature -- Access: filter

	filters (a_api: CMS_API): detachable LIST [WSF_FILTER]
			-- Possibly list of Filter's module.
		do
			create {ARRAYED_LIST [WSF_FILTER]} Result.make (2)
			Result.extend (create {CMS_CORS_FILTER})
			Result.extend (create {CMS_BASIC_AUTH_FILTER}.make (a_api))
		end

feature -- Access: router

	setup_router (a_router: WSF_ROUTER; a_api: CMS_API)
			-- <Precursor>
		do
			configure_api_login (a_api, a_router)
			configure_api_logoff (a_api, a_router)
			a_router.handle ("/" + login_location, create {WSF_URI_AGENT_HANDLER}.make (agent handle_login_basic_auth (a_api, ?, ?)), a_router.methods_head_get)
		end

feature {NONE} -- Implementation: routes

	configure_api_login (api: CMS_API; a_router: WSF_ROUTER)
		local
			l_bal_handler: CMS_BASIC_AUTH_LOGIN_HANDLER
			l_methods: WSF_REQUEST_METHODS
		do
			create l_bal_handler.make (api)
			create l_methods
			l_methods.enable_get
			a_router.handle ("/" + do_login_location, l_bal_handler, l_methods)
		end

	configure_api_logoff (api: CMS_API; a_router: WSF_ROUTER)
		local
			l_bal_handler: CMS_BASIC_AUTH_LOGOFF_HANDLER
			l_methods: WSF_REQUEST_METHODS
		do
			create l_bal_handler.make (api)
			create l_methods
			l_methods.enable_get
			a_router.handle ("/" + logout_location, l_bal_handler, l_methods)
		end

	handle_login_basic_auth (api: CMS_API; req: WSF_REQUEST; res: WSF_RESPONSE)
		local
			r: CMS_RESPONSE
			vals: CMS_VALUE_TABLE
		do
			create {GENERIC_VIEW_CMS_RESPONSE} r.make (req, res, api)
			if api.user_is_authenticated then
				r.add_error_message ("You are already signed in!")
				r.set_main_content (r.link ("Logout", "account/roc-logout", Void))
			else
				if attached smarty_template_block (Current, "login", api) as l_tpl_block then
					r.add_javascript_url (r.url ("module/" + name + "/files/js/roc_basic_auth.js", Void))

					create vals.make (1)
						-- add the variable to the block
					api.hooks.invoke_value_table_alter (vals, r)
					across
						vals as ic
					loop
						l_tpl_block.set_value (ic.item, ic.key)
					end
					r.add_block (l_tpl_block, "content")
				else
					debug ("cms")
						r.add_warning_message ("Error with block [login]")
					end
				end
				r.set_value ("Basic Auth", "optional_content_type")
			end
			r.execute
		end

feature -- Hooks configuration

	setup_hooks (a_hooks: CMS_HOOK_CORE_MANAGER)
			-- Module hooks configuration.
		do
			Precursor (a_hooks)
			a_hooks.subscribe_to_block_hook (Current)
		end

feature -- Hooks

	block_list: ITERABLE [like {CMS_BLOCK}.name]
		do
			Result := <<"?login">>
		end

	get_block_view (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
		do
			if a_block_id.is_case_insensitive_equal_general ("login") then
				a_response.add_javascript_url (a_response.url ("module/" + name + "/files/js/roc_basic_auth.js", Void))
				get_block_view_login (a_block_id, a_response)
			end
		end

feature {NONE} -- Block views

	get_block_view_login (a_block_id: READABLE_STRING_8; a_response: CMS_RESPONSE)
		local
			vals: CMS_VALUE_TABLE
		do
			if attached smarty_template_block (Current, a_block_id, a_response.api) as l_tpl_block then
				create vals.make (1)
					-- add the variable to the block
				a_response.api.hooks.invoke_value_table_alter (vals, a_response)
				across
					vals as ic
				loop
					l_tpl_block.set_value (ic.item, ic.key)
				end
				a_response.add_block (l_tpl_block, "content")
			else
				debug ("cms")
					a_response.add_warning_message ("Error with block [" + a_block_id + "]")
				end
			end
		end

end
