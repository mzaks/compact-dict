@always_inline
fn eq(a: StringRef, b: String) -> Bool:
    let l = len(a)
    if l != len(b):
        return False
    let p1 = a.data
    let p2 = b._as_ptr()
    var offset = 0
    alias step = 16
    while l - offset >= step:
        if p1.simd_load[step](offset) != p2.simd_load[step](offset):
            return False
        offset += step
    while l - offset > 0:
        if p1.load(offset) != p2.load(offset):
            return False
        offset += 1
    return True
