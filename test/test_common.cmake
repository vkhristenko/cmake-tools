include(../common.cmake)

tcpp_abs_path(_abs_path "../common.cmake")
tcpp_debug_var(_abs_path)

tcpp_rel_path(_rel_path "common.cmake" ${CMAKE_SOURCE_DIR})
tcpp_debug_var(_rel_path)
