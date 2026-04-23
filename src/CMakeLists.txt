foreach(d ${MY_PROJECT_SUBDIRECTORIES})
   MESSAGE(STATUS "Adding subdirectory: ${d}")
   add_subdirectory(${d})
endforeach()
