#!/usr/bin/env bash

# Library for installing tools from GitHub releases
# Usage: source this file and call _installFromGitHubRelease_ with configuration
# Set STRATEGY variable to "curl" (default) or "gh" to choose download method

# Default strategy if not set
: "${STRATEGY:=curl}"

# Fetch version using curl strategy
_fetchVersionCurl_() {
    local repo="$1"
    local api_url="https://api.github.com/repos/${repo}/releases/latest"
    local api_response
    api_response=$(curl -sSL -w "\n%{http_code}" "${api_url}")
    local api_code="${api_response##*$'\n'}"
    local api_body="${api_response%$'\n'*}"
    
    if [[ "$api_code" -ne 200 ]]; then
        error "Failed to fetch release info from ${api_url}"
        error "HTTP Status Code: ${api_code}"
        error "Response: ${api_body}"
        return 1
    fi
    
    local version
    version=$(echo "$api_body" | grep -Po '"tag_name": "\K[^"]*')
    
    if [[ -z "$version" ]]; then
        error "Failed to parse version from GitHub API response"
        error "Repository: ${repo}"
        debug "API Response: ${api_body}"
        return 1
    fi
    
    echo "$version"
}

# Fetch version using gh CLI strategy
_fetchVersionGh_() {
    local repo="$1"
    
    if ! command -v gh &>/dev/null; then
        error "gh CLI is not installed. Please install it or use STRATEGY=curl"
        return 1
    fi
    
    local version
    version=$(gh release view --repo "$repo" --json tagName --jq .tagName 2>&1)
    
    if [[ $? -ne 0 ]] || [[ -z "$version" ]]; then
        error "Failed to fetch release info using gh CLI"
        error "Repository: ${repo}"
        error "Response: ${version}"
        return 1
    fi
    
    echo "$version"
}

# Download asset using curl strategy
_downloadAssetCurl_() {
    local repo="$1"
    local version="$2"
    local expanded_pattern="$3"
    
    debug "Downloading from ${repo} ${version}"
    debug "Pattern: ${expanded_pattern}"
    
    local download_url="https://github.com/${repo}/releases/download/${version}/${expanded_pattern}"
    local http_response
    http_response=$(curl -sSL -w "\n%{http_code}" -o "${expanded_pattern}" "${download_url}")
    local http_code="${http_response##*$'\n'}"
    
    if [[ "$http_code" -ne 200 ]]; then
        error "Failed to download from ${download_url}"
        error "HTTP Status Code: ${http_code}"
        if [[ -f "${expanded_pattern}" ]]; then
            error "Response: $(cat "${expanded_pattern}")"
            rm -f "${expanded_pattern}"
        fi
        return 1
    fi
    
    return 0
}

# Download asset using gh CLI strategy
_downloadAssetGh_() {
    local repo="$1"
    local version="$2"
    local expanded_pattern="$3"
    
    if ! command -v gh &>/dev/null; then
        error "gh CLI is not installed. Please install it or use STRATEGY=curl"
        return 1
    fi
    
    debug "Downloading from ${repo} ${version} using gh CLI"
    debug "Pattern: ${expanded_pattern}"
    
    if ! gh release download --repo "$repo" "$version" --pattern "$expanded_pattern" 2>&1; then
        error "Failed to download using gh CLI"
        return 1
    fi
    
    return 0
}

_installFromGitHubRelease_() {
    local repo="$1"
    local package="$2"
    local asset_pattern="$3"
    local version_cmd="$4"
    local post_install="$5"  # Optional: function name to call after download

    header "Verify ${package} installation and check for updates"

    info "Using STRATEGY: ${STRATEGY}"

    # Fetch version based on strategy
    local version
    case "$STRATEGY" in
        curl)
            version=$(_fetchVersionCurl_ "$repo") || return 1
            ;;
        gh)
            version=$(_fetchVersionGh_ "$repo") || return 1
            ;;
        *)
            error "Unknown STRATEGY: ${STRATEGY}. Use 'curl' or 'gh'"
            return 1
            ;;
    esac
    
    local vless_version
    vless_version=$(echo "$version" | sed 's/v//g')

    # Check if already installed and up to date
    if command -v "$package" &>/dev/null; then
        local current_version
        current_version=$(eval "$version_cmd" 2>/dev/null || echo "unknown")

        if [[ "$current_version" == "$vless_version" ]]; then
            info "${package} is up to date (${vless_version})"
            return 0
        fi
        info "${package} ${current_version} -> ${vless_version}"
    else
        info "Installing ${package} ${vless_version}"
    fi

    # Create temp directory and download
    _makeTempDir_ "install-${package}"
    pushd "${TMP_DIR}" &>/dev/null || exit 1

    # Expand variables in asset pattern
    local expanded_pattern
    expanded_pattern=$(eval echo "$asset_pattern")

    # Download based on strategy
    case "$STRATEGY" in
        curl)
            _downloadAssetCurl_ "$repo" "$version" "$expanded_pattern" || {
                popd &>/dev/null
                return 1
            }
            ;;
        gh)
            _downloadAssetGh_ "$repo" "$version" "$expanded_pattern" || {
                popd &>/dev/null
                return 1
            }
            ;;
    esac

    # Call post-install function if provided
    if [[ -n "$post_install" ]] && declare -f "$post_install" &>/dev/null; then
        "$post_install" "$vless_version" || {
            error "Post-install failed for ${package}"
            popd &>/dev/null
            return 1
        }
    fi

    popd &>/dev/null || exit 1
    success "${package} installed successfully"
}
