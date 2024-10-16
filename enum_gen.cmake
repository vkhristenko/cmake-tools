function(tcpp_enum_gen)
    cmake_parse_arguments(
        tcpp_enum_gen
        ""
        "TARGET"
        "INPUT"
        ${ARGN}
    )

    tcpp_fail_if_undefined(tcpp_enum_gen_INPUT)
    tcpp_fail_if_undefined(tcpp_enum_gen_TARGET)
    set(_input ${tcpp_enum_gen_INPUT})
    set(_target ${tcpp_enum_gen_TARGET})

    tcpp_module_name_from_target(_this_module ${_target})
    tcpp_target_form(_target_copy_files ${_this_module} copy_files)
    tcpp_copy_files(
        TARGET ${_target_copy_files}
        INPUT ${_input}
    )

    set(_output_abs ${CMAKE_CURRENT_BINARY_DIR}/enum_gen.h)
    add_custom_command(
        OUTPUT ${_output_abs}
        COMMAND 
            $<TARGET_PROPERTY:enum_gen,LOCATION> --input $<TARGET_PROPERTY:${_target_copy_files},OUTPUT> --output ${_output_abs}
        DEPENDS
            ${_target_copy_files} $<TARGET_PROPERTY:${_target_copy_files},OUTPUT>
            enum_gen $<TARGET_PROPERTY:enum_gen,LOCATION>
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "${_target}: Running enum_gen to generate enum aux methods for ${_input}"
    )
    add_custom_target(${_target} DEPENDS ${_output_abs})
    set_target_properties(${_target} PROPERTIES OUTPUT ${_output_abs})
endfunction()
