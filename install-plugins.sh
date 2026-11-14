#!/bin/sh
# Installs every Moodle plugin ZIP found in the given directory (default: /tmp/plugins).
#
# Naming convention: <type>_<name>[-anything].zip  (type is the Moodle plugin type,
# e.g. local_foo.zip, mod_bar-1.2.3.zip, tool_baz_MOODLE-4.5.zip). The ZIP must
# contain a single top-level folder (the standard layout of zips downloaded from
# the Moodle plugins directory). An existing plugin of the same name is replaced.
set -eu

SRC="${1:-/tmp/plugins}"
WWW="${2:-/var/www/html}"

type_dir() {
    case "$1" in
        mod|theme|local|block|filter|auth|enrol|report|repository|plagiarism|portfolio|webservice|antivirus|calendartype|dataformat|fileconverter)
            echo "$1" ;;
        format)         echo course/format ;;
        availability)   echo availability/condition ;;
        tool)           echo admin/tool ;;
        qtype)          echo question/type ;;
        qbehaviour)     echo question/behaviour ;;
        qformat)        echo question/format ;;
        qbank)          echo question/bank ;;
        editor)         echo lib/editor ;;
        atto)           echo lib/editor/atto/plugins ;;
        tiny)           echo lib/editor/tiny/plugins ;;
        assignsubmission) echo mod/assign/submission ;;
        assignfeedback) echo mod/assign/feedback ;;
        booktool)       echo mod/book/tool ;;
        quiz)           echo mod/quiz/report ;;
        quizaccess)     echo mod/quiz/accessrule ;;
        datafield)      echo mod/data/field ;;
        datapreset)     echo mod/data/preset ;;
        forumreport)    echo mod/forum/report ;;
        gradeexport)    echo grade/export ;;
        gradeimport)    echo grade/import ;;
        gradereport)    echo grade/report ;;
        gradingform)    echo grade/grading/form ;;
        message)        echo message/output ;;
        media)          echo media/player ;;
        search)         echo search/engine ;;
        cachestore)     echo cache/stores ;;
        cachelock)      echo cache/locks ;;
        customfield)    echo customfield/field ;;
        profilefield)   echo user/profile/field ;;
        contenttype)    echo contentbank/contenttype ;;
        logstore)       echo admin/tool/log/store ;;
        paygw)          echo payment/gateway ;;
        h5plugin)       echo h5p/h5plugin ;;
        *)              return 1 ;;
    esac
}

found=0
for zip in "$SRC"/*.[Zz][Ii][Pp]; do
    [ -e "$zip" ] || continue
    found=1
    base=$(basename "$zip")
    stem=${base%.*}
    type=$(echo "${stem%%_*}" | tr '[:upper:]' '[:lower:]')
    rest=${stem#*_}
    name=${rest%%[-.]*}
    # Also stop at a further underscore (e.g. tool_baz_MOODLE-4.5)
    name=${name%%_*}

    if [ "$type" = "$stem" ] || [ -z "$name" ]; then
        echo "ERROR: cannot parse plugin type/name from '$base' (expected <type>_<name>[-version].zip)" >&2
        exit 1
    fi
    if ! rel=$(type_dir "$type"); then
        echo "ERROR: unknown plugin type '$type' in '$base'" >&2
        exit 1
    fi

    tmp=$(mktemp -d)
    unzip -q "$zip" -d "$tmp"
    count=$(find "$tmp" -mindepth 1 -maxdepth 1 | wc -l)
    if [ "$count" -ne 1 ] || [ ! -d "$(find "$tmp" -mindepth 1 -maxdepth 1)" ]; then
        echo "ERROR: '$base' must contain exactly one top-level folder" >&2
        exit 1
    fi

    target="$WWW/$rel/$name"
    echo "Installing ${type}_${name} -> $target"
    rm -rf "$target"
    mkdir -p "$WWW/$rel"
    mv "$(find "$tmp" -mindepth 1 -maxdepth 1)" "$target"
    chown -R www-data:www-data "$target"
    rm -rf "$tmp"
done

[ "$found" -eq 1 ] || echo "No plugin ZIPs found in $SRC"
