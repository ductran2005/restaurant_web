# Chatbot Feature

This project now includes an AI-powered chatbot accessible via `/chatbot.html`.

## Overview

- **Servlet**: `market.restaurant_web.servlet.ChatbotServlet` listens at `/api/chat`.
- **Frontend**: floating widget injected into every customer page via layout tag (`customer.tag`).
  The widget’s assets live under `webapp/chatbot.js` and `webapp/chatbot.css`.
  A dedicated `chatbot.html` remains available as a standalone page for testing.
- **Integration**: Uses existing DAO classes to query menu items, today's confirmed bookings, and available tables. No new DAO classes were added.
- **AI Backend**: Contacts OpenAI Chat Completions API (`gpt-3.5-turbo`) using `HttpClient`.

## Requirements

- Set `OPENAI_API_KEY` in the environment before running the server. The servlet reads
  the value via `System.getenv("OPENAI_API_KEY")`.
- Do **not** embed the key in source code.

## How it works

1. User opens `/chatbot.html` and types a question.
2. JavaScript sends a POST request to `/api/chat` with JSON `{ "message": "..." }`.
3. `ChatbotServlet` builds contextual prompt using database information and the user message.
4. Servlet calls OpenAI API and returns `{ "reply": "..." }`.
5. Frontend displays the AI reply.

## Notes

- The implementation is intentionally lightweight and modular; database access is encapsulated in helper method `collectDbContext()`.
- If further logic is needed (e.g. specialized booking queries), expand inside the servlet or extract to a service.

Enjoy the new AI chatbot!
