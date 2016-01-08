note
	description: "Summary description for {CMS_AUTHENTICATION_EMAIL_SERVICE}."
	date: "$Date$"
	revision: "$Revision$"

class
	CMS_AUTHENTICATION_EMAIL_SERVICE

create
	make

feature {NONE} -- Initialization

	make (a_params: like parameters)
			-- Create instance of email service with `a_params' data.
		do
			parameters := a_params
			initialize
		end

	initialize
			-- Initialize service.
		do
			create error_handler.make
			reset_error
		end

feature -- Access

	parameters: CMS_AUTHENTICATION_EMAIL_SERVICE_PARAMETERS
			-- Associated parameters.

	cms_api: CMS_API
		do
			Result := parameters.cms_api
		end

	contact_email_address: IMMUTABLE_STRING_8
			-- contact email.
		do
			Result := parameters.contact_email_address
		end

	notif_email_address: IMMUTABLE_STRING_8
			-- Site admin's email.
		do
			Result := parameters.notif_email_address
		end

	sender_email_address: IMMUTABLE_STRING_8
			-- Site sender's email.
		do
			Result := parameters.sender_email_address
		end

feature -- Error

	error_handler: ERROR_HANDLER

	has_error: BOOLEAN
		do
			Result := error_handler.has_error
		end

	reset_error
		do
			error_handler.reset
		end

feature -- Basic Operations / Internal

	send_internal_email (a_content: READABLE_STRING_GENERAL)
		do
			send_message (sender_email_address, notif_email_address, "Notification Contact", a_content)
		end

	send_email_internal_server_error (a_content: READABLE_STRING_GENERAL)
		do
			send_message (sender_email_address, notif_email_address, "Internal Server Error", a_content)
		end

feature -- Basic Operations / Contact

	send_contact_email (a_to, a_content: READABLE_STRING_8)
			-- Send successful contact message `a_token' to `a_to'.
		require
			attached_to: a_to /= Void
		local
			l_message: STRING
		do
			create l_message.make_from_string (parameters.account_activation)
			l_message.replace_substring_all ("$link", a_content)
			send_message (contact_email_address, a_to, parameters.contact_subject_register, l_message)
		end

	send_contact_activation_email (a_to, a_content: READABLE_STRING_8)
			-- Send successful contact message `a_token' to `a_to'.
		require
			attached_to: a_to /= Void
		local
			l_message: STRING
		do
			create l_message.make_from_string (parameters.account_re_activation)
			l_message.replace_substring_all ("$link", a_content)
			send_message (contact_email_address, a_to, parameters.contact_subject_activate, l_message)
		end

	send_contact_password_email (a_to, a_content: READABLE_STRING_8)
			-- Send successful contact message `a_token' to `a_to'.
		require
			attached_to: a_to /= Void
		local
			l_message: STRING
		do
			create l_message.make_from_string (parameters.account_password)
			l_message.replace_substring_all ("$link", a_content)
			send_message (contact_email_address, a_to, parameters.contact_subject_password, l_message)
		end

	send_contact_welcome_email (a_to, a_content: READABLE_STRING_8)
			-- Send successful contact message `a_token' to `a_to'.
		require
			attached_to: a_to /= Void
		local
			l_message: STRING
		do
			create l_message.make_from_string (parameters.account_welcome)
			l_message.replace_substring_all ("$link", a_content)
			send_message (contact_email_address, a_to, parameters.contact_subject_oauth, l_message)
		end

feature {NONE} -- Implementation

	send_message (a_from_address, a_to_address: READABLE_STRING_8; a_subjet: READABLE_STRING_GENERAL; a_content: READABLE_STRING_GENERAL)
		local
			l_email: CMS_EMAIL
			utf: UTF_CONVERTER
		do
			reset_error
			l_email := cms_api.new_email (a_to_address, utf.escaped_utf_32_string_to_utf_8_string_8 (a_subjet), utf.escaped_utf_32_string_to_utf_8_string_8 (a_content))
			l_email.set_from_address (a_from_address)
			l_email.add_header_line ("MIME-Version:1.0")
			l_email.add_header_line ("Content-Type: text/html; charset=utf-8")
			cms_api.process_email (l_email)
			if cms_api.has_error then
				error_handler.add_custom_error (-1, generator + "send_message failed", cms_api.string_representation_of_errors)
			end
		end

end
