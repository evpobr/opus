macro(TEST_VAR_ARRAYS VARIABLE)
  if(NOT DEFINED ${VARIABLE})
    message(STATUS "Check if C99 variable length arrays (VLA) are supported")
    try_compile(
      ${VARIABLE}
      ${CMAKE_BINARY_DIR}
      ${CMAKE_CURRENT_LIST_DIR}/cmake/TestVarArrays.c
      OUTPUT_VARIABLE OUTPUT
    )
    if(${VARIABLE})
      message(STATUS "Check if C99 variable length arrays (VLA) are supported - Success")
    else()
      message(STATUS "Check if C99 variable length arrays (VLA) are supported - Failed")
    endif()
  endif()
endmacro()