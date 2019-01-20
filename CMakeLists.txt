cmake_minimum_required(VERSION 3.6)

project(opus VERSION 1.3.0 LANGUAGES C)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(GNUInstallDirs)
include(CheckIncludeFile)
include(CMakeDependentOption)
include(FeatureSummary)
include(TestVarArrays)

# Options

option(FIXED_POINT "Compile without floating point (for machines without a fast enough FPU)" OFF)

# Configuration

if(CMAKE_SYSTEM_PROCESSOR MATCHES "i?86|x86|X86|amd64|AMD64|x86_64")

  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(OPUS_X86_64 1)
  endif()

  check_include_file(xmmintrin.h HAVE_SSE)
  check_include_file(emmintrin.h HAVE_SSE2)
  check_include_file(smmintrin.h HAVE_SSE4_1)
  check_include_file(immintrin.h HAVE_AVX)

endif()

if(MSVC)
  set(USE_ALLOCA 1)
else()
  test_var_arrays(VAR_ARRAYS)
  if(NOT VAR_ARRAYS)
    check_include_file(alloca.h USE_ALLOCA)
    if(NOT USE_ALLOCA)
      set(NONTHREADSAFE_PSEUDOSTACK 1)
    endif()
  endif()
endif()

# Dependent options

cmake_dependent_option(OPUS_X86_MAY_HAVE_SSE "Use SSE (if avaiable)" ON "HAVE_SSE" OFF)
cmake_dependent_option(OPUS_X86_PRESUME_SSE "Use SSE (hardcoded)" ON "OPUS_X86_MAY_HAVE_SSE;OPUS_X86_64" OFF)
cmake_dependent_option(OPUS_X86_MAY_HAVE_SSE2 "Use SSE2 (if avaiable)" ON "HAVE_SSE2" OFF)
cmake_dependent_option(OPUS_X86_PRESUME_SSE2 "Use SSE2 (hardcoded)" ON "OPUS_X86_MAY_HAVE_SSE2;OPUS_X86_64" OFF)
cmake_dependent_option(OPUS_X86_MAY_HAVE_SSE4_1 "Use SSE4.1 (if avaiable)" ON "HAVE_SSE4_1" OFF)
cmake_dependent_option(OPUS_X86_PRESUME_SSE4_1 "Use SSE4.1 (hardcoded)" OFF "OPUS_X86_MAY_HAVE_SSE4_1" OFF)

if((NOT OPUS_X86_PRESUME_SSE4_1) OR (NOT OPUS_X86_PRESUME_SSE2) OR (NOT OPUS_X86_PRESUME_SSE))
  set(OPUS_HAVE_RTCD 1)
endif()

# Sources

set(CELT_HEAD
  celt/arch.h
  celt/bands.h
  celt/celt.h
  celt/cpu_support.h
  include/opus_types.h
  include/opus_defines.h
  include/opus_custom.h
  celt/cwrs.h
  celt/ecintrin.h
  celt/entcode.h
  celt/entdec.h
  celt/entenc.h
  celt/fixed_debug.h
  celt/fixed_generic.h
  celt/float_cast.h
  celt/_kiss_fft_guts.h
  celt/kiss_fft.h
  celt/laplace.h
  celt/mathops.h
  celt/mdct.h
  celt/mfrngcod.h
  celt/modes.h
  celt/os_support.h
  celt/pitch.h
  celt/celt_lpc.h
  celt/x86/celt_lpc_sse.h
  celt/quant_bands.h
  celt/rate.h
  celt/stack_alloc.h
  celt/vq.h
  celt/static_modes_float.h
  celt/static_modes_fixed.h
  celt/static_modes_float_arm_ne10.h
  celt/static_modes_fixed_arm_ne10.h
  celt/arm/armcpu.h
  celt/arm/fixed_armv4.h
  celt/arm/fixed_armv5e.h
  celt/arm/fixed_arm64.h
  celt/arm/kiss_fft_armv4.h
  celt/arm/kiss_fft_armv5e.h
  celt/arm/pitch_arm.h
  celt/arm/fft_arm.h
  celt/arm/mdct_arm.h
  celt/mips/celt_mipsr1.h
  celt/mips/fixed_generic_mipsr1.h
  celt/mips/kiss_fft_mipsr1.h
  celt/mips/mdct_mipsr1.h
  celt/mips/pitch_mipsr1.h
  celt/mips/vq_mipsr1.h
  celt/x86/pitch_sse.h
  celt/x86/vq_sse.h
  celt/x86/x86cpu.h
)

