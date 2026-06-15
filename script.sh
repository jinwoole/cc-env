cat << 'EOF' >> ~/.zshrc

# Claude Code 멀티 환경 CRUD 매니저 (.claude-env 전용 폴더 버전)
function claude-env() {
    local CMD=$1
    local NAME=$2
    
    # 기본 루트 저장소를 $HOME/.claude-env로 지정
    local ROOT_DIR="$HOME/.claude-env"
    
    # 루트 디렉토리가 없으면 최초 1회 자동 생성
    if [ ! -d "$ROOT_DIR" ]; then
        mkdir -p "$ROOT_DIR"
    fi

    case "$CMD" in
        # 1. Create & Run (생성 및 실행)
        "run" | "")
            if [ -z "$NAME" ]; then
                echo "❌ 사용법: claude-env run [환경이름]"
                echo "💡 팁: 'claude-env list'로 기존 환경 목록을 확인해보세요."
                return 1
            fi
            local TARGET_DIR="$ROOT_DIR/$NAME"
            if [ ! -d "$TARGET_DIR" ]; then
                mkdir -p "$TARGET_DIR"
                echo "✨ [$NAME] 환경이 새로 생성되었습니다."
                echo "📂 경로: $TARGET_DIR"
            fi
            echo "🚀 [$NAME] 환경으로 Claude Code를 실행합니다..."
            CLAUDE_CONFIG_DIR="$TARGET_DIR" claude
            ;;

        # 2. Read (목록 조회)
        "list" | "ls")
            echo "📂 [현재 생성된 Claude Code 환경 목록]"
            echo "📍 저장소: $ROOT_DIR"
            echo "----------------------------------------"
            local count=0
            
            # 📂 폴더 내부 목록 탐색
            for dir in "$ROOT_DIR"/*; do
                if [ -d "$dir" ]; then
                    local env_name=$(basename "$dir")
                    if [ "$env_name" != "*" ] && [ -n "$env_name" ]; then
                        echo "👉 $env_name"
                        count=$((count+1))
                    fi
                fi
            done
            
            if [ $count -eq 0 ]; then
                echo "아직 생성된 커스텀 환경이 없습니다."
                echo "💡 'claude-env run [이름]'으로 첫 환경을 만들어보세요!"
            fi
            echo "----------------------------------------"
            ;;

        # 3. Update (이름 변경)
        "rename" | "mv")
            local NEW_NAME=$3
            if [ -z "$NAME" ] || [ -z "$NEW_NAME" ]; then
                echo "❌ 사용법: claude-env rename [기존이름] [새이름]"
                return 1
            fi
            if [ ! -d "$ROOT_DIR/$NAME" ]; then
                echo "❌ [$NAME] 환경이 존재하지 않습니다."
                return 1
            fi
            mv "$ROOT_DIR/$NAME" "$ROOT_DIR/$NEW_NAME"
            echo "✅ 환경 이름이 변경되었습니다: [$NAME] ➡️ [$NEW_NAME]"
            ;;

        # 4. Delete (삭제)
        "delete" | "rm")
            if [ -z "$NAME" ]; then
                echo "❌ 사용법: claude-env delete [환경이름]"
                return 1
            fi
            if [ ! -d "$ROOT_DIR/$NAME" ]; then
                echo "❌ [$NAME] 환경이 존재하지 않습니다."
                return 1
            fi
            
            # 안전장치
            read -q "REPLY?⚠️  [$NAME] 환경(인증 정보, 히스토리 전체)을 정말 삭제하시겠습니까? (y/n): "
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm -rf "$ROOT_DIR/$NAME"
                echo "🗑️  [$NAME] 환경이 삭제되었습니다."
            else
                echo "❌ 삭제가 취소되었습니다."
            fi
            ;;

        # 도움말
        *)
            echo "❓ 올바른 명령어를 입력해주세요."
            echo "  claude-env run [이름]    : 환경 실행 (없으면 자동 생성)"
            echo "  claude-env list          : 생성된 모든 환경 보기"
            echo "  claude-env rename [A] [B]: 환경 이름 바꾸기"
            echo "  claude-env delete [이름] : 환경 삭제하기"
            ;;
    esac
}
EOF
source ~/.zshrc