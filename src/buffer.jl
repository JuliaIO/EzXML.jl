# Buffer
# ======

struct _Buffer
    content::Cstring
    use::Cuint
    size::Cuint
    alloc::Ptr{Void}
    contentIO::Cstring
end

mutable struct Buffer
    ptr::Ptr{_Buffer}

    function Buffer()
        buf_ptr = ccall(
            (:xmlBufferCreate, libxml2),
            Ptr{_Buffer},
            ())
        buf = new(buf_ptr)
        finalizer(buf, finalize_buffer)
        return buf
    end
end

function finalize_buffer(buf)
    ccall(
        (:xmlBufferFree, libxml2),
        Void,
        (Ptr{Void},),
        buf.ptr)
end
