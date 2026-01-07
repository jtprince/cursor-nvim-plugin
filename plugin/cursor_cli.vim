" ===================================================================
" Cursor CLI Plugin for Neovim
" Provides Cursor IDE-like functionality using the Cursor CLI
" Author: ross (with AI assistance)
" Version: 1.0
" License: MIT
" ===================================================================

if exists('g:loaded_cursor_cli') || !has('nvim')
    finish
endif
let g:loaded_cursor_cli = 1

" Configuration
let g:cursor_cli_command = get(g:, 'cursor_cli_command', 'cursor-agent')
let g:cursor_cli_model = get(g:, 'cursor_cli_model', 'sonnet-4')

" Use autoload functions for better performance
" All core functionality is now in autoload/cursor_cli.vim

" ===================================================================
" Main Functions
" ===================================================================

" Chat with Cursor AI (like Cursor IDE sidebar)
" Optional model parameter: if provided, uses that model
function! CursorChat(...)
    let l:model = a:0 > 0 ? a:1 : ''
    let l:question = input('💬 Ask Cursor AI: ')
    if empty(l:question)
        return
    endif
    
    " Add context about current file if available
    let l:context = ""
    if expand('%') != ""
        let l:context = printf(" (Context: working on %s)", expand('%:t'))
    endif
    
    let l:prompt = cursor_cli#create_prompt_with_context(l:question)
    let l:response = cursor_cli#exec(l:prompt, l:model)
    if !empty(l:response)
        call cursor_cli#create_result_buffer('Chat', l:response)
        echo "✅ Chat response ready!"
    endif
endfunction

" Edit selected code with AI instructions
" Optional model parameter: if provided, uses that model
function! CursorEdit(...) range
    let l:model = a:0 > 0 ? a:1 : ''
    let l:instruction = input('✏️  Edit instruction: ')
    if empty(l:instruction)
        return
    endif
    
    " Get selected text or current line
    if a:firstline == a:lastline && col("'<") == col("'>")
        let l:lines = [getline('.')]
        let l:start_line = line('.')
        let l:end_line = line('.')
    else
        let l:lines = getline(a:firstline, a:lastline)
        let l:start_line = a:firstline
        let l:end_line = a:lastline
    endif
    
    let l:original_code = join(l:lines, "\n")
    
    " Create prompt with context
    let l:prompt = printf("Edit this %s code according to the instruction.\n\nFile: %s\nInstruction: %s\n\nOriginal code:\n%s\n\nProvide only the edited code:", 
        \ expand('%:e'), expand('%:t'), l:instruction, l:original_code)
    
    let l:result = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:result)
        " Create diff view
        call cursor_cli#create_result_buffer('Diff', "ORIGINAL:\n" . l:original_code . "\n\nEDITED:\n" . l:result, 'vnew')
        
        echo "Apply changes? (y/n/v for view only): "
        let l:choice = nr2char(getchar())
        
        if l:choice ==# 'y'
            " Replace selected lines
            execute l:start_line . ',' . l:end_line . 'delete'
            call append(l:start_line - 1, split(l:result, '\n'))
            echo "✅ Changes applied!"
        elseif l:choice ==# 'v'
            echo "📖 View mode - close buffer when done"
            return
        else
            bwipeout __CursorDiff__
            echo "❌ Changes discarded"
        endif
    endif
endfunction

" Generate code from instruction
" Optional model parameter: if provided, uses that model
function! CursorGenerate(...)
    let l:model = a:0 > 0 ? a:1 : ''
    let l:current_line = getline('.')
    let l:default = l:current_line =~ '^\s*[#/"\*].*' ? l:current_line : ''
    let l:instruction = input('🚀 Generate code: ', l:default)
    
    if empty(l:instruction)
        return
    endif
    
    " Create generation prompt
    let l:prompt = printf("Generate %s code for: %s\n\nFile context: %s (%s)\n\nProvide only the code without explanations:", 
        \ expand('%:e'), l:instruction, expand('%:t'), &filetype)
    let l:result = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:result)
        " Insert at current position
        let l:lines = split(l:result, '\n')
        call append(line('.'), l:lines)
        echo printf("✅ Generated %d lines of code!", len(l:lines))
    endif
endfunction

" Explain selected code
" Optional model parameter: if provided, uses that model
function! CursorExplain(...) range
    let l:model = a:0 > 0 ? a:1 : ''
    let l:lines = getline(a:firstline, a:lastline)
    let l:code = join(l:lines, '\n')
    
    if empty(trim(l:code))
        echo "No code selected to explain"
        return
    endif
    
    let l:prompt = printf("Explain this %s code from %s:\n\n%s", expand('%:e'), expand('%:t'), l:code)
    let l:explanation = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:explanation)
        call cursor_cli#create_result_buffer('Explanation', l:explanation)
        echo "📖 Code explanation ready!"
    endif
