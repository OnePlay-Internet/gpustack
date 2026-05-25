import os
import glob
import shutil
import gzip

# Root directory of gpustack repository
root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ui_dir = os.path.join(root_dir, 'gpustack', 'ui')
logos_dir = os.path.join(root_dir, 'logos')

print("Running UI branding replacement...")
print(f"Repository Root: {root_dir}")
print(f"UI Directory: {ui_dir}")
print(f"Logos Directory: {logos_dir}")

# 1. Overwrite custom logo assets
# Define logo mapping
logo_mappings = [
    # (source_logo_filename, target_filename_pattern)
    ('favicon.png', 'favicon.png'),
    ('favicon.png', 'favicon.ico'),  # copy PNG to .ico filename, browsers support this
    ('favicon.png', 'static/favicon.png'),
    ('favicon.png', 'static/favicon.ico'),
    ('logo_with_title.png', 'static/gpustack-logo.*.png'),
    ('only_logo_transparent.png', 'static/small-logo-200x200.*.png'),
]

for src_name, dest_pattern in logo_mappings:
    src_path = os.path.join(logos_dir, src_name)
    if not os.path.exists(src_path):
        print(f"Warning: Source logo {src_path} does not exist.")
        continue

    # Resolve the destination glob pattern
    dest_glob = os.path.join(ui_dir, dest_pattern)
    matched_files = glob.glob(dest_glob)

    if matched_files:
        for matched_file in matched_files:
            shutil.copy2(src_path, matched_file)
            print(f"Replaced logo asset: {matched_file} with {src_name}")
    else:
        # If no files matched, and it's a fixed path (no * in it), we can create/copy it directly
        if '*' not in dest_pattern:
            dest_path = os.path.join(ui_dir, dest_pattern)
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)
            shutil.copy2(src_path, dest_path)
            print(f"Created logo asset: {dest_path} with {src_name}")
        else:
            print(f"Warning: Could not find any file matching pattern: {dest_glob}")

# 2. Define text replacements for HTML and JS
replacements = [
    ("https://github.com/gpustack/gpustack/releases", "https://samaira.ai"),
    ("https://github.com/gpustack/gpustack/issues/new/choose", "https://samaira.ai"),
    ("https://github.com/gpustack/gpustack/issues/1979", "https://samaira.ai"),
    ("https://github.com/gpustack/gpustack", "https://samaira.ai"),
    ("https://discord.gg/VXYJzuaqwD", "https://samaira.ai"),
    ("https://docs.gpustack.ai/latest/faq/", "https://samaira.ai"),
    (
        "https://docs.gpustack.ai/latest/troubleshooting/?h=reset#reset-admin-password",
        "https://samaira.ai",
    ),
    (
        "https://docs.gpustack.ai/latest/user-guide/built-in-inference-backends/?h=parameters+reference#parameters-reference_2",
        "https://samaira.ai",
    ),
    (
        "https://docs.gpustack.ai/latest/user-guide/model-deployment-management/#enable-generic-proxy",
        "https://samaira.ai",
    ),
    (
        "https://docs.gpustack.ai/latest/installation/installation-requirements/",
        "https://samaira.ai",
    ),
    ("docs.gpustack.ai", "samaira.ai"),
    ("YOUR_GPUSTACK_API_KEY", "YOUR_SAMAIRA_AI_API_KEY"),
]

modified_count = 0

for root, dirs, files in os.walk(ui_dir):
    for file in files:
        if file.endswith('.js') or file.endswith('.html'):
            path = os.path.join(root, file)
            try:
                # Read content
                with open(path, 'r', encoding='utf-8') as f:
                    content = f.read()

                original_content = content

                # Apply URLs and key replacements
                for target, replacement in replacements:
                    content = content.replace(target, replacement)

                # Apply Samaira / GPUStack text replacements carefully
                # We want to replace "GPUStack Server" with "Samaira AI Server", and "GPUStack" with "Samaira AI"
                content = content.replace("GPUStack Server", "Samaira AI Server")
                content = content.replace("gpustack Server", "Samaira AI Server")
                content = content.replace("GPUStack", "Samaira AI")

                # Also clean up any occurrences of "Samaira" or "Samaira Server" from previous half-replacements
                content = content.replace("Samaira.AI", "__SAMAIRA_TEMP__")
                content = content.replace("Samaira AI", "__SAMAIRA_TEMP__")
                content = content.replace("Samaira", "__SAMAIRA_TEMP__")
                content = content.replace("__SAMAIRA_TEMP__", "Samaira AI")

                if content != original_content:
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"Modified text in: {path}")
                    modified_count += 1

                    # If this is a JS/HTML file and a .gz version exists, re-compress it
                    gz_path = path + '.gz'
                    if os.path.exists(gz_path):
                        with open(path, 'rb') as f_in:
                            with gzip.open(gz_path, 'wb') as f_out:
                                shutil.copyfileobj(f_in, f_out)
                        print(f"  Re-compressed: {gz_path}")
            except Exception as e:
                print(f"Error processing {path}: {e}")

print(f"Completed! Total modified text files: {modified_count}")
