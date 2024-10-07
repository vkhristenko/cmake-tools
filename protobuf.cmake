function(tcpp_protobuf_generate_one)
    cmake_parse_arguments(
        tcpp_protobuf_generate_one
        ""
        "OUTPUT_DIR;PROTO"
        "IMPORT_PATHS;SRCS_VAR;HDRS_VAR"
        ${ARGN}
    )
    tcpp_fail_if_undefined(tcpp_protobuf_generate_one_PROTO)
    tcpp_fail_if_undefined(tcpp_protobuf_generate_one_SRCS_VAR)
    tcpp_fail_if_undefined(tcpp_protobuf_generate_one_HDRS_VAR)
    set(_proto ${tcpp_protobuf_generate_one_PROTO})
    set(_srcs_var ${tcpp_protobuf_generate_one_SRCS_VAR})
    set(_hdrs_var ${tcpp_protobuf_generate_one_HDRS_VAR})
    tcpp_set(_output_dir tcpp_protobuf_generate_one_OUTPUT_DIR ${CMAKE_BINARY_DIR}/src)
    tcpp_set(_import_paths tcpp_protobuf_generate_one_IMPORT_PATHS "")
    list(PREPEND _import_paths ${CMAKE_SOURCE_DIR}/src)

    # TODO
    # 1) can we use DEPFILE to get the generated files?
    # 2) can we use variables provided by calling find_package(Protobuf) ?

    tcpp_abs_path(_proto_abs ${_proto})
    tcpp_abs_path(_output_dir_abs ${_output_dir})
    set(_import_paths_abs)
    foreach(_path ${_import_paths})
        tcpp_abs_path(_path_abs ${_path})
        list(APPEND _import_paths_abs "-I${_path_abs}")
    endforeach()
    
    # NOTE must exist!
    list(GET _import_paths 0 _base_import_path)
    cmake_path(GET _proto_abs PARENT_PATH _proto_parent_path_abs)
    tcpp_rel_path(_out_dir_rel ${_proto_parent_path_abs} ${_base_import_path})

    cmake_path(GET _proto FILENAME _proto_filename)
    cmake_path(GET _proto_filename STEM _proto_stem)
    
    tcpp_debug_var(_out_dir_rel)
    tcpp_debug_var(_output_dir)
    tcpp_debug_var(_proto_stem)

    add_custom_command(
        OUTPUT
            ${_output_dir}/${_out_dir_rel}/${_proto_stem}.pb.h
            ${_output_dir}/${_out_dir_rel}/${_proto_stem}.pb.cc
            ${_output_dir}/${_out_dir_rel}/${_proto_stem}.grpc.pb.h
            ${_output_dir}/${_out_dir_rel}/${_proto_stem}.grpc.pb.cc
        COMMAND
            $<TARGET_FILE:protobuf::protoc> 
        ARGS
            ${_import_paths_abs} 
            --cpp_out=${_output_dir}
            --grpc_out=${_output_dir}
            --plugin=protoc-gen-grpc=$<TARGET_FILE:gRPC::grpc_cpp_plugin>
            ${_proto_abs}
        DEPENDS ${_protos}
        COMMAND_EXPAND_LISTS
        COMMENT "Generating sources and headers for ${_protos}"
        VERBATIM
    )

    set(${_srcs_var} 
        ${_output_dir}/${_out_dir_rel}/${_proto_stem}.pb.cc
        ${_output_dir}/${_out_dir_rel}/${_proto_stem}.grpc.pb.cc
        PARENT_SCOPE
    )
    set(${_hdrs_var}
        ${_output_dir}/${_out_dir_rel}/${_proto_stem}.pb.h
        ${_output_dir}/${_out_dir_rel}/${_proto_stem}.grpc.pb.h
        PARENT_SCOPE
    )
endfunction()

function(tcpp_protobuf_generate)
    cmake_parse_arguments(
        tcpp_protobuf_generate
        ""
        "OUTPUT_DIR"
        "PROTOS;IMPORT_PATHS;SRCS_VAR;HDRS_VAR"
        ${ARGN}
    )
    tcpp_fail_if_undefined(tcpp_protobuf_generate_PROTOS)
    tcpp_fail_if_undefined(tcpp_protobuf_generate_SRCS_VAR)
    tcpp_fail_if_undefined(tcpp_protobuf_generate_HDRS_VAR)
    set(_protos ${tcpp_protobuf_generate_PROTOS})
    set(_srcs_var ${tcpp_protobuf_generate_SRCS_VAR})
    set(_hdrs_var ${tcpp_protobuf_generate_HDRS_VAR})
    tcpp_set(_output_dir tcpp_protobuf_generate_OUTPUT_DIR "")
    tcpp_set(_import_paths tcpp_protobuf_generate_IMPORT_PATHS "")

    set(_srcs)
    set(_hdrs)
    foreach(_proto ${_protos})
        tcpp_protobuf_generate_one(
            PROTO ${_proto}
            SRCS_VAR _srcs_one_proto
            HDRS_VAR _hdrs_one_proto
            OUTPUT_DIR ${_output_dir}
            IMPORT_PATHS ${_import_paths}
        ) 

        list(APPEND _srcs ${_srcs_one_proto})
        list(APPEND _hdrs ${_hdrs_one_proto})
    endforeach()

    set(${_srcs_var} ${_srcs} PARENT_SCOPE)
    set(${_hdrs_var} ${_hdrs} PARENT_SCOPE)
endfunction()
