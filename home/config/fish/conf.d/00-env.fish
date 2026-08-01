# Environment variables — set for every shell (zshenv equivalent).
#
# zshenv sets these for zsh; fish may be launched directly (not via a zsh
# login shell), so set them here too. `-q` keeps any value already exported.
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache

set -gx LANGUAGE en_US:en
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx PLATFORM (uname)

# PostgreSQL: hit \e on psql to edit the query in $EDITOR
set -gx PSQL_EDITOR 'nvim +"setfiletype sql" '

# Editor (neovim is Nix-provided, so it is already on PATH via /etc/fish)
if type -q nvim
    set -gx EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
end

# CA bundle for the Nix-provided TLS stack.
#
# nixpkgs' OpenSSL carries no CA bundle: it verifies against NIX_SSL_CERT_FILE,
# falling back to /etc/ssl/certs/ca-certificates.crt. Distributions that keep
# the bundle elsewhere (Fedora: /etc/pki) leave nix-provided git/curl with no
# trust anchors at all, and a single-user Nix install only exports the variable
# from the profile scripts bash reads — fish never sees it. Point it at the
# first bundle that exists on this host.
if not set -q NIX_SSL_CERT_FILE
    for ca_bundle in \
        /etc/ssl/certs/ca-certificates.crt \
        /etc/pki/tls/certs/ca-bundle.crt \
        /etc/ssl/ca-bundle.pem \
        /etc/ssl/cert.pem
        if test -e $ca_bundle
            set -gx NIX_SSL_CERT_FILE $ca_bundle
            set -q SSL_CERT_FILE; or set -gx SSL_CERT_FILE $ca_bundle
            break
        end
    end
    set -e ca_bundle
end

# GPG (over SSH use the curses pinentry)
if set -q SSH_CONNECTION
    set -gx GPG_TTY (tty)
    set -gx PINENTRY_USER_DATA USE_CURSES=1
end
