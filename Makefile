PWD=$(shell pwd)

all: package

convert:
	wat2wasm resources/debug.wat -o resources/debug.wasm
	wat2wasm resources/debug.wat -v > resources/debug.text
	tools/bin2coe.py --input resources/debug.wasm --output resources/debug.coe

prepare:
	@mkdir -p work

project: prepare hxs
	@vivado -mode batch -source scripts/create_project.tcl -notrace -nojournal -tempDir work -log work/vivado.log

package:
	python3 setup.py sdist bdist_wheel

clean:
	@find ip ! -iname *.xci -type f -exec rm {} +
	@rm -rf .Xil vivado*.log vivado*.str vivado*.jou
	@rm -rf work \
		src-gen \
		hxs_gen \
	 	*.egg-info \
		 docs/_build \
		 dist \
		 build \
	@rm -rf ip/**/hdl \
		ip/**/synth \
		ip/**/example_design \
		ip/**/sim \
		ip/**/simulation \
		ip/**/misc \
		ip/**/doc

hxs:
	docker run -t \
               -v ${PWD}/hxs:/work/src \
               -v ${PWD}/hxs_gen:/work/gen \
               registry.build.aug:5000/docker/hxs_generator:latest
	cp hxs_gen/vhd_gen/header/wasm_fpga_uart_header.vhd resources/wasm_fpga_uart_header.vhd
	cp hxs_gen/vhd_gen/wishbone/wasm_fpga_uart_wishbone.vhd resources/wasm_fpga_uart_wishbone.vhd
	cp hxs_gen/vhd_gen/testbench/direct/wasm_fpga_uart_direct.vhd resources/wasm_fpga_uart_direct.vhd
	cp hxs_gen/vhd_gen/testbench/indirect/wasm_fpga_uart_indirect.vhd resources/wasm_fpga_uart_indirect.vhd
	cp hxs_gen/simstm_gen/indirect/wasm_fpga_uart_indirect.stm resources/wasm_fpga_uart_indirect.stm

install-from-test-pypi:
	pip3 install --upgrade -i https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple wasm-fpga-uart

upload-to-test-pypi: package
	python3 -m twine upload --repository-url https://test.pypi.org/legacy/ dist/*

upload-to-pypi: package
	python3 -m twine upload --repository pypi dist/*

docs:
	(cd docs && make html)

.PHONY: all prepare project package clean hxs docs
