set(_var "something")

function(_assign)
    # with PARENT_SCOPE will set the global variable _var
    set(_var "something else")
endfunction()

_assign()
message(STATUS "_var = ${_var}")
