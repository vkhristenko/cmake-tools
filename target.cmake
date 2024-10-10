function(tcpp_target_name _target_var)
    tcpp_rel_path(_path_to_subdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src)
    string(REPLACE "/" "--" _path_to_subdir ${_path_to_subdir})
    set(${_target_var} ${_path_to_subdir} PARENT_SCOPE)
endfunction()

function(tcpp_target_form _target_var _prefix _suffix)
    set(${_target_var} ${_prefix}--${_suffix} PARENT_SCOPE)
endfunction()

function(tcpp_auto_addsubdirs _dir_rel)
    if (EXISTS ${_dir_rel}/CMakeLists.txt)
        message(STATUS ${_dir_rel}/CMakeLists.txt)
        add_subdirectory(${_dir_rel})
    else()
        file(GLOB directories LIST_DIRECTORIES true ${_dir_rel}/*)
        message(STATUS ${directories})

        foreach(dir ${directories})
            if(IS_DIRECTORY ${dir})
                tcpp_auto_addsubdirs(${dir})
            endif()
        endforeach()
    endif()
endfunction()

# single source executable
function(tcpp_sse)
    cmake_parse_arguments(
        tcpp_sse
        ""
        "SRC;TARGET_VAR"
        "DEPS"
        ${ARGN}
    )
    tcpp_fail_if_undefined(tcpp_sse_SRC)
    set(_src ${tcpp_sse_SRC})
    tcpp_set(_deps tcpp_sse_DEPS "")
    cmake_path(GET _src FILENAME _src_filename)
    cmake_path(GET _src_filename STEM _src_stem)
    tcpp_target_name(_target_prefix)
    tcpp_target_form(_target ${_target_prefix} ${_src_stem})
    
    add_executable(${_target} ${_src})
    target_link_libraries(${_target} PUBLIC ${_deps})
    set_target_properties(${_target} PROPERTIES OUTPUT_NAME ${_src_stem})

    if (DEFINED tcpp_sse_TARGET_VAR AND DEFINED ${tcpp_sse_TARGET_VAR})
        set(${tcpp_sse_TARGET_VAR} ${_target} PARENT_SCOPE)
    endif()
endfunction()
