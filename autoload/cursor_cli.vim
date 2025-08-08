" ===================================================================
" Cursor CLI Plugin - Autoload Functions
" Provides Cursor IDE-like functionality using the Cursor CLI
" Author: ross (with AI assistance)
" Version: 1.0
" License: MIT
" ===================================================================

" Check if cursor CLI is available
function! cursor_cli#available()
    let l:command = get(g:, 'cursor_cli_command', 'cursor-agent')
    return executable(l:command) || executable('cursor-agent')
endfunction

" Execute cursor CLI command and parse streaming JSON
function! cursor_cli#exec(prompt)
    if !cursor_cli#available()
        echohl ErrorMsg
        echo "Cursor CLI not found. Install with: curl https://cursor.com/install -fsS | bash"
        echohl None
        return ""
    endif
    
    let l:command = get(g:, 'cursor_cli_command', 'cursor-agent')
    
    " Escape the prompt properly for shell
    let l:escaped_prompt = substitute(a:prompt, '"', '\\"', 'g')
    let l:escaped_prompt = substitute(l:escaped_prompt, '`', '\\`', 'g')
    let l:escaped_prompt = substitute(l:escaped_prompt, '$', '\\$', 'g')
    
    " Create a script that monitors cursor-agent output and terminates when we get the result
    let l:temp_script = tempname() . '.sh'
    let l:temp_output = tempname() . '.out'
    
    let l:script_content = [
        \ '#!/bin/bash',
        \ '# Start cursor-agent and monitor output',
        \ l:command . ' --print "' . l:escaped_prompt . '" | while IFS= read -r line; do',
        \ '    echo "$line" >> ' . l:temp_output,
        \ '    if echo "$line" | grep -q "\"type\":\"result\""; then',
        \ '        # Found result line, wait a moment for any final output then exit',
        \ '        sleep 0.5',
        \ '        break',
        \ '    fi',
        \ 'done'
    \ ]
    
    call writefile(l:script_content, l:temp_script)
    call system('chmod +x ' . l:temp_script)
    
    " Show progress
    echo "Cursor AI working... (streaming response)"
    redraw
    
    " Execute the script
    let l:start_time = localtime()
    call system(l:temp_script . ' &')
    
    " Wait for output file to appear and have content
    let l:max_wait = 30  " 30 seconds max
    let l:wait_count = 0
    while l:wait_count < l:max_wait
        if filereadable(l:temp_output)
            let l:content = readfile(l:temp_output)
            " Check if we have the result line
            for line in l:content
                if line =~ '"type":"result"'
                    break  " Found result, we can proceed
                endif
            endfor
            if line =~ '"type":"result"'
                break
            endif
        endif
        sleep 1
        let l:wait_count += 1
        echo "Cursor AI working... (" . l:wait_count . "s)"
        redraw
    endwhile
    
    let l:end_time = localtime()
    
    " Clean up script
    call delete(l:temp_script)
    
    " Read and parse results
    if !filereadable(l:temp_output)
        echohl ErrorMsg
        echo "Cursor AI failed - no output received"
        echohl None
        call delete(l:temp_output)
        return ""
    endif
    
    let l:raw_lines = readfile(l:temp_output)
    call delete(l:temp_output)
    
    if empty(l:raw_lines)
        echohl WarningMsg
        echo "Cursor AI returned empty response"
        echohl None
        return ""
    endif
    
    " Parse the JSON stream to extract the final result
    let l:result = cursor_cli#parse_streaming_json(l:raw_lines)
    
    if empty(l:result)
        echohl WarningMsg
        echo "Could not parse Cursor AI response"
        echohl None
        return ""
    endif
    
    let l:duration = l:end_time - l:start_time
    echo "✅ Cursor AI completed in " . l:duration . "s"
    return l:result
endfunction

" Parse streaming JSON output from cursor-agent
function! cursor_cli#parse_streaming_json(lines)
    let l:result_text = ""
    
    " Look for the final result in the "result" type message
    for line in a:lines
        if line =~ '"type":"result"'
            try
                let l:json = json_decode(line)
                if has_key(l:json, 'result')
                    return l:json.result
                endif
            catch
                " If result parsing fails, continue to try assistant messages
            endtry
        endif
    endfor
    
    " Fallback: concatenate all assistant message content
    let l:content_parts = []
    for line in a:lines
        if line =~ '"type":"assistant"'
            try
                let l:json = json_decode(line)
                if has_key(l:json, 'message') && has_key(l:json.message, 'content')
                    for content_item in l:json.message.content
                        if has_key(content_item, 'text')
                            call add(l:content_parts, content_item.text)
                        endif
                    endfor
                endif
            catch
                " Skip malformed JSON
            endtry
        endif
    endfor
    
    return join(l:content_parts, '')
endfunction

" Create a buffer for displaying results
function! cursor_cli#create_result_buffer(name, content, ...)
    let l:modifier = a:0 > 0 ? a:1 : 'split'
    
    execute l:modifier . ' __Cursor' . a:name . '__'
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nobuflisted
    setlocal wrap
    setlocal linebreak
    setlocal filetype=markdown
    
    " Clear buffer and set content
    %delete _
    call setline(1, split(a:content, '\n'))
    normal! gg
    
    " Add syntax highlighting for code blocks
    syntax match CursorCodeBlock /```.*```/ms=s,me=e
    highlight link CursorCodeBlock String
endfunction

" Get context for current file
function! cursor_cli#get_file_context()
    let l:context = ""
    if expand('%') != ""
        let l:filetype = expand('%:e')
        let l:filename = expand('%:t')
        let l:context = printf(" (Context: working on %s file %s)", l:filetype, l:filename)
    endif
    return l:context
endfunction

" Create prompt with file context
function! cursor_cli#create_prompt_with_context(base_prompt)
    let l:context = cursor_cli#get_file_context()
    return a:base_prompt . l:context
endfunction 