# Buffer
# ======

struct _Buffer
    content::Cstring
    use::Cuint
    size::Cuint
    alloc::Ptr{Cvoid}
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
        finalizer(finalize_buffer, buf)
        return buf
    end
end

function finalize_buffer(buf)
    ccall(
        (:xmlBufferFree, libxml2),
        Cvoid,
        (Ptr{Cvoid},),
        buf.ptr)
end
