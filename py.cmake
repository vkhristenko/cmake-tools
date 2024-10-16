function(tcpp_add_python_executable)
    cmake_parse_arguments(
        tcpp_add_python_executable
        ""
        "TARGET;ENTRY_POINT"
        "INPUT"
        ${ARGN}
    )
    tcpp_fail_if_undefined(tcpp_add_python_executable_TARGET)
    tcpp_fail_if_undefined(tcpp_add_python_executable_ENTRY_POINT)
    tcpp_fail_if_undefined(tcpp_add_python_executable_INPUT)
    set(_target ${tcpp_add_python_executable_TARGET})
    set(_entry_point ${tcpp_add_python_executable_ENTRY_POINT})
    set(_input ${tcpp_add_python_executable_INPUT})

    tcpp_target_form(_target_copy_files ${_target} copy_files)
    tcpp_copy_files(
        TARGET ${_target_copy_files}
        INPUT ${_input}
    )

    # generate a script to generate the exe
    set(_forward_args [=[\${@:1}]=])
    file(
        GENERATE
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_target}_gen
        CONTENT "$<TARGET_PROPERTY:IMPORTED_LOCATION> ${CMAKE_CURRENT_BINARY_DIR}/${_entry_point} ${_forward_args}"
        TARGET python3
        FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE
    )

    add_custom_command(
        COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/${_target}_gen  ${CMAKE_CURRENT_BINARY_DIR}/${_target}
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${_target}
        DEPENDS ${_target_copy_files} $<TARGET_PROPERTY:${_target_copy_files},OUTPUT>
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "${_target}: generating python executable target ${_target}"
    )
    add_custom_target(${_target} DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${_target})
    set_target_properties(${_target} PROPERTIES LOCATION ${CMAKE_CURRENT_BINARY_DIR}/${_target})
endfunction()
