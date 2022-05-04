# Runs a bunch of helpful diagnostics on a runner.
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions
set-output(){   echo "::set-output name=${1}::${2}"; }
workflow-log(){ echo "::${2:-info} file=.github/workflows/${GITHUB_WORKFLOW}.yml,line=1::$1"; }
grouped(){   echo "::group:: ☑ ${1}"; shift 1; eval "${@}"; echo "::endgroup::"; }

dump_colors(){
    for i in {0..255} ; do
        printf "\x1b[38;5;${i}m%3d " "${i}"
        if (( $i == 15 )) || (( $i > 15 )) && (( ($i-15) % 12 == 0 )); then
            echo;
        fi
    done
}

set -eu; echo "::echo::off"; # <-- this line divides the helpers (above) from the main script.
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

set-output "cpu"      $(uname -m)
set-output "hostname" $(hostname)

grouped "Environment Vars" "env | sort | grep -Ev ^PATH"
grouped "$(dirname $GITHUB_ENV) (dir contents)" "ls -lAh \$(dirname $GITHUB_ENV)"
grouped "\$GITHUB_EVENT_PATH (file contents)" "jq -CSer '.' $GITHUB_EVENT_PATH"
grouped "\$GITHUB_STEP_SUMMARY (file contents)" "jq -CSer '.' $GITHUB_STEP_SUMMARY"
grouped "Runner's CPU Information" "lscpu"
grouped "Runner's PCI Information" "lspci"
grouped "Runner's Block devices" "lsblk"
grouped "Runner's Docker info" "docker system info"
grouped "Runner's Podman info" "podman system info"
grouped "Runner's Current Memory Usage" "free -mh"
grouped "Runner hardware information" "lshw"
grouped "\$PATH (where the binaries are)" "echo \$PATH | tr ':' '\n' | nl -w2 -s'. '"
grouped "Available binaries" "echo $PATH | tr ':' '\n' | xargs -n1 ls -1 2>/dev/null | sort -u | tr '\n' ';' | sed -e 's/\;/  /g'"
grouped "XTerm Colors" "dump_colors"

echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-" && exit 0