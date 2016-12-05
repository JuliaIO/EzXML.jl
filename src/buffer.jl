# Buffer
# ======

# Make a temporary buffer and call `func`.
function make_buffer(func)
    buf_ptr = @check ccall(
        (:xmlBufCreate, libxml2),
        Ptr{Void},
        ()) != C_NULL
    try
        return func(buf_ptr)
    finally
        ccall(
            (:xmlBufFree, libxml2),
            Void,
            (Ptr{Void},),
            buf_ptr)
    end
end
