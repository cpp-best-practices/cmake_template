add_subdirectory(sample_library)
if(NOT CMAKE_UNITY_BUILD)
  add_subdirectory(ftxui_sample)
endif()
