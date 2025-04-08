# ygr.nvim

📎 Quickly copy or open Git remote links to the current line or selection in Neovim.

Supports **GitHub**, **GitLab**, **Bitbucket**, and private remotes.

This project is an exploration into **vibe coding** — using natural language and AI assistance
to turn high-level intent into working code. Development was guided entirely through iterative
conversations with ChatGPT, where ideas were explored, refined, implemented, and debugged
interactively.

For an overview of that process, including summarized prompts and responses, see [`prompts.md`](./prompts.md).

Special thanks to ChatGPT for being a collaborative coding partner
throughout.

Everything, including this README, was written almost entirely by GPT-4o.

## ✨ Features

- `ygr` — Copy Git link to current line
- `ygR` — Open Git link in browser
- Visual mode: `ygr` — Copy link for selected range
- `:GitLink` / `:GitLinkOpen` — Do the same via commands
- `:GitLinkToggleOpen` — Toggle "copy and open" mode

## ⚙️ Installation (lazy.nvim)

```lua
{
  "dklbreitling/ygr.nvim",
  version = "*",
  config = function()
    require("ygr").setup({
      also_open = false,
      preview_link = false,
      provider_map = {
        ["git.mycompany.com"] = "gitlab",
      },
    })
  end,
}
```

## 🛠 Supported Providers

GitHub

GitLab

Bitbucket

Custom/private servers via `provider_map`


## 📝 License

MIT © David Breitling — see LICENSE file for full terms.

