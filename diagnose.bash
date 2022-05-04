# Runs a bunch of helpful diagnostics on a runner.
# https://docs.github.com/en/actions/using-workflows/workflow-commands-for-github-actions
set-output(){   echo "::set-output name=${1}::${2}"; }
workflow-log(){ echo "::${2:-info} file=.github/workflows/${GITHUB_WORKFLOW}.yml,line=1::$1"; }
grouped(){   echo "::group::${1}"; shift 1; eval "${@}"; echo "::endgroup::"; }

set -eu; echo "::echo::off"; # <-- this line divides the helpers (above) from the main script.
cat <<-'__BANNER__'
         (__) 
         (oo) 
   /------\/ 
  / |    ||   
 *  /\---/\ 
    ~~   ~~   
...."Have you mooed today?"...
__BANNER__

set-output "cpu"      $(uname -m)
set-output "hostname" $(hostname)

grouped "Environment Vars" "env | sort | grep -Ev ^PATH"
grouped "Executable Search Path" "echo \$PATH | tr ':' '\n'"
grouped "Executables in Runner's \$PATH" "echo $PATH | tr ':' '\n' | xargs -n1 ls -1 2>/dev/null | sort -u | xargs -n5 echo | column -t"
grouped "Contents of \$GITHUB_EVENT_PATH" "jq -CSer '.' $GITHUB_EVENT_PATH"
grouped "\$RUNNER_TOOL_CACHE" "ls -oAh $RUNNER_TOOL_CACHE"
