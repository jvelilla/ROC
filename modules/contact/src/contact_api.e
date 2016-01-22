note
	description: "API for the contact module."
	date: "$Date: 2015-05-22 23:00:09 +0200 (ven., 22 mai 2015) $"
	revision: "$Revision: 97349 $"

class
	CONTACT_API

inherit
	CMS_MODULE_API
		rename
			make as make_api
		end

	REFACTORING_HELPER

create
	make

feature {NONE} -- Initialization

	make (a_api: CMS_API; a_contact_storage: like contact_storage)
			-- <Precursor>.
		do
			make_api (a_api)
			contact_storage := a_contact_storage
		end

feature {CMS_MODULE} -- Access nodes storage.

	contact_storage: CONTACT_STORAGE_I

feature -- Basic operation

	save_contact_message (msg: CONTACT_MESSAGE)
		do
			contact_storage.save_contact_message (msg)
		end

end
