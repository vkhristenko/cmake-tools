function(tcpp_target_name _target_var _target_id)
    tcpp_module_name(_this_module)
    tcpp_debug_var(_this_module)
    tcpp_module_id_from_name(_module_id ${_this_module})
    tcpp_debug_var(_module_id)
    tcpp_target_form(_target ${_this_module} ${_module_id})
    tcpp_debug_var(_target)
    if (DEFINED _target_id)
        tcpp_target_form(_target ${_this_module} ${_target_id})
    endif()
    tcpp_debug_var(_target)
    set(${_target_var} ${_target} PARENT_SCOPE)
endfunction()

function(tcpp_module_name _module_var)
    tcpp_rel_path(_path_to_subdir ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_SOURCE_DIR}/src)
    string(REPLACE "/" "--" _path_to_subdir ${_path_to_subdir})
    set(${_module_var} ${_path_to_subdir} PARENT_SCOPE)
endfunction()

# name vs id must be reversed
# id = some_name
# name = full--path--to--module--some_name
function(tcpp_module_id_from_name _module_id_var _module_name)
    string(REPLACE "--" ";" _module_name ${_module_name})
    list(LENGTH _module_name _length)
    math(EXPR _last_item_index "${_length} - 1")
    list(GET _module_name ${_last_item_index} _last_item)
    set(${_module_id_var} ${_last_item} PARENT_SCOPE)
endfunction()

function(tcpp_module_name_from_path _module_var _path)
    tcpp_rel_path(_path_to_subdir ${_path} ${CMAKE_SOURCE_DIR}/src)
    string(REPLACE "/" "--" _path_to_subdir ${_path_to_subdir})
    set(${_module_var} ${_path_to_subdir} PARENT_SCOPE)
endfunction()

function(tcpp_module_name_from_target _module_name_var _target)
    string(REPLACE "++" "--" _target_as_list_pre ${_target})
    string(REPLACE "--" ";" _target_as_list ${_target_as_list_pre})
    list(LENGTH _target_as_list _target_as_list_size)
    math(EXPR _size "${_target_as_list_size} - 1")
    list(SUBLIST _target_as_list 0 ${_size} _sublist)
    list(JOIN _sublist "--" _merged)
    set(${_module_name_var} ${_merged} PARENT_SCOPE)
endfunction()

function(tcpp_target_form _target_var _module _suffix)
    set(${_target_var} ${_module}++${_suffix} PARENT_SCOPE)
endfunction()

function(tcpp_dummy _target)
    add_custom_command(
        COMMAND touch ${CMAKE_CURRENT_BINARY_DIR}/${_target}_package
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_target}_package
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "Generating dummy target=${_target}"
    )
    tcpp_debug_var(_target)
    add_custom_target(${_target} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${_target}_package)
endfunction()

function(tcpp_auto_addsubdirs _dir)
    if (EXISTS ${_dir}/CMakeLists.txt)
        message(STATUS ${_dir}/CMakeLists.txt)
        add_subdirectory(${_dir})
        
        get_property(_dir_targets DIRECTORY ${_dir} PROPERTY BUILDSYSTEM_TARGETS)
        tcpp_debug_var(_dir_targets)
        
        tcpp_module_name_from_path(_module ${_dir})
        tcpp_dummy(${_module})
        add_dependencies(${_module} ${_dir_targets})
    else()
        file(GLOB directories LIST_DIRECTORIES true ${_dir}/*)
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