set(CELT_SOURCES
  celt/bands.c
  celt/celt.c
  celt/celt_encoder.c
  celt/celt_decoder.c
  celt/cwrs.c
  celt/entcode.c
  celt/entdec.c
  celt/entenc.c
  celt/kiss_fft.c
  celt/laplace.c
  celt/mathops.c
  celt/mdct.c
  celt/modes.c
  celt/pitch.c
  celt/celt_lpc.c
  celt/quant_bands.c
  celt/rate.c
  celt/vq.c
)

set(CELT_SOURCES_SSE
  celt/x86/x86cpu.c
  celt/x86/x86_celt_map.c
  celt/x86/pitch_sse.c
)

set(CELT_SOURCES_SSE2
  celt/x86/pitch_sse2.c
  celt/x86/vq_sse2.c
)

set(CELT_SOURCES_SSE4_1
  celt/x86/celt_lpc_sse4_1.c
  celt/x86/pitch_sse4_1.c
)

set(CELT_SOURCES_ARM
  celt/arm/armcpu.c
  celt/arm/arm_celt_map.c
)

set(CELT_SOURCES_ARM_ASM
  celt/arm/celt_pitch_xcorr_arm.s
)

set(CELT_AM_SOURCES_ARM_ASM
  celt/arm/armopts.s.in
)

set(CELT_SOURCES_ARM_NEON_INTR
  celt/arm/celt_neon_intr.c
  celt/arm/pitch_neon_intr.c
)

set(CELT_SOURCES_ARM_NE10
  celt/arm/celt_fft_ne10.c
  celt/arm/celt_mdct_ne10.c
)

set(SILK_HEAD
  silk/debug.h
  silk/control.h
  silk/errors.h
  silk/API.h
  silk/typedef.h
  silk/define.h
  silk/main.h
  silk/x86/main_sse.h
  silk/PLC.h
  silk/structs.h
  silk/tables.h
  silk/tuning_parameters.h
  silk/Inlines.h
  silk/MacroCount.h
  silk/MacroDebug.h
  silk/macros.h
  silk/NSQ.h
  silk/pitch_est_defines.h
  silk/resampler_private.h
  silk/resampler_rom.h
  silk/resampler_structs.h
  silk/SigProc_FIX.h
  silk/x86/SigProc_FIX_sse.h
  silk/arm/biquad_alt_arm.h
  silk/arm/LPC_inv_pred_gain_arm.h
  silk/arm/macros_armv4.h
  silk/arm/macros_armv5e.h
  silk/arm/macros_arm64.h
  silk/arm/SigProc_FIX_armv4.h
  silk/arm/SigProc_FIX_armv5e.h
  silk/arm/NSQ_del_dec_arm.h
  silk/arm/NSQ_neon.h
  silk/fixed/main_FIX.h
  silk/fixed/structs_FIX.h
  silk/fixed/arm/warped_autocorrelation_FIX_arm.h
  silk/fixed/mips/noise_shape_analysis_FIX_mipsr1.h
  silk/fixed/mips/warped_autocorrelation_FIX_mipsr1.h
  silk/float/main_FLP.h
  silk/float/structs_FLP.h
  silk/float/SigProc_FLP.h
  silk/mips/macros_mipsr1.h
  silk/mips/NSQ_del_dec_mipsr1.h
  silk/mips/sigproc_fix_mipsr1.h
)