endfunction

" Review current file
" Optional model parameter: if provided, uses that model
function! CursorReview(...)
    let l:model = a:0 > 0 ? a:1 : ''
    let l:current_file = expand('%:p')
    if empty(l:current_file) || !filereadable(l:current_file)
        echo "No readable file to review"
        return
    endif
    
    " Read file content for review
    let l:file_content = join(readfile(l:current_file), "\n")
    let l:prompt = printf("Review this %s code for best practices, bugs, and improvements:\n\nFile: %s\n\n%s", expand('%:e'), expand('%:t'), l:file_content)
    let l:review = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:review)
        call cursor_cli#create_result_buffer('Review', l:review)
        echo "🔍 Code review ready!"
    endif
endfunction

" Optimize selected code
" Optional model parameter: if provided, uses that model
function! CursorOptimize(...) range
    let l:model = a:0 > 0 ? a:1 : ''
    let l:lines = getline(a:firstline, a:lastline)
    let l:code = join(l:lines, '\n')
    
    let l:prompt = printf("Optimize this %s code for better performance and readability:\n\nFile: %s\n\nOriginal code:\n%s\n\nProvide only the optimized code:", expand('%:e'), expand('%:t'), l:code)
    let l:result = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:result)
        call cursor_cli#create_result_buffer('Optimization', "ORIGINAL:\n" . l:code . "\n\nOPTIMIZED:\n" . l:result, 'vnew')
        
        echo "Apply optimization? (y/n): "
        let l:choice = nr2char(getchar())
        
        if l:choice ==# 'y'
            execute a:firstline . ',' . a:lastline . 'delete'
            call append(a:firstline - 1, split(l:result, '\n'))
            echo "✅ Code optimized!"
        else
            bwipeout __CursorOptimization__
            echo "❌ Optimization discarded"
        endif
    endif
endfunction

" Fix errors in selected code
" Optional model parameter: if provided, uses that model
function! CursorFix(...) range
    let l:model = a:0 > 0 ? a:1 : ''
    let l:lines = getline(a:firstline, a:lastline)
    let l:code = join(l:lines, '\n')
    
    let l:prompt = printf("Fix any errors or bugs in this %s code:\n\nFile: %s\n\nCode with issues:\n%s\n\nProvide only the corrected code:", expand('%:e'), expand('%:t'), l:code)
    let l:result = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:result)
        call cursor_cli#create_result_buffer('Fix', "ORIGINAL:\n" . l:code . "\n\nFIXED:\n" . l:result, 'vnew')
        
        echo "Apply fix? (y/n): "
        let l:choice = nr2char(getchar())
        
        if l:choice ==# 'y'
            execute a:firstline . ',' . a:lastline . 'delete'
            call append(a:firstline - 1, split(l:result, '\n'))
            echo "✅ Code fixed!"
        else
            bwipeout __CursorFix__
            echo "❌ Fix discarded"
        endif
    endif
endfunction

" Quick refactor with context menu
" Optional model parameter: if provided, uses that model
function! CursorRefactor(...) range
    let l:model = a:0 > 0 ? a:1 : ''
    echo "Refactor options:"
    echo "1. Extract function"
    echo "2. Rename variable" 
    echo "3. Add comments"
    echo "4. Simplify logic"
    echo "5. Custom instruction"
    
    let l:choice = nr2char(getchar())
    let l:instruction = ""
    
    if l:choice == '1'
        let l:instruction = 'Extract this code into a well-named function'
    elseif l:choice == '2'
        let l:instruction = 'Rename variables to be more descriptive'
    elseif l:choice == '3'
        let l:instruction = 'Add helpful comments to explain the code'
    elseif l:choice == '4'
        let l:instruction = 'Simplify the logic while maintaining functionality'
    elseif l:choice == '5'
        let l:instruction = input('Custom refactor instruction: ')
    else
        echo "Invalid choice"
        return
    endif
    
    " Use the edit function with refactor instruction
    let l:lines = getline(a:firstline, a:lastline)
    let l:code = join(l:lines, '\n')
    
    let l:prompt = printf("Refactor this %s code: %s\n\nFile: %s\n\nOriginal code:\n%s\n\nProvide only the refactored code:", expand('%:e'), l:instruction, expand('%:t'), l:code)
    let l:result = cursor_cli#exec(l:prompt, l:model)
    
    if !empty(l:result)
        call cursor_cli#create_result_buffer('Refactor', "ORIGINAL:\n" . l:code . "\n\nREFACTORED:\n" . l:result, 'vnew')
        
        echo "Apply refactor? (y/n): "
        let l:apply = nr2char(getchar())
        
        if l:apply ==# 'y'
            execute a:firstline . ',' . a:lastline . 'delete'
            call append(a:firstline - 1, split(l:result, '\n'))
            echo "✅ Code refactored!"
        else
            bwipeout __CursorRefactor__
            echo "❌ Refactor discarded"
        endif
    endif
