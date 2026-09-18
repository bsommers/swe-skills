#!/usr/bin/env bash
#
# swe-skills installer: Installs skills from this repository globally or locally
# for any combination of Antigravity (agy), Claude Code, and Cursor.
#

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

# Colors for terminal output
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "========================================================"
    echo "          SWE-Skills Multi-Agent Installer              "
    echo "========================================================"
    echo -e "${NC}"
}

usage() {
    echo -e "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -s, --scope <global|local|both>   Installation scope (default: prompt)"
    echo "  -a, --agents <agy,claude,cursor|all> Comma-separated list of target agents (default: prompt)"
    echo "  -k, --skills <name1,name2|all>    Skills to install (default: all)"
    echo "  -t, --target <path>               Target directory for local install (default: current directory)"
    echo "  -m, --mode <symlink|copy>         Link or copy files (default: symlink for dev, copy fallback)"
    echo "  -l, --list                        List available skills in this repository"
    echo "  -u, --uninstall                   Uninstall specified skills from selected agents/scope"
    echo "  -h, --help                        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                # Interactive wizard"
    echo "  $0 --scope global --agents all    # Install all skills globally for agy, claude, cursor"
    echo "  $0 --scope local --agents agy,claude --target /path/to/my-project"
    echo "  $0 --skills code-architecture-review --agents claude --scope global"
    echo "  $0 --uninstall --agents cursor --scope global"
    exit 0
}