set(SILK_SOURCES
  silk/CNG.c
  silk/code_signs.c
  silk/init_decoder.c
  silk/decode_core.c
  silk/decode_frame.c
  silk/decode_parameters.c
  silk/decode_indices.c
  silk/decode_pulses.c
  silk/decoder_set_fs.c
  silk/dec_API.c
  silk/enc_API.c
  silk/encode_indices.c
  silk/encode_pulses.c
  silk/gain_quant.c
  silk/interpolate.c
  silk/LP_variable_cutoff.c
  silk/NLSF_decode.c
  silk/NSQ.c
  silk/NSQ_del_dec.c
  silk/PLC.c
  silk/shell_coder.c
  silk/tables_gain.c
  silk/tables_LTP.c
  silk/tables_NLSF_CB_NB_MB.c
  silk/tables_NLSF_CB_WB.c
  silk/tables_other.c
  silk/tables_pitch_lag.c
  silk/tables_pulses_per_block.c
  silk/VAD.c
  silk/control_audio_bandwidth.c
  silk/quant_LTP_gains.c
  silk/VQ_WMat_EC.c
  silk/HP_variable_cutoff.c
  silk/NLSF_encode.c
  silk/NLSF_VQ.c
  silk/NLSF_unpack.c
  silk/NLSF_del_dec_quant.c
  silk/process_NLSFs.c
  silk/stereo_LR_to_MS.c
  silk/stereo_MS_to_LR.c
  silk/check_control_input.c
  silk/control_SNR.c
  silk/init_encoder.c
  silk/control_codec.c
  silk/A2NLSF.c
  silk/ana_filt_bank_1.c
  silk/biquad_alt.c
  silk/bwexpander_32.c
  silk/bwexpander.c
  silk/debug.c
  silk/decode_pitch.c
  silk/inner_prod_aligned.c
  silk/lin2log.c
  silk/log2lin.c
  silk/LPC_analysis_filter.c
  silk/LPC_inv_pred_gain.c
  silk/table_LSF_cos.c
  silk/NLSF2A.c
  silk/NLSF_stabilize.c
  silk/NLSF_VQ_weights_laroia.c
  silk/pitch_est_tables.c
  silk/resampler.c
  silk/resampler_down2_3.c
  silk/resampler_down2.c
  silk/resampler_private_AR2.c
  silk/resampler_private_down_FIR.c
  silk/resampler_private_IIR_FIR.c
  silk/resampler_private_up2_HQ.c
  silk/resampler_rom.c
  silk/sigm_Q15.c
  silk/sort.c
  silk/sum_sqr_shift.c
  silk/stereo_decode_pred.c
  silk/stereo_encode_pred.c
  silk/stereo_find_predictor.c
  silk/stereo_quant_pred.c
  silk/LPC_fit.c
)

set(SILK_SOURCES_SSE4_1
  silk/x86/NSQ_sse4_1.c
  silk/x86/NSQ_del_dec_sse4_1.c
  silk/x86/x86_silk_map.c
  silk/x86/VAD_sse4_1.c
  silk/x86/VQ_WMat_EC_sse4_1.c
)

set(SILK_SOURCES_ARM_NEON_INTR
  silk/arm/arm_silk_map.c
  silk/arm/biquad_alt_neon_intr.c
  silk/arm/LPC_inv_pred_gain_neon_intr.c
  silk/arm/NSQ_del_dec_neon_intr.c
  silk/arm/NSQ_neon.c
)

set(SILK_SOURCES_FIXED
  silk/fixed/LTP_analysis_filter_FIX.c
  silk/fixed/LTP_scale_ctrl_FIX.c
  silk/fixed/corrMatrix_FIX.c
  silk/fixed/encode_frame_FIX.c
  silk/fixed/find_LPC_FIX.c
  silk/fixed/find_LTP_FIX.c
  silk/fixed/find_pitch_lags_FIX.c
  silk/fixed/find_pred_coefs_FIX.c
  silk/fixed/noise_shape_analysis_FIX.c
  silk/fixed/process_gains_FIX.c
  silk/fixed/regularize_correlations_FIX.c
  silk/fixed/residual_energy16_FIX.c
  silk/fixed/residual_energy_FIX.c
  silk/fixed/warped_autocorrelation_FIX.c
  silk/fixed/apply_sine_window_FIX.c
  silk/fixed/autocorr_FIX.c
  silk/fixed/burg_modified_FIX.c
  silk/fixed/k2a_FIX.c
  silk/fixed/k2a_Q16_FIX.c
  silk/fixed/pitch_analysis_core_FIX.c
  silk/fixed/vector_ops_FIX.c
  silk/fixed/schur64_FIX.c
  silk/fixed/schur_FIX.c
)

set(SILK_SOURCES_FIXED_SSE4_1
  silk/fixed/x86/vector_ops_FIX_sse4_1.c
  silk/fixed/x86/burg_modified_FIX_sse4_1.c
)

set(SILK_SOURCES_FIXED_ARM_NEON_INTR
  silk/fixed/arm/warped_autocorrelation_FIX_neon_intr.c
)

