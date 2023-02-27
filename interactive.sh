##
#  shlib/interactive
# ------------------- -
#  author: Satoshi Soma (https://amekusa.com)
# ============================================ *
#
#  MIT License
#
#  Copyright (c) 2022 Satoshi Soma
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
##


reload() {
	echo "Reloading the login shell ($SHELL)..."
	exec "$SHELL" --login
}

# mkdir & cd
mkcd() {
	if [ -z "$1" ]; then
		echo "Usage:"
		echo "  $0 <new-dir>"
		return 1
	fi
	if [ -d "$1" ]; then
		echo "dir '$1' already exists"
		cd -- "$1"
		return
	fi
	mkdir -p -- "$1" &&
	cd -- "$1"
}

# find
f() {
	if [ -z "$1" ]; then
		echo "Usage:"
		echo "  $0 <query> [basedir] [maxdepth]"
		return 1
	fi
	local dir='.'; [ -z "$2" ] || dir="$2"
	local depth=2; [ -z "$3" ] || depth="$3"
	find "$dir" -maxdepth "$depth" -iname "*${1}*"
}

# find & cd
fcd() {
	if [ -z "$1" ]; then
		echo "Usage:"
		echo "  $0 <query> [basedir] [maxdepth]"
		return 1
	fi
	local dir='.'; [ -z "$2" ] || dir="$2"
	local depth=2; [ -z "$3" ] || depth="$3"
	local dest=$(find "$dir" -maxdepth "$depth" -type d -iname "*${1}*" -print -quit)
	if [ -z $dest ]; then
		echo "'${1}' is not found"
		return 1
	fi
	cd "$dest"
}

# site health checker
http() {
	if [ -z "$1" ]; then
		echo "Usage:"
		echo "  $0 <location>"
		echo "  $0 <location> -s (for HTTPS)"
		return 1
	fi
	local protocol=http
	[ "$2" = "-s" ] && protocol=https
	local ua="Site Health Check"
	local r=$(curl -Is -A "$ua" -o /dev/null -w '%{http_code} (%{time_total}s)\n' "$protocol://$1")
	echo "$r"
	local s="${r:0:3}"
	[ "$s" -ge 200 ] && [ "$s" -lt 400 ]
}

# site health checker (HTTPS)
https() {
	if [ -z "$1" ]; then
		echo "Usage:"
		echo "  $0 <location>"
		return 1
	fi
	http "$1" -s
}
