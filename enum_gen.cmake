function(tcpp_enum_gen)
    cmake_parse_arguments(
        tcpp_enum_gen
        ""
        "OUTPUT"
        "INPUT"
        ${ARGN}
    )

    tcpp_fail_if_undefined(tcpp_enum_gen_INPUT)
    tcpp_fail_if_undefined(tcpp_enum_gen_OUTPUT)
    set(_input ${tcpp_enum_gen_INPUT})
    set(_output ${tcpp_enum_gen_OUTPUT})

    tcpp_abs_path(_input_abs ${_input})
    tcpp_abs_path(_output_abs ${_output})

    add_custom_command(
        OUTPUT ${_output_abs}
        COMMAND $<TARGET_PROPERTY:enum_gen,EXECUTABLE_FILE_LOCATION> --input ${_input} --output ${_output}
        DEPENDS ${_input} enum_gen $<TARGET_PROPERTY:enum_gen,EXECUTABLE_FILE_LOCATION>
        COMMAND_EXPAND_LISTS
        VERBATIM
        COMMENT "enum_gen: Generating enums for ${_input}"
    )
    
endfunction()
