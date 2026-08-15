#!/usr/bin/env zsh
set -e

cd "${0:A:h:h}" && git pull

blacklist=("${(@f)"$(<./blacklist.txt)"}")
whitelist=("${(@f)"$(<./whitelist.txt)"}")

# hagezi/pro.plus = Blocks most of the annoying internet noise.
# hagezi/doh-vpn-proxy-bypass = Blocks attempts to bypass local DNS resolution.
# hagezi/dyndns = Blocks malicious use of dynamic DNS services.
# hagezi/nosafesearch = Blocks SafeSearch-incompatible search engines.
# hagezi/spam-tlds-rpz = Blocks the most-abused TLDs (RPZ only).

urls=(
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.mini.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/doh-vpn-proxy-bypass.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/dyndns.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/nosafesearch.txt'
)
{
  printf "[AdBlock]\n! Title: AdBlock\n\n||%s^\n" "${blacklist[@]}"
  curl -sL "${urls[@]}" | grep '^||'
} | grep -vFf <(printf '||%s^\n' "${whitelist[@]}") > ./adblock.txt

urls=(
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/rpz/pro.plus.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/rpz/doh-vpn-proxy-bypass.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/rpz/dyndns.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/rpz/nosafesearch.txt'
  'https://raw.githubusercontent.com/hagezi/dns-blocklists/main/rpz/spam-tlds-rpz.txt'
)
{
  printf "\$ORIGIN blocklist.\n\n%s CNAME .\n*.%s CNAME .\n" "${blacklist[@]}" "${blacklist[@]}"
  curl -sL "${urls[@]}" | grep -E '^[*[:alnum:]].*CNAME'
} | grep -vFf <(printf '%s CNAME .\n' "${whitelist[@]}") > ./adblock.rpz

git status
