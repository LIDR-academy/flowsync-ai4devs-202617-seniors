#!/usr/bin/env bash
# Publica las ramas del curso en el repo de un cohorte, en su cadencia.
#
# POR QUÉ EXISTE, y no es comodidad:
#   `s(N+1)/start` ES la solución de la sesión N. Verificado contra los SHA del
#   repo del curso: s2/start = s1/end, s3/start = s2/end, s5/start = s4/end.
#   Por eso un repo de cohorte NO puede nacer con todas las ramas: sería repartir
#   el curso resuelto el primer día. Y tampoco puede nacer sin ninguna, porque
#   entonces el prework del alumno no tiene de dónde partir.
#   (`gh repo create --include-all-branches` es opt-in: sin él, una copia de
#   plantilla se lleva SOLO la rama por defecto. Aquí se usa eso a propósito.)
#
# Uso:
#   publicar-cohorte.sh crear    202610-seniors
#   publicar-cohorte.sh publicar 202610-seniors s3 start
#   publicar-cohorte.sh estado   202610-seniors
set -euo pipefail

ORG=LIDR-academy
FUENTE="$ORG/flowsync-ai4devs-fundacional"

# git con la MISMA cuenta que gh. Sin esto, `gh repo create` usa la cuenta de gh
# y el `git clone` de justo después usa la que haya en el llavero del sistema (el
# git de Apple trae `credential.helper=osxkeychain` de fábrica). Con varias
# cuentas de GitHub en la máquina son distintas, y como el fundacional es
# privado, GitHub responde «Repository not found» en vez de «sin permiso»: el
# repo del cohorte queda creado y sin s1/start. El `credential.helper=` vacío
# anula los helpers anteriores; `gh auth git-credential` da el token de la
# cuenta ACTIVA de gh (o de GH_TOKEN si está definido), sin tocar tu config.
git_gh () { git -c credential.helper= -c 'credential.helper=!gh auth git-credential' "$@"; }

# Falla pronto y diciendo con qué cuenta, en vez de a medio crear.
CUENTA=""
comprobar_cuenta () {
  if ! CUENTA=$(gh api user --jq .login 2>/dev/null); then
    if [ -n "${GH_TOKEN:-}${GITHUB_TOKEN:-}" ]; then
      echo "✗ Tienes GH_TOKEN o GITHUB_TOKEN definido y GitHub no lo acepta. Quítalo o cámbialo."
    else
      echo "✗ gh no está autenticado. Corre: gh auth login"
    fi
    exit 1
  fi
  if ! gh api "repos/$FUENTE" >/dev/null 2>&1; then
    echo "✗ La cuenta activa de gh, «${CUENTA}», no ve $FUENTE."
    if [ -n "${GH_TOKEN:-}${GITHUB_TOKEN:-}" ]; then
      echo "  Tienes GH_TOKEN o GITHUB_TOKEN definido, y gana sobre la cuenta activa: quítalo o cámbialo."
    else
      echo "  Si tienes varias cuentas en gh, cambia a la que tiene acceso:"
      echo "    gh auth status              # las lista"
      echo "    gh auth switch -u <cuenta>"
    fi
    exit 1
  fi
  echo "Usando la cuenta de gh «${CUENTA}»."
}

etiqueta_valida () {
  # fecha + al menos un segmento de track. Sin track, los cohortes colisionan.
  [[ "$1" =~ ^[0-9]{6}(-[A-Za-z0-9]+)+$ ]] || {
    echo "✗ Etiqueta inválida: «$1»"
    echo "  Formato: AAAAMM-track   (p. ej. 202610-seniors, 202610-seniors-II)"
    echo "  El track NO es opcional: sin él, dos cohortes del mismo mes chocan."
    exit 1; }
}

repo_de () { echo "$ORG/flowsync-ai4devs-$1"; }

cmd_crear () {
  local et="$1"; etiqueta_valida "$et"
  local repo; repo=$(repo_de "$et")
  echo "Creando $repo desde ${FUENTE}…"
  gh repo create "$repo" --template "$FUENTE" --public \
     --description "FlowSync — cohorte $et. Forkea este repo, trabaja en tu rama y abre un PR. NO es el repo canónico." >/dev/null
  # SIN --include-all-branches: solo viene `main`. Es deliberado (ver cabecera).
  echo "  ✓ repo creado (solo main)"
  sleep 3   # GitHub tarda un instante en dejar el repo utilizable
  cmd_publicar "$et" s1 start
  echo
  echo "✓ Listo. El cohorte arranca con main + s1/start."
  echo "  Las demás ramas se publican una a una, cuando toque:"
  echo "    $(basename "$0") publicar $et s1 end     # después de impartir el Módulo 1"
}

