## WhatsApp-Driven Google Drive Assistant (n8n workflow)
Partially implemented
Minimal MVP that listens to WhatsApp messages via Twilio Sandbox, performs Google Drive actions (LIST, DELETE, MOVE), summarizes folder documents (TXT + Google Docs export), logs all actions to Google Sheets, and replies via TwiML.

### Features
- LIST /FolderName — list files in the named folder
- DELETE /FolderName/FileName.ext CONFIRM — delete a single file (requires CONFIRM)
- MOVE /SourceFolder/FileName.ext /DestFolder — move a single file
- SUMMARY /FolderName — summaries for up to N files (TXT and Google Docs only)
- Audit log to Google Sheets

### Repo layout
- `docker-compose.yml` — run n8n with an exposed webhook tunnel
- `env.sample` — example environment variables
- `workflows/whatsapp-drive-mvp.json` — n8n export to import
- `scripts/run.sh`, `scripts/run.ps1` — helper launch scripts

### Prerequisites
- Docker + Docker Compose
- A Twilio Sandbox for WhatsApp (or a Twilio WhatsApp-enabled number)
- Google Cloud project with OAuth2 credentials for Drive and Sheets (user data)
- OpenAI API key (for GPT-4o or gpt-4o-mini)

### Quick start
1) Copy env and edit
```
cp env.sample .env
```
Fill at least:
- `N8N_TUNNEL_SUBDOMAIN` to any unique string (enables public webhook URL)
- `OPENAI_API_KEY`

2) Launch n8n
```
docker compose up -d
```

3) Import the workflow
- Open n8n UI at `http://localhost:5678` (use basic auth if set)
- Import `workflows/whatsapp-drive-mvp.json`
- In nodes: connect credentials for Google Drive, Google Sheets, and OpenAI
  - Google Drive: OAuth2, scopes: `https://www.googleapis.com/auth/drive`
  - Google Sheets: OAuth2, scopes: `https://www.googleapis.com/auth/spreadsheets`
  - OpenAI: API key
- In the Sheets Append node, specify an existing spreadsheet and sheet

4) Grab the public webhook URL
- After activating the workflow, copy the production webhook URL of the Webhook node
- It will look like: `https://<subdomain>.n8n.cloud/webhook/whatsapp`

5) Configure Twilio Sandbox for WhatsApp
- In Twilio Console > Messaging > Try it out > WhatsApp Sandbox
- Set the “WHEN A MESSAGE COMES IN” webhook to the URL from step 4
- Method: POST, Content Type: `application/x-www-form-urlencoded`

6) Test via WhatsApp
Send one of the following to your Sandbox number:
- `LIST /ProjectX`
- `DELETE /ProjectX/report.txt CONFIRM`
- `MOVE /ProjectX/report.txt /Archive`
- `SUMMARY /ProjectX`

### Command syntax
- `LIST /FolderName`
- `DELETE /FolderName/Filename.ext CONFIRM`
- `MOVE /SourceFolder/Filename.ext /DestFolder`
- `SUMMARY /FolderName`

Notes:
- Folder lookup uses name-based search (first match). If you have duplicates, prefer unique names or adjust nodes to search by folder ID.
- SUMMARY supports plain text and Google Docs (exported as text). PDFs/DOCX are left as “unsupported” in this MVP.

### Safety & logging
- DELETE requires the `CONFIRM` keyword. If omitted, you’ll get a reminder response without deleting anything.
- Every command attempt is appended to a Google Sheet with timestamp, sender, command, args, and status.

### OpenAI model
- Default is `gpt-4o-mini` for cost/speed. You can switch to `gpt-4o` in the OpenAI node.

### Environment variables
See `.env.sample` for all variables. Key ones:
- `N8N_TUNNEL_SUBDOMAIN` — enables a public webhook URL without extra tooling
- `WEBHOOK_URL_SUFFIX=whatsapp` — matches the Webhook node path
- `OPENAI_API_KEY` — used by the OpenAI node
- Optional: `N8N_BASIC_AUTH_USER` and `N8N_BASIC_AUTH_PASSWORD`

### Limitations in MVP
- Path resolution is name-based (no nested path crawling). Use single-level folder names.
- SUMMARY reads only TXT and Google Docs (export). For PDF/DOCX support, add conversion steps or community nodes.
- Twilio signature verification is not enabled in this MVP (add a verification step for production).

### Extending
- Add help command: `HELP` to render usage
- Implement full path traversal with parent scoping
- Add PDF/DOCX extractors (e.g., community nodes or custom microservice)
- Add Twilio request signature validation

### Troubleshooting
- If webhook says 404, ensure the workflow is active and tunnel subdomain is set
- If Drive nodes return empty results, verify OAuth scopes and that folder names exist in your Drive
- If Sheets append fails, ensure spreadsheet and sheet names are configured and shared with the OAuth account


