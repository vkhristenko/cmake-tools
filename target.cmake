# deprecated in favor of tcpp_module_name
function(tcpp_target_name _target_var)
    tcpp_rel_path(_path_to_subdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src)
    string(REPLACE "/" "--" _path_to_subdir ${_path_to_subdir})
    set(${_target_var} ${_path_to_subdir} PARENT_SCOPE)
endfunction()

function(tcpp_module_name _module_var)
    tcpp_rel_path(_path_to_subdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src)
    string(REPLACE "/" "--" _path_to_subdir ${_path_to_subdir})
    set(${_module_var} ${_path_to_subdir} PARENT_SCOPE)
endfunction()

function(tcpp_module_name_from_target _module_name_var _target)
    string(REPLACE "--" ";" _target_as_list ${_target})
    list(LENGTH _target_as_list _target_as_list_size)
    list(SUBLIST _target_as_list 0 ${_target_as_list_size} _sublist)
    list(JOIN _target_as_list "--" _merged)
    set(${_module_name_var} ${_merged} PARENT_SCOPE)
endfunction()

function(tcpp_target_form _target_var _module _suffix)
    set(${_target_var} ${_module}--${_suffix} PARENT_SCOPE)
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
    tcpp_module_name(_this_module)
    tcpp_target_form(_target ${_this_module} ${_src_stem})
    
    add_executable(${_target} ${_src})
    target_link_libraries(${_target} PUBLIC ${_deps})
    set_target_properties(${_target} PROPERTIES OUTPUT_NAME ${_src_stem})

    if (DEFINED tcpp_sse_TARGET_VAR AND DEFINED ${tcpp_sse_TARGET_VAR})
        set(${tcpp_sse_TARGET_VAR} ${_target} PARENT_SCOPE)
    endif()
endfunction()

function(tcpp_copy_files)
    cmake_parse_arguments(
        tcpp_copy_files
        ""
        "TARGET"
        "INPUT"
        ${ARGN}
    )
    tcpp_fail_if_undefined(tcpp_copy_files_TARGET)
    tcpp_fail_if_undefined(tcpp_copy_files_INPUT)
    set(_target ${tcpp_copy_files_TARGET})
    set(_input ${tcpp_copy_files_INPUT})

    set(_copy_files_file ${_target}_copy_files)
    file(
        GENERATE
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_copy_files_file}
        CONTENT "\
#!/bin/bash
cp ${_input} ${CMAKE_CURRENT_BINARY_DIR}
"
    FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    )

    foreach(_file ${_input})
        tcpp_rel_path(_file_rel ${_file} ${CMAKE_CURRENT_SOURCE_DIR})
        set(_output_file ${CMAKE_CURRENT_BINARY_DIR}/${_file_rel})
        list(APPEND _output_files ${_output_file})
    endforeach()

    add_custom_command(
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${_copy_files_file}
        OUTPUT ${_output_files}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${_copy_files_file} ${_input}
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "${_target}: copying ${_input} into ${CMAKE_CURRENT_BINARY_DIR}"
    )
    add_custom_target(${_target} DEPENDS ${_output_files})
    set_target_properties(${_target} PROPERTIES OUTPUT ${_output_files})
endfunction()
