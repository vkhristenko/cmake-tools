function(tcpp_print msg)
    message(STATUS "${msg}")
endfunction()

function(tcpp_debug_var var) 
    tcpp_print("${var} = ${${var}}")
endfunction()

function(tcpp_fail_here)
    message(FATAL_ERROR "Stop execution!")
endfunction()

function(tcpp_fail_with_error msg)
    message(FATAL_ERROR ${msg})
endfunction()

function(tcpp_fail_if_undefined var)
    if (NOT DEFINED ${var})
        tcpp_fail_with_error("variable ${var} is not defined")
    endif()
endfunction()

function(tcpp_abs_path _abs_path_var _path)
    cmake_path(ABSOLUTE_PATH _path OUTPUT_VARIABLE _abs_path)
    set(${_abs_path_var} ${_abs_path} PARENT_SCOPE)
endfunction()

function(tcpp_rel_path _rel_path_var _path _wrt)
    tcpp_abs_path(_path_abs ${_path})
    tcpp_abs_path(_wrt_abs ${_wrt})

    cmake_path(
        RELATIVE_PATH _path_abs
        OUTPUT_VARIABLE _rel_path 
        BASE_DIRECTORY ${_wrt_abs})
    set(${_rel_path_var} ${_rel_path} PARENT_SCOPE)
endfunction()

function(tcpp_set _dest_var _src_var _default)
    if (DEFINED ${_src_var})
        set(${_dest_var} ${${_src_var}} PARENT_SCOPE)
    else()
        set(${_dest_var} ${_default} PARENT_SCOPE)
    endif()
endfunction()
