from .keys_container import KeyRef

@always_inline
fn eq(a: KeyRef, b: KeyRef) -> Bool:
    var l = a.size
    if l != b.size:
        return False
    var p1 = a.pointer
    var p2 = b.pointer
    var offset = 0
    alias step = 16
    while l - offset >= step:
        var unequal = p1.load[width=step](offset) != p2.load[width=step](offset)
        if unequal.reduce_or():
            return False
        offset += step
    while l - offset > 0:
        if p1.load(offset) != p2.load(offset):
            return False
        offset += 1
    return True