set(SILK_SOURCES_FLOAT
  silk/float/apply_sine_window_FLP.c
  silk/float/corrMatrix_FLP.c
  silk/float/encode_frame_FLP.c
  silk/float/find_LPC_FLP.c
  silk/float/find_LTP_FLP.c
  silk/float/find_pitch_lags_FLP.c
  silk/float/find_pred_coefs_FLP.c
  silk/float/LPC_analysis_filter_FLP.c
  silk/float/LTP_analysis_filter_FLP.c
  silk/float/LTP_scale_ctrl_FLP.c
  silk/float/noise_shape_analysis_FLP.c
  silk/float/process_gains_FLP.c
  silk/float/regularize_correlations_FLP.c
  silk/float/residual_energy_FLP.c
  silk/float/warped_autocorrelation_FLP.c
  silk/float/wrappers_FLP.c
  silk/float/autocorrelation_FLP.c
  silk/float/burg_modified_FLP.c
  silk/float/bwexpander_FLP.c
  silk/float/energy_FLP.c
  silk/float/inner_product_FLP.c
  silk/float/k2a_FLP.c
  silk/float/LPC_inv_pred_gain_FLP.c
  silk/float/pitch_analysis_core_FLP.c
  silk/float/scale_copy_vector_FLP.c
  silk/float/scale_vector_FLP.c
  silk/float/schur_FLP.c
  silk/float/sort_FLP.c
)

set(OPUS_HEAD
  include/opus.h
  include/opus_multistream.h
  include/opus_projection.h
  src/opus_private.h
  src/analysis.h
  src/mapping_matrix.h
  src/mlp.h
  src/tansig_table.h
)

set(OPUS_SOURCES
  src/opus.c
  src/opus_decoder.c
  src/opus_encoder.c
  src/opus_multistream.c
  src/opus_multistream_encoder.c
  src/opus_multistream_decoder.c
  src/repacketizer.c
  src/opus_projection_encoder.c
  src/opus_projection_decoder.c
  src/mapping_matrix.c
)

set(OPUS_SOURCES_FLOAT
  src/analysis.c
  src/mlp.c
  src/mlp_data.c
)

if(FIXED_POINT)
  list(APPEND SILK_SOURCES ${SILK_SOURCES_FIXED})
  if(HAVE_SSE4_1)
    list(APPEND SILK_SOURCES ${SILK_SOURCES_SSE4_1} ${SILK_SOURCES_FIXED_SSE4_1})
  endif()
  if(HAVE_ARM_NEON_INTR)
    list(APPEND SILK_SOURCES ${SILK_SOURCES_FIXED_ARM_NEON_INTR})
  endif()
else()
  list(APPEND SILK_SOURCES ${SILK_SOURCES_FLOAT})
  if(HAVE_SSE4_1)
    list(APPEND SILK_SOURCES ${SILK_SOURCES_SSE4_1})
  endif()
endif()

if(DISABLE_FLOAT_API)
else()
  list(APPEND OPUS_SOURCES ${OPUS_SOURCES_FLOAT})
endif()

if(HAVE_SSE)
  list(APPEND CELT_SOURCES ${CELT_SOURCES_SSE})
endif()
if(HAVE_SSE2)
  list(APPEND CELT_SOURCES ${CELT_SOURCES_SSE2})
endif()
if(HAVE_SSE4_1)
  list(APPEND CELT_SOURCES ${CELT_SOURCES_SSE4_1})
endif()

configure_file(cmake/config.h.cmake config.h)

# Features

add_feature_info(MAY_HAVE_SSE OPUS_X86_MAY_HAVE_SSE "Use SSE (if avaiable)")
add_feature_info(PRESUME_SSE OPUS_X86_PRESUME_SSE "Use SSE (hardcoded)")
add_feature_info(MAY_HAVE_SSE2 OPUS_X86_MAY_HAVE_SSE2 "Use SSE2 (if avaiable)")
add_feature_info(PRESUME_SSE2 OPUS_X86_PRESUME_SSE2 "Use SSE2 (hardcoded)")
add_feature_info(MAY_HAVE_SSE4_1 OPUS_X86_MAY_HAVE_SSE4_1 "Use SSE4.1 (if avaiable)")
add_feature_info(PRESUME_SSE4_1 OPUS_X86_PRESUME_SSE4_1 "Use SSE4.1 (hardcoded)")

feature_summary(WHAT ALL)

# Targets

add_library(opus
  ${CMAKE_CURRENT_BINARY_DIR}/config.h
  ${CELT_HEAD} ${CELT_SOURCES}
  ${SILK_HEAD} ${SILK_SOURCES}
  ${OPUS_HEAD} ${OPUS_SOURCES}
)

target_include_directories(opus
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
    celt
    silk
)

if(FIXED_POINT)
  target_include_directories(opus PRIVATE silk/fixed)
else()
  target_include_directories(opus PRIVATE silk/float)
endif()

target_compile_definitions(opus
  PRIVATE
    OPUS_BUILD
    HAVE_CONFIG_H
    $<$<BOOL:${BUILD_SHARED_LIBS}>:DLL_EXPORT>
)

set_target_properties(opus PROPERTIES
  VERSION 0.7.0
  SOVERSION 0
)
