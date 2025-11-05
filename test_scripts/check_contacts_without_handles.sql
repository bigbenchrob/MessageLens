-- Check how many contacts exist in AddressBook without any phone/email records
-- Run this against your import.db to see if there are contacts without contact info

-- Count total non-ignored contacts
SELECT COUNT(*) as total_contacts 
FROM contacts 
WHERE is_ignored = 0 AND Z_PK IS NOT NULL;

-- Count contacts that have at least one phone/email
SELECT COUNT(DISTINCT c.Z_PK) as contacts_with_handles
FROM contacts c
WHERE c.is_ignored = 0 
  AND c.Z_PK IS NOT NULL
  AND EXISTS (
    SELECT 1 FROM contact_to_handle cth 
    WHERE cth.contact_z_pk = c.Z_PK
  );

-- Show example contacts WITHOUT any phone/email
SELECT 
  c.Z_PK,
  c.display_name,
  c.first_name,
  c.last_name,
  c.organization
FROM contacts c
WHERE c.is_ignored = 0 
  AND c.Z_PK IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM contact_to_handle cth 
    WHERE cth.contact_z_pk = c.Z_PK
  )
LIMIT 10;
