#!/bin/bash
# ============================================================
# 🐳 Instalação automatizada do Docker Desktop no Arch Linux
# ------------------------------------------------------------
# - Instala o Docker Desktop via AUR (yay)
# - Escolhe qemu-base automaticamente
# - Adiciona o usuário atual ao grupo docker
# - Desativa a inicialização automática do serviço
# ============================================================

set -e  # Para o script se algo falhar

echo "🚀 Iniciando instalação do Docker Desktop no Arch Linux..."

# Verifica se o yay está instalado
if ! command -v yay &> /dev/null; then
    echo "❌ 'yay' não encontrado. Instale-o antes de rodar este script."
    exit 1
fi

# Instalar o Docker Desktop com yay
echo "📦 Instalando Docker Desktop via AUR..."
yay -S --noconfirm --needed docker-desktop qemu-base

# Desativar inicialização automática (caso esteja ativa)
echo "⚙️ Desativando inicialização automática do Docker Desktop..."
systemctl --user disable docker-desktop 2>/dev/null || true

# Garantir que o Docker Desktop não está rodando
echo "🛑 Parando serviço do Docker Desktop (se estiver ativo)..."
systemctl --user stop docker-desktop 2>/dev/null || true

# Adicionar o usuário atual ao grupo docker
echo "👤 Adicionando o usuário '$USER' ao grupo 'docker'..."
sudo usermod -aG docker "$USER"

# Exibir instruções finais
echo ""
echo "✅ Instalação concluída!"
echo "⚙️ O Docker Desktop foi instalado e o autostart está desativado."
echo ""
echo "🔁 Para aplicar as permissões do grupo docker, faça logout/login (ou reinicie)."
echo ""
echo "▶️ Para iniciar manualmente o Docker Desktop, use:"
echo "    systemctl --user start docker-desktop"
echo ""
echo "🧰 Para verificar o status:"
echo "    systemctl --user status docker-desktop"
echo ""
echo "🐋 Para testar o Docker:"
echo "    docker run hello-world"
echo ""
echo "💡 Dica: Você pode abrir o Docker Desktop pelo menu do KDE/GNOME quando quiser."
