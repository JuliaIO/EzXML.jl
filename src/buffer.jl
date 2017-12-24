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
        if VERSION > v"0.7-"
            finalizer(finalize_buffer, buf)
        else
            finalizer(buf, finalize_buffer)
        end
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
