import re
import json
import openai

# Configuration
client = openai.OpenAI(api_key="YOUR_OPENAI_API_KEY")
MODEL = "gpt-4o"  # or gpt-3.5-turbo

def get_llm_comments(tagged_chunk):
    """Sends a chunk of code to the API and expects a JSON response."""
    prompt = f"""
    Analyze the following Verilog code. For every line ending in '// [ID_xxx]', 
    generate a concise technical comment. 
    Return ONLY a JSON object mapping the ID to the comment string.
    Example: {{"ID_001": "Clock reset logic", "ID_002": "Data bus width 32-bit"}}
    
    CODE:
    {tagged_chunk}
    """
    
    response = client.chat.completions.create(
        model=MODEL,
        messages=[{"role": "user", "content": prompt}],
        response_format={ "type": "json_object" }
    )
    return json.loads(response.choices[0].message.content)

def process_rtl(input_path, output_path):
    with open(input_path, 'r') as f:
        lines = f.readlines()

    # --- PHASE 1: TAGGING ---
    tagged_lines = []
    tag_counter = 0
    decl_pattern = re.compile(r'^\s*(input|output|inout|wire|reg|logic|parameter|always|assign)\b')
    
    for line in lines:
        if decl_pattern.match(line) and ';' in line or 'always' in line:
            tag = f"ID_{tag_counter:03d}"
            tagged_lines.append(f"{line.rstrip()} // [{tag}]\n")
            tag_counter += 1
        else:
            tagged_lines.append(line)

    # --- PHASE 2: API CALLS (Chunked) ---
    # We send chunks of ~100 tagged lines at a time to stay under context limits
    full_comment_map = {}
    chunk_size = 100 
    tagged_only = [line for line in tagged_lines if "// [ID_" in line]
    
    print(f"Processing {len(tagged_only)} tags in chunks...")
    
    for i in range(0, len(tagged_only), chunk_size):
        chunk = "".join(tagged_only[i : i + chunk_size])
        try:
            chunk_comments = get_llm_comments(chunk)
            full_comment_map.update(chunk_comments)
            print(f"Completed chunk {i//chunk_size + 1}")
        except Exception as e:
            print(f"Error in chunk starting at {i}: {e}")

    # --- PHASE 3: MERGING ---
    final_output = []
    for line in tagged_lines:
        match = re.search(r'// \[(ID_\d+)\]', line)
        if match:
            tag = match.group(1)
            comment = full_comment_map.get(tag, "")
            # Keep the original code, swap the [ID] for the actual comment
            clean_code = line.split('// [')[0].rstrip()
            final_output.append(f"{clean_code} // {comment}\n")
        else:
            final_output.append(line)

    with open(output_path, 'w') as f:
        f.writelines(final_output)
    print(f"Done! Commented RTL saved to {output_path}")

# Run it
process_rtl("input_design.v", "commented_design.v")
