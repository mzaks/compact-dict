# syntax is correct but can be unrecognized by your IDE
# check issue: https://github.com/modular/modular/issues/5115
# or line `fn call_it[f: fn() capturing [_] -> None]()` in https://docs.modular.com/mojo/changelog/
fn progress_bar[callback: fn(Int) raises capturing [_] -> None](n:Int, prefix:String='', bar_size:Int=60) raises:
    var n_size = len(String(n))
    var space = " " if len(prefix)>0 else ""

    @parameter
    fn show(step:Int):
        var bar:String=space
        for j in range(bar_size):
            if j < Int((step * bar_size) / n):
                bar += "█"
            else:
                bar += "░"

        for _ in range(n_size-len(String(step))):
            bar += " "

        print("\r" + String(prefix) + String(bar) + " " + String(step) + "/" + String(n) + " ",end="")

    show(0)
    for step in range(n):
        callback(step)
        show(step+1)