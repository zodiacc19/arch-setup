function fish_title
    if test (count $argv) -gt 0
        echo $argv
    else
        echo "~ fish — "(pwd)
    end
end
