# Sidebar Navigation and Organization

## Overview

The left sidebar provides a two-tier organizational system for browsing messages. The top tier determines whether you're viewing **Contacts** (matched participants) or **Unmatched Handles** (phone numbers/emails without associated contacts). The second tier refines what's displayed in the scrollable list below.

## Navigation Flow

### Critical Rule: Center Panel Behavior

**The center panel remains EMPTY until the user takes a specific action:**

- **When browsing Contacts**: Center panel stays empty until a **chat** is clicked
- **When browsing Unmatched Handles**: Center panel stays empty until a **handle** is clicked

The left sidebar's scrolling list is where navigation choices are made. The center panel is purely for viewing the selected content.

## Two-Tier Organization Structure

### MENU A: Top-Level Category Selection ("Show messages from:")

Located at the very top of the sidebar. Determines the fundamental mode:

1. **"Contacts"** - View messages organized by matched participants (contacts)
2. **"Unmatched Phones"** - View messages from phone numbers without associated contacts
3. **"Unmatched Emails"** - View messages from email addresses without associated contacts

**UI Pattern**: Prefer radio buttons when all choices fit. Use dropdown menu when space is constrained or many options exist.

### MENU B: Secondary Filter/Selection

Appears below MENU A. Content and behavior depends on MENU A selection:

---

## (1) Contacts Mode

**MENU A Selection**: "Contacts"

**MENU B**: Dropdown showing all contacts (participants)
- Displays each contact's display name
- **FUTURE ENHANCEMENT**: Add radio buttons below menu:
  - "A-Z" (alphabetical sort)
  - "Favourites" (show only starred contacts)
  - Additional organization modes as needed

### Navigation Flow:

1. User selects a contact from MENU B dropdown
2. **Left sidebar scrolling list** updates to show all chats for that contact
   - Each chat displayed as an enhanced chat card with:
     - Contact name
     - Handle identifier (phone/email)
     - Message count badge
     - Recency indicator (⏱ Now, 📩 Today, etc.)
     - Timeline visualization (if sufficient message history)
     - Date range labels
3. **Center panel** remains EMPTY (shows placeholder)
4. User clicks a chat in the left sidebar list
5. **Center panel** now displays messages for that specific chat

**FUTURE ENHANCEMENT**: Add controls below the chat list to refine ordering:
- Earliest first
- Most recent first
- Most active (highest message count)
- Other sorting criteria

---

## (2) Unmatched Handles Mode

**MENU A Selection**: "Unmatched Phones" or "Unmatched Emails"

**MENU B**: Determines which handles to display in the scrolling list

### For "Unmatched Phones":

**Radio buttons below MENU B**:
- **"All"** - Show all unmatched phone numbers
- **"Spam?"** - Show only numbers flagged as potential spam candidates

### For "Unmatched Emails":

**Radio buttons below MENU B**: (Currently NULL - all emails shown)

### Navigation Flow:

1. User selects filter criteria (e.g., "All" or "Spam?" for phones)
2. **Left sidebar scrolling list** shows canonical handles matching the criteria
   - Each handle displayed as a card showing:
     - Formatted phone number or email address
     - Message count
     - Date range of messages
     - Spam indicator (if applicable)
3. **Center panel** remains EMPTY (shows placeholder)
4. User clicks a handle in the left sidebar list
5. **Center panel** displays **ALL messages from that handle** in chronological order
   - Messages NOT broken down by chat
   - All messages from the handle across all chats shown together
   - Sorted by date/time

### CRITICAL DISTINCTION:

**Contacts**: Clicking shows messages for **one chat** (conversation context preserved)

**Unmatched Handles**: Clicking shows **all messages from that handle** regardless of chat (aggregated view)

---

## Future Enhancements

### Handle Labeling System (Phase 6)

When viewing messages for an unmatched handle in the center panel, provide UI to:

1. **Label the handle** - Assign a meaningful name/identifier
   - Once labeled, the handle moves to "Contacts and Labeled Handles" tier
   - Messages can then be viewed broken down by individual chats
   - Labeling associates the handle with a participant

2. **Mark as SPAM** - Dismiss the handle as unwanted
   - Remove from main views
   - Optionally show in "Spam" filtered view
   - Prevent future notifications

### Contact Organization (Phase 7)

- Favorites system for frequently accessed contacts
- Custom grouping/categorization
- Contact detail view showing all associated handles
- Merge/split contact functionality

---

## UI Pattern Guidelines

### When to Use Radio Buttons vs. Menus:

- **Radio buttons**: Use when all choices fit comfortably on screen (2-5 options typically)
- **Dropdown menu**: Use when space is limited or many options exist (6+ contacts, for example)
- **Radio buttons below menu**: Use to refine the contents of a dropdown menu (e.g., filter what contacts are shown)

### Consistency Rules:

- MENU A controls the fundamental data domain (Contacts vs. Unmatched)
- MENU B controls which specific item(s) within that domain to display
- Radio buttons below menus provide additional filtering/sorting
- The scrolling list always shows the items to select from
- The center panel always waits for a selection before showing content

---

## Implementation Notes

### Key Files:

- **Sidebar Views**:
  - `lib/features/contacts/presentation/view/contacts_sidebar_view.dart` - Contacts mode
  - `lib/features/contacts/presentation/view/unmatched_handles_sidebar_view.dart` - Unmatched handles mode

- **Data Providers**:
  - `lib/features/contacts/application/contacts_list_provider.dart` - Contact list for MENU B
  - `lib/features/contacts/application/chats_for_participant_provider.dart` - Chats for selected contact
  - `lib/features/contacts/application/unmatched_phones_provider.dart` - Unmatched phone handles
  - `lib/features/contacts/application/unmatched_emails_provider.dart` - Unmatched email handles
  - `lib/features/messages/application/messages_for_handle_provider.dart` - All messages from a handle

- **Routing**:
  - `lib/essentials/navigation/presentation/view_model/panel_coordinator_provider.dart` - Routes specs to views
  - Sidebar shows in left panel (`WindowPanel.left`)
  - Content shows in center panel (`WindowPanel.center`)

### Navigation Specs:

**Sidebar content** uses `ViewSpec.sidebar(SidebarSpec)`:
- `SidebarSpec.contacts(...)` - Contacts mode with selected participant
- `SidebarSpec.unmatchedPhones(...)` - Unmatched phones mode
- `SidebarSpec.unmatchedEmails(...)` - Unmatched emails mode

**Center panel content** uses different specs based on mode:
- Contacts mode → `ViewSpec.messages(MessagesSpec.forChat(chatId: ...))` - Show one chat's messages
- Unmatched mode → `ViewSpec.messages(MessagesSpec.forHandle(handleId: ...))` - Show all messages from handle

**DO NOT** use `ViewSpec.chats(ChatsSpec.forParticipant(...))` in center panel when selecting a contact - this was a bug. The chats list appears in the LEFT sidebar, not the center panel.