# Find all available skills in skills/ directory
get_available_skills() {
    local skills=()
    if [ -d "$SKILLS_DIR" ]; then
        for dir in "$SKILLS_DIR"/*; do
            if [ -d "$dir" ] && [ -f "$dir/SKILL.md" ]; then
                skills+=("$(basename "$dir")")
            fi
        done
    fi
    echo "${skills[@]}"
}

list_skills() {
    print_banner
    echo -e "${BOLD}Available skills in this repository:${NC}"
    echo ""
    local skills=($(get_available_skills))
    if [ ${#skills[@]} -eq 0 ]; then
        echo "  (No skills found in $SKILLS_DIR)"
        return
    fi
    for skill in "${skills[@]}"; do
        local desc=""
        if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
            desc=$(grep -m 1 "^description:" "$SKILLS_DIR/$skill/SKILL.md" | sed -E 's/description:[[:space:]]*["'\'']?//; s/["'\'']?$//')
        fi
        echo -e "  ${GREEN}• ${BOLD}${skill}${NC}"
        if [ -n "$desc" ]; then
            echo -e "    ${desc}"
        fi
        echo ""
    done
}

# Defaults
SCOPE=""
AGENTS=""
SELECTED_SKILLS="all"
TARGET_DIR="$(pwd)"
MODE="symlink"
UNINSTALL=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--scope)
            SCOPE="$2"
            shift 2
            ;;
        -a|--agents)
            AGENTS="$2"
            shift 2
            ;;
        -k|--skills)
            SELECTED_SKILLS="$2"
            shift 2
            ;;
        -t|--target)
            TARGET_DIR="$2"
            shift 2
            ;;
        -m|--mode)
            MODE="$2"
            shift 2
            ;;
        -l|--list)
            list_skills
            exit 0
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Resolve skills to install
available_skills=($(get_available_skills))
if [ ${#available_skills[@]} -eq 0 ]; then
    echo -e "${RED}Error: No valid skills found in ${SKILLS_DIR}${NC}"
    exit 1
fi

# Interactive mode if arguments not provided
interactive_prompt() {
    print_banner

    # 1. Select Skills
    if [ -z "$SELECTED_SKILLS" ] || [ "$SELECTED_SKILLS" = "prompt" ]; then
        echo -e "${BOLD}Available Skills:${NC}"
        local i=1
        for s in "${available_skills[@]}"; do
            echo "  $i) $s"
            ((i++))
        done
        echo "  a) All skills"
        read -r -p "Select skills to install [a]: " skill_choice
        skill_choice="${skill_choice:-a}"
        if [ "$skill_choice" = "a" ] || [ "$skill_choice" = "A" ]; then
            SELECTED_SKILLS="all"
        elif [[ "$skill_choice" =~ ^[0-9]+$ ]] && [ "$skill_choice" -le "${#available_skills[@]}" ] && [ "$skill_choice" -ge 1 ]; then
            SELECTED_SKILLS="${available_skills[$((skill_choice-1))]}"
        else
            SELECTED_SKILLS="all"
        fi
    fi

    # 2. Select Scope
    if [ -z "$SCOPE" ]; then
        echo ""
        echo -e "${BOLD}Select Installation Scope:${NC}"
        echo "  1) Global (User profile / home directory)"
        echo "  2) Local in Repository (Target workspace)"
        echo "  3) Both Global and Local"
        read -r -p "Choose scope [1]: " scope_choice
        case "$scope_choice" in
            2) SCOPE="local" ;;
            3) SCOPE="both" ;;
            *) SCOPE="global" ;;
        esac
    fi

    # If local or both, ask target directory
    if [ "$SCOPE" = "local" ] || [ "$SCOPE" = "both" ]; then
        if [ "$TARGET_DIR" = "$(pwd)" ]; then
            echo ""
            read -r -p "Enter local target repository path [$(pwd)]: " custom_target
            TARGET_DIR="${custom_target:-$(pwd)}"
        fi
    fi

    # 3. Select Target Agents
    if [ -z "$AGENTS" ]; then
        echo ""
        echo -e "${BOLD}Select Target Agents:${NC}"
        echo "  1) All (Antigravity + Claude Code + Cursor)"
        echo "  2) Antigravity (agy)"
        echo "  3) Claude Code"
        echo "  4) Cursor"
        echo "  5) Custom combination"
        read -r -p "Choose target agents [1]: " agent_choice
        case "$agent_choice" in
            2) AGENTS="agy" ;;
            3) AGENTS="claude" ;;
            4) AGENTS="cursor" ;;
            5)
                read -r -p "Enter comma-separated agents (e.g. agy,claude): " custom_agents
                AGENTS="$custom_agents"
                ;;
            *) AGENTS="all" ;;
        esac
    fi

    # 4. Select Mode
    if [ -z "$MODE" ]; then
        echo ""
        echo -e "${BOLD}Select Install Mode:${NC}"
        echo "  1) Symlink (Recommended: updates automatically when repo changes)"
        echo "  2) Copy (Standalone copy)"
        read -r -p "Choose mode [1]: " mode_choice
        case "$mode_choice" in
            2) MODE="copy" ;;
            *) MODE="symlink" ;;
        esac
    fi
}

# Trigger interactive wizard if needed
if [ -z "$SCOPE" ] || [ -z "$AGENTS" ]; then
    interactive_prompt
fi

# Expand skills array
SKILLS_TO_INSTALL=()
if [ "$SELECTED_SKILLS" = "all" ]; then
    SKILLS_TO_INSTALL=("${available_skills[@]}")
else
    IFS=',' read -ra ADDR <<< "$SELECTED_SKILLS"
    for s in "${ADDR[@]}"; do
        s_trimmed=$(echo "$s" | xargs)
        if [ -d "$SKILLS_DIR/$s_trimmed" ]; then
            SKILLS_TO_INSTALL+=("$s_trimmed")
        else
            echo -e "${YELLOW}Warning: Skill '$s_trimmed' not found in $SKILLS_DIR. Skipping.${NC}"
        fi
    done
fi

if [ ${#SKILLS_TO_INSTALL[@]} -eq 0 ]; then
    echo -e "${RED}No valid skills selected for installation.${NC}"
    exit 1
fi

# Expand agents
INSTALL_AGY=false
INSTALL_CLAUDE=false
INSTALL_CURSOR=false

if [ "$AGENTS" = "all" ]; then
    INSTALL_AGY=true
    INSTALL_CLAUDE=true
    INSTALL_CURSOR=true
else
    IFS=',' read -ra AGENT_ARR <<< "$AGENTS"
    for a in "${AGENT_ARR[@]}"; do
        a_clean=$(echo "$a" | tr '[:upper:]' '[:lower:]' | xargs)
        case "$a_clean" in
            agy|antigravity|gemini) INSTALL_AGY=true ;;
            claude|claudecode|"claude code") INSTALL_CLAUDE=true ;;
            cursor|cursorrules) INSTALL_CURSOR=true ;;
            *) echo -e "${YELLOW}Warning: Unrecognized agent '$a_clean'. Ignoring.${NC}" ;;
        esac
    done
fi

install_or_link() {
    local src="$1"
    local dest="$2"
    local name="$3"

    mkdir -p "$(dirname "$dest")"

    if [ "$UNINSTALL" = true ]; then
        if [ -e "$dest" ] || [ -L "$dest" ]; then
            rm -rf "$dest"
            echo -e "  ${RED}✖ Uninstalled:${NC} $dest"
        fi
        return
    fi

    # Remove existing destination if present
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        rm -rf "$dest"
    fi

    if [ "$MODE" = "symlink" ]; then
        ln -sf "$src" "$dest"
        echo -e "  ${GREEN}✓ Linked (symlink):${NC} $dest -> $src"
    else
        cp -r "$src" "$dest"
        echo -e "  ${GREEN}✓ Copied:${NC} $dest"
    fi
}

install_cursor_rule() {
    local skill_src="$1"
    local dest_rule_file="$2"
    local skill_name="$3"

    mkdir -p "$(dirname "$dest_rule_file")"

    if [ "$UNINSTALL" = true ]; then
        if [ -f "$dest_rule_file" ] || [ -L "$dest_rule_file" ]; then
            rm -f "$dest_rule_file"
            echo -e "  ${RED}✖ Uninstalled Cursor rule:${NC} $dest_rule_file"
        fi
        return
    fi

    # If symlinking, create symlink directly to SKILL.md if format matches
    if [ "$MODE" = "symlink" ]; then
        ln -sf "$skill_src/SKILL.md" "$dest_rule_file"
        echo -e "  ${GREEN}✓ Linked Cursor rule:${NC} $dest_rule_file -> $skill_src/SKILL.md"
    else
        cp "$skill_src/SKILL.md" "$dest_rule_file"
        echo -e "  ${GREEN}✓ Created Cursor rule:${NC} $dest_rule_file"
    fi
}

echo ""
if [ "$UNINSTALL" = true ]; then
    echo -e "${BOLD}${RED}Uninstalling Skills...${NC}"
else
    echo -e "${BOLD}${GREEN}Installing Skills (${MODE})...${NC}"
fi
echo -e "Skills: ${CYAN}${SKILLS_TO_INSTALL[*]}${NC}"
echo ""

# 1. Global Installation
if [ "$SCOPE" = "global" ] || [ "$SCOPE" = "both" ]; then
    echo -e "${BOLD}${BLUE}=== Global Scope ===${NC}"

    for skill in "${SKILLS_TO_INSTALL[@]}"; do
        src_path="${SKILLS_DIR}/${skill}"

        # Antigravity Global
        if [ "$INSTALL_AGY" = true ]; then
            dest_path="${HOME}/.gemini/config/skills/${skill}"
            echo -e "${BOLD}[Antigravity Global]${NC} ${skill}"
            install_or_link "$src_path" "$dest_path" "$skill"
        fi

        # Claude Code Global
        if [ "$INSTALL_CLAUDE" = true ]; then
            dest_path="${HOME}/.claude/skills/${skill}"
            echo -e "${BOLD}[Claude Code Global]${NC} ${skill}"
            install_or_link "$src_path" "$dest_path" "$skill"
        fi

        # Cursor Global
        if [ "$INSTALL_CURSOR" = true ]; then
            dest_skill_path="${HOME}/.cursor/skills/${skill}"
            dest_rule_path="${HOME}/.cursor/rules/${skill}.mdc"
            echo -e "${BOLD}[Cursor Global]${NC} ${skill}"
            install_or_link "$src_path" "$dest_skill_path" "$skill"
            install_cursor_rule "$src_path" "$dest_rule_path" "$skill"
        fi
    done
    echo ""
fi

# 2. Local Installation
if [ "$SCOPE" = "local" ] || [ "$SCOPE" = "both" ]; then
    echo -e "${BOLD}${BLUE}=== Local Scope (Target: ${TARGET_DIR}) ===${NC}"

    if [ ! -d "$TARGET_DIR" ]; then
        echo -e "${YELLOW}Target directory '$TARGET_DIR' does not exist. Creating it...${NC}"
        mkdir -p "$TARGET_DIR"
    fi

    for skill in "${SKILLS_TO_INSTALL[@]}"; do
        src_path="${SKILLS_DIR}/${skill}"

        # Antigravity Local (.agents/skills)
        if [ "$INSTALL_AGY" = true ]; then
            dest_path="${TARGET_DIR}/.agents/skills/${skill}"
            echo -e "${BOLD}[Antigravity Local]${NC} ${skill}"
            install_or_link "$src_path" "$dest_path" "$skill"
        fi

        # Claude Code Local (.claude/skills)
        if [ "$INSTALL_CLAUDE" = true ]; then
            dest_path="${TARGET_DIR}/.claude/skills/${skill}"
            echo -e "${BOLD}[Claude Code Local]${NC} ${skill}"
            install_or_link "$src_path" "$dest_path" "$skill"
        fi

        # Cursor Local (.cursor/rules and .cursor/skills)
        if [ "$INSTALL_CURSOR" = true ]; then
            dest_skill_path="${TARGET_DIR}/.cursor/skills/${skill}"
            dest_rule_path="${TARGET_DIR}/.cursor/rules/${skill}.mdc"
            echo -e "${BOLD}[Cursor Local]${NC} ${skill}"
            install_or_link "$src_path" "$dest_skill_path" "$skill"
            install_cursor_rule "$src_path" "$dest_rule_path" "$skill"
        fi
    done
    echo ""
fi

echo -e "${GREEN}${BOLD}✓ Operation completed successfully!${NC}"
echo ""
echo -e "${BOLD}How to use installed skills:${NC}"
if [ "$INSTALL_CLAUDE" = true ]; then
    echo -e "  • ${CYAN}Claude Code:${NC} Type ${BOLD}/${SKILLS_TO_INSTALL[0]}${NC} in chat"
fi
if [ "$INSTALL_AGY" = true ]; then
    echo -e "  • ${CYAN}Antigravity (agy):${NC} The agent will automatically detect and trigger the skill, or mention it in your prompt"
fi
if [ "$INSTALL_CURSOR" = true ]; then
    echo -e "  • ${CYAN}Cursor:${NC} Rules are loaded automatically in Composer / Agent, or reference in chat"
fi
echo ""
