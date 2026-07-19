# Insert a kubernetes pod name selected with fzf (Ctrl-x Ctrl-p).
function _fzf_k8s_pods
    if not type -q kubectl
        echo 'A "kubectl" command is not found.'
        return 1
    end
    set -l pod (kubectl get pods | fzf \
        --height 100% \
        --header-lines 1 \
        --preview 'kubectl describe pods/{1}' \
        | perl -lanE 'say $F[0]')
    test -n "$pod"; and commandline -i -- "$pod"
    commandline -f repaint
end