cmd_publicar () {
  local et="$1" mod="$2" tipo="$3"; etiqueta_valida "$et"
  [[ "$mod"  =~ ^s[1-7]$        ]] || { echo "✗ Módulo inválido: «${mod}» (s1..s7)"; exit 1; }
  [[ "$tipo" =~ ^(start|end)$   ]] || { echo "✗ Tipo inválido: «${tipo}» (start|end)"; exit 1; }
  local repo rama n; repo=$(repo_de "$et"); rama="$mod/$tipo"; n="${mod#s}"

  # GUARDARRAÍL: publicar sN/start reparte s(N-1)/end, y eso no se ve en el nombre.
  if [ "$tipo" = "start" ] && [ "$n" -gt 1 ]; then
    echo "⚠️  ATENCIÓN: publicar «${rama}» entrega también la SOLUCIÓN del Módulo $((n-1))."
    echo "    La cadena del curso hace que s$n/start y s$((n-1))/end sean el mismo commit."
    echo "    Publícala solo si el Módulo $((n-1)) ya se impartió."
    read -r -p "    ¿Seguir? (escribe SI): " r
    [ "$r" = "SI" ] || { echo "  Cancelado."; exit 1; }
  fi

  local tmp; tmp=$(mktemp -d); trap 'rm -rf "${tmp:-}"' EXIT
  git_gh clone -q --bare "https://github.com/$FUENTE.git" "$tmp/src"
  git -C "$tmp/src" rev-parse --verify "refs/heads/$rama" >/dev/null 2>&1 \
    || { echo "✗ «${rama}» no existe en $FUENTE"; exit 1; }
  # nunca --force: si ya está publicada y alguien trabajó encima, esto falla en vez de pisarlo
  if git_gh -C "$tmp/src" push -q "https://github.com/$repo.git" "refs/heads/$rama:refs/heads/$rama" 2>/dev/null; then
    echo "  ✓ $rama publicada en $repo"
  else
    if gh api "repos/$repo/branches/${rama/\//%2F}" >/dev/null 2>&1; then
      echo "  = $rama ya estaba publicada y no ha cambiado. Nada que hacer."
    else
      echo "✗ No se pudo publicar $rama con la cuenta «${CUENTA}». ¿Tiene permiso de escritura en $repo?"; exit 1
    fi
  fi
}

cmd_estado () {
  local et="$1"; etiqueta_valida "$et"
  local repo; repo=$(repo_de "$et")
  echo "Ramas publicadas en $repo:"
  gh api "repos/$repo/branches" --jq '.[].name' 2>/dev/null | sort | sed 's/^/  /' \
    || { echo "✗ No existe $repo"; exit 1; }
}

# ---------------------------------------------------------------------------
# Este script vive en la máquina del TA, así que PUEDE QUEDARSE VIEJO. Y lo que
# se queda viejo es el guardarraíl: una copia de antes del aviso de "esto
# destapa la solución del módulo anterior" publica sin preguntar y nadie se
# entera. Por eso se compara contra la copia del repositorio antes de actuar.
comprobar_version () {
  local remoto
  remoto=$(gh api "repos/$FUENTE/contents/scripts/publicar-cohorte.sh" --jq '.content' 2>/dev/null | base64 -d 2>/dev/null) || return 0
  [ -n "$remoto" ] || return 0
  # Ambos lados por sustitución de comando, que recorta el salto final igual en
  # los dos: comparar el archivo tal cual contra "$(...)" daba siempre distinto.
  local local_txt; local_txt=$(cat "$0")
  if [ "$(printf '%s' "$remoto" | shasum -a 256)" != "$(printf '%s' "$local_txt" | shasum -a 256)" ]; then
    echo "✗ Tu copia de este script NO coincide con la del repositorio."
    echo "  No sigo: la diferencia puede estar en los avisos que impiden repartir una solución antes de tiempo."
    echo "  Actualízala:"
    echo "    gh api repos/$FUENTE/contents/scripts/publicar-cohorte.sh --jq .content | base64 -d > \"$0\""
    exit 1
  fi
}
comprobar_version

case "${1:-}" in crear|publicar|estado) comprobar_cuenta ;; esac

case "${1:-}" in
  crear)    shift; cmd_crear "$@" ;;
  publicar) shift; cmd_publicar "$@" ;;
  estado)   shift; cmd_estado "$@" ;;
  *) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
