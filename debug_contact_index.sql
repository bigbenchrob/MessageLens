-- Debug queries to understand contact_message_index population

-- 1. Check total messages vs indexed messages for a specific contact
-- Replace ? with actual participant_id
SELECT 
  'Total messages involving contact' as metric,
  COUNT(DISTINCT m.id) as count
FROM messages m
LEFT JOIN handles_canonical h_sender ON m.sender_handle_id = h_sender.id
LEFT JOIN handle_to_participant htp_sender ON h_sender.id = htp_sender.handle_id
LEFT JOIN chat_to_handle cth ON m.chat_id = cth.chat_id
LEFT JOIN handle_to_participant htp_recip ON cth.handle_id = htp_recip.handle_id
WHERE htp_sender.participant_id = ? OR htp_recip.participant_id = ?

UNION ALL

SELECT 
  'Messages in contact_message_index' as metric,
  COUNT(*) as count
FROM contact_message_index
WHERE contact_id = ?;

-- 2. Check if messages are properly linked to participants
SELECT 
  'Outgoing messages (is_from_me=1)' as type,
  COUNT(DISTINCT m.id) as message_count,
  COUNT(DISTINCT htp_recip.participant_id) as unique_contacts
FROM messages m
JOIN chat_to_handle cth ON m.chat_id = cth.chat_id
LEFT JOIN handle_to_participant htp_recip ON cth.handle_id = htp_recip.handle_id
WHERE m.is_from_me = 1

UNION ALL

SELECT 
  'Incoming messages (is_from_me=0)' as type,
  COUNT(DISTINCT m.id) as message_count,
  COUNT(DISTINCT htp_sender.participant_id) as unique_contacts
FROM messages m
LEFT JOIN handles_canonical h_sender ON m.sender_handle_id = h_sender.id
LEFT JOIN handle_to_participant htp_sender ON h_sender.id = htp_sender.handle_id
WHERE m.is_from_me = 0;

-- 3. Sample of messages not in index
SELECT 
  m.id,
  m.chat_id,
  m.is_from_me,
  m.sender_handle_id,
  m.text,
  m.sent_at_utc,
  'Missing from index' as status
FROM messages m
WHERE m.id NOT IN (SELECT message_id FROM contact_message_index)
LIMIT 20;

-- 4. Check handle_to_participant mapping completeness
SELECT 
  'Handles with participant mapping' as metric,
  COUNT(*) as count
FROM handles_canonical h
WHERE EXISTS (
  SELECT 1 FROM handle_to_participant htp 
  WHERE htp.handle_id = h.id
)

UNION ALL

SELECT 
  'Handles without participant mapping' as metric,
  COUNT(*) as count
FROM handles_canonical h
WHERE NOT EXISTS (
  SELECT 1 FROM handle_to_participant htp 
  WHERE htp.handle_id = h.id
);

-- 5. Check for NULL sent_at_utc (these won't appear in timeline)
SELECT 
  'Messages with NULL sent_at_utc' as metric,
  COUNT(*) as count
FROM contact_message_index
WHERE sent_at_utc IS NULL OR sent_at_utc = '';
