test:
	pixi run mojo test_generic_dict.mojo
	pixi run mojo test_multi_dict.mojo
	pixi run mojo test_sparse_array.mojo
	pixi run mojo test_string_dict.mojo

benchmark:
	pixi run mojo benchmark_generic_dict.mojo
	pixi run mojo benchmark_multi_dict.mojo
	pixi run mojo benchmark_report_string_dict.mojo
	pixi run mojo benchmark_string_dict.mojo

memory:
	pixi run mojo memory_consumption_compact_dict.mojo
	pixi run mojo memory_consumption_std_lib_dict.mojo