endfunction

" Test Cursor CLI with a simple prompt
function! CursorTest()
    echo "Testing Cursor CLI connection..."
    let l:result = cursor_cli#exec("Just say 'Hello from Cursor!' - this is a test")
    if !empty(l:result)
        echo "✅ Test successful! Response: " . l:result[:100] . (len(l:result) > 100 ? "..." : "")
    else
        echo "❌ Test failed - check the error messages above"
    endif
endfunction

" ===================================================================
" Commands
" ===================================================================

command! CursorChat call CursorChat()
command! -range CursorEdit <line1>,<line2>call CursorEdit()
command! CursorGenerate call CursorGenerate()
command! -range CursorExplain <line1>,<line2>call CursorExplain()
command! CursorReview call CursorReview()
command! -range CursorOptimize <line1>,<line2>call CursorOptimize()
command! -range CursorFix <line1>,<line2>call CursorFix()
command! -range CursorRefactor <line1>,<line2>call CursorRefactor()

" ===================================================================
" Model-Specific Commands
" ===================================================================
" These commands allow you to specify the model directly in the command name
" Format: :CursorChat<Model> where Model is one of the available models

" Define available models and their command-friendly names
let s:models = [
    \ ['Sonnet4', 'sonnet-4'],
    \ ['Sonnet4Thinking', 'sonnet-4-thinking'],
    \ ['GPT5', 'gpt-5'],
    \ ['Auto', 'auto'],
    \ ['ClaudeSonnet4', 'claude-sonnet-4'],
    \ ['ClaudeSonnet4Thinking', 'claude-sonnet-4-thinking'],
    \ ['GPT4', 'gpt-4'],
    \ ['GPT4Turbo', 'gpt-4-turbo']
\ ]

" Create model-specific commands for each base command
for model_pair in s:models
    let l:cmd_name = model_pair[0]
    let l:model_value = model_pair[1]
    
    " CursorChat variants
    execute printf("function! CursorChat%s(...)\n    call CursorChat('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! CursorChat%s call CursorChat%s()", l:cmd_name, l:cmd_name)
    
    " CursorEdit variants
    execute printf("function! CursorEdit%s(...) range\n    call CursorEdit('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! -range CursorEdit%s <line1>,<line2>call CursorEdit%s()", l:cmd_name, l:cmd_name)
    
    " CursorGenerate variants
    execute printf("function! CursorGenerate%s(...)\n    call CursorGenerate('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! CursorGenerate%s call CursorGenerate%s()", l:cmd_name, l:cmd_name)
    
    " CursorExplain variants
    execute printf("function! CursorExplain%s(...) range\n    call CursorExplain('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! -range CursorExplain%s <line1>,<line2>call CursorExplain%s()", l:cmd_name, l:cmd_name)
    
    " CursorReview variants
    execute printf("function! CursorReview%s(...)\n    call CursorReview('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! CursorReview%s call CursorReview%s()", l:cmd_name, l:cmd_name)
    
    " CursorOptimize variants
    execute printf("function! CursorOptimize%s(...) range\n    call CursorOptimize('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! -range CursorOptimize%s <line1>,<line2>call CursorOptimize%s()", l:cmd_name, l:cmd_name)
    
    " CursorFix variants
    execute printf("function! CursorFix%s(...) range\n    call CursorFix('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! -range CursorFix%s <line1>,<line2>call CursorFix%s()", l:cmd_name, l:cmd_name)
    
    " CursorRefactor variants
    execute printf("function! CursorRefactor%s(...) range\n    call CursorRefactor('%s')\nendfunction", l:cmd_name, l:model_value)
    execute printf("command! -range CursorRefactor%s <line1>,<line2>call CursorRefactor%s()", l:cmd_name, l:cmd_name)
endfor

" Status and test functions
command! CursorStatus echo cursor_cli#available() ? "✅ Cursor CLI available" : "❌ Cursor CLI not found"
command! CursorTest call CursorTest() 