function(add_python_executable)
    cmake_parse_arguments(
        add_python_executable
        ""
        "TARGET;ENTRY_POINT"
        "INPUT"
        ${ARGN}
    )
    tcpp_fail_if_undefined(add_python_executable_TARGET)
    tcpp_fail_if_undefined(add_python_executable_ENTRY_POINT)
    tcpp_fail_if_undefined(add_python_executable_INPUT)
    set(_target ${add_python_executable_TARGET})
    set(_entry_point ${add_python_executable_ENTRY_POINT})
    set(_input ${add_python_executable_INPUT})

    # generate a script to copy py files
    set(_copy_files_file copy_files_file)
    file(
        GENERATE
        OUTPUT ${_copy_files_file}
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
   
    # a target to run the above script
    tcpp_debug_var(_output_files)
    add_custom_command(
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${_copy_files_file}
        OUTPUT ${_output_files} 
        DEPENDS ${_input}
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "copying files ${_input} into ${CMAKE_CURRENT_BINARY_DIR}"
    )
    add_custom_target(${_target}_copy_files DEPENDS ${_output_files})

    # generate a script to generate the exe
    set(_forward_args [=[\${@:1}]=])
    set(_gen_exe_file gen_exe_file)
    file(
        GENERATE
        OUTPUT ${_gen_exe_file}
        CONTENT "\
#!/bin/bash
cat > ${CMAKE_CURRENT_BINARY_DIR}/${_target} <<- EOM
$<TARGET_PROPERTY:IMPORTED_LOCATION> ${CMAKE_CURRENT_BINARY_DIR}/${_entry_point} ${_forward_args}
EOM
chmod +x ${CMAKE_CURRENT_BINARY_DIR}/${_target}
"
        TARGET python3
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    )

    # genreate the exe and set the properties
    add_custom_command(
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/${_gen_exe_file}
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_target}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${_gen_exe_file} ${_target}_copy_files ${_output_files}
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "generating executable ${CMAKE_CURRENT_BINARY_DIR}/${_target}"
    )
    add_custom_target(${_target} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${_target})
    set_target_properties(${_target} PROPERTIES EXECUTABLE_FILE_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${_target})

endfunction()
