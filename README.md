# Cursor CLI Plugin for Neovim

A comprehensive Neovim plugin that brings Cursor IDE-like AI functionality to your terminal-based development workflow.

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Neovim](https://img.shields.io/badge/nvim-0.5.0+-green.svg)

## ✨ Features

- **🤖 AI Chat Interface** - Interactive AI chat like Cursor IDE's sidebar
- **✏️ Intelligent Code Editing** - AI-powered code modifications with diff preview
- **🚀 Code Generation** - Generate code from natural language descriptions
- **📖 Code Explanation** - Understand complex code blocks with AI explanations
- **🔍 Code Review** - Automated code review suggestions
- **⚡ Code Optimization** - Performance and readability improvements
- **🔧 Error Fixing** - Automated bug detection and fixes
- **🔄 Smart Refactoring** - Context-aware refactoring with interactive menu
- **⏱️ Streaming Responses** - Real-time AI responses with proper timeout handling
- **🎯 Context Awareness** - Automatically includes file type and project context

## 📦 Installation

### Prerequisites

1. **Neovim 0.5.0+** (required for Lua support)
2. **Cursor CLI** - Install with:
   ```bash
   curl https://cursor.com/install -fsS | bash
   ```
3. **Cursor Account** - Sign up at [cursor.com](https://cursor.com) and authenticate:
   ```bash
   cursor-agent login
   ```

### Install the Plugin

#### Using [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'your-username/cursor-nvim-plugin'
```

#### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'your-username/cursor-nvim-plugin'
```

#### Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'your-username/cursor-nvim-plugin',
  config = function()
    -- Optional configuration
  end,
}
```

#### Manual Installation
```bash
git clone https://github.com/your-username/cursor-nvim-plugin.git ~/.config/nvim/pack/plugins/start/cursor-nvim-plugin
```

## 🎯 Usage

### Core Commands

| Command | Description |
|---------|-------------|
| `:CursorChat` | Open AI chat interface |
| `:CursorEdit` | Edit selected code with AI |
| `:CursorGenerate` | Generate code from description |
| `:CursorExplain` | Explain selected code |
| `:CursorReview` | Review current file |
| `:CursorOptimize` | Optimize selected code |
| `:CursorFix` | Fix errors in code |
| `:CursorRefactor` | Smart refactor menu |
| `:CursorTest` | Test CLI connection |
| `:CursorStatus` | Check CLI status |

### Example Key Mappings

Add these to your `init.vim` or `init.lua`:

```vim
" Cursor CLI mappings
nmap <leader>cc :CursorChat<CR>
nmap <leader>ce :CursorEdit<CR>
vmap <leader>ce :CursorEdit<CR>
nmap <leader>cg :CursorGenerate<CR>
vmap <leader>cx :CursorExplain<CR>
nmap <leader>cr :CursorReview<CR>
vmap <leader>co :CursorOptimize<CR>
vmap <leader>cf :CursorFix<CR>
vmap <leader>crf :CursorRefactor<CR>
```

### Workflow Examples

#### 1. **AI Chat** 
```vim
:CursorChat
" Ask: "How do I optimize this React component for performance?"
```

#### 2. **Code Editing**
```vim
" Select code in visual mode, then:
:CursorEdit
" Instruction: "Add error handling and validation"
```

#### 3. **Code Generation**
```vim
" Write a comment like: // function to validate email addresses
" Position cursor on the line, then:
:CursorGenerate
```

#### 4. **Code Explanation**
```vim
" Select complex code in visual mode:
:CursorExplain
```

#### 5. **Smart Refactoring**
```vim
" Select code to refactor:
:CursorRefactor
" Choose from: Extract function, Rename variables, Add comments, etc.
```

## ⚙️ Configuration

### Default Configuration
```vim
" Cursor CLI command (default: 'cursor-agent')
let g:cursor_cli_command = 'cursor-agent'

" Default AI model (default: 'sonnet-4')
let g:cursor_cli_model = 'sonnet-4'
```

### Available Models
- `sonnet-4` (default)
- `sonnet-4-thinking`
- `gpt-5`
- And more (check `cursor-agent --help` for current models)

### File Type Context
The plugin automatically provides context based on file type:
- Python: `.py` files
- JavaScript: `.js`, `.jsx` files  
- TypeScript: `.ts`, `.tsx` files
- And more...

## 🔧 Troubleshooting

### Check Status
```vim
:CursorStatus
```

### Test Connection
```vim
:CursorTest
```

### Common Issues

1. **"Cursor CLI not found"**
   ```bash
   # Install Cursor CLI
   curl https://cursor.com/install -fsS | bash
   
   # Add to PATH (already handled by installer)
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Authentication Issues**
   ```bash
   cursor-agent login
   cursor-agent status
   ```

3. **Timeout Issues**
   - Try shorter prompts
   - Check internet connection
   - Verify Cursor account status

## 🎨 Integration Examples

### With NERDCommenter
```vim
" Disable NERDCommenter default mappings to avoid conflicts
let g:NERDCreateDefaultMappings = 0

" Use custom mappings for comments
nmap ++ <plug>NERDCommenterToggle
vmap ++ <plug>NERDCommenterToggle
```

### With LSP
The plugin works alongside your existing LSP setup and provides complementary AI-powered functionality.

### With Other AI Tools
- **GitHub Copilot**: Works simultaneously
- **ChatGPT.nvim**: Use different key mappings
- **Codeium**: Compatible

## 📝 Commands Reference

### Core Features
- `CursorChat` - Interactive AI chat
- `CursorEdit` - AI-powered code editing
- `CursorGenerate` - Code generation from descriptions
- `CursorExplain` - Code explanation and documentation
- `CursorReview` - Automated code review
- `CursorOptimize` - Performance optimization suggestions
- `CursorFix` - Bug detection and fixing
- `CursorRefactor` - Intelligent refactoring options

### Utility Commands
- `CursorStatus` - Check if Cursor CLI is available
- `CursorTest` - Test connection with simple prompt

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Cursor](https://cursor.com) for the amazing AI-powered IDE and CLI
- [Neovim](https://neovim.io) community for the extensible editor
- All contributors and users of this plugin

## 🔗 Related Projects

- [Cursor IDE](https://cursor.com) - The AI-powered code editor
- [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim) - ChatGPT integration for Neovim
- [copilot.vim](https://github.com/github/copilot.vim) - GitHub Copilot for Vim/Neovim

---

**Bring the power of Cursor IDE to your Neovim workflow! 🚀** 