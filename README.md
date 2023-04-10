# 🤖 Hey GPT

Rails app that powers [Hey GPT](https://t.me/h3y_gpt_bot) Telegram bot.

Basically it's just a webhook handler which processes each message in the background using Sidekiq. Something like this:

```mermaid
sequenceDiagram;
  participant U as User;
  participant B as Bot;
  participant A as Rails app;
  participant W as Sidekiq worker;
  U->>B: sends message
  B->>A: sends webhook with update
  A->>W: enqueues webhook processing job
  W->>U: sends message with response (usually from OpenAI API)
```

## Stack

- Ruby/Rails/Sidekiq
- PostgreSQL
- Redis
