import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

__tag__ = ""
__build__ = 0
__version__ = "{}".format(__tag__)
__commit__ = "0000000"

setuptools.setup(
    name="wasm-fpga-uart",
    version=__version__,
    author="Denis Vasilìk",
    author_email="contact@denisvasilik.com",
    url="https://github.com/denisvasilik/wasm-fpga-uart/",
    project_urls={
        "Bug Tracker": "https://github.com/denisvasilik/wasm-fpga/",
        "Documentation": "https://wasm-fpga.readthedocs.io/en/latest/",
        "Source Code": "https://github.com/denisvasilik/wasm-fpga-uart/",
    },
    description="WebAssembly FPGA Uart",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=setuptools.find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3.6",
        "Operating System :: OS Independent",
    ],
    dependency_links=[],
    package_dir={},
    package_data={},
    data_files=[
        ("wasm-fpga-uart/package", ["package/component.xml"]),
        ("wasm-fpga-uart/package/bd", ["package/bd/bd.tcl"]),
        ("wasm-fpga-uart/package/xgui", ["package/xgui/wasm_fpga_uart_v1_0.tcl"]),
        (
            "wasm-fpga-uart/resources",
            [
                "resources/wasm_fpga_uart_header.vhd",
                "resources/wasm_fpga_uart_direct.vhd",
                "resources/wasm_fpga_uart_indirect.vhd",
                "resources/wasm_fpga_uart_wishbone.vhd",
            ],
        ),
        (
            "wasm-fpga-uart/ip/WasmFpgaTestBenchRam",
            ["ip/WasmFpgaTestBenchRam/WasmFpgaTestBenchRam.xci"],
        ),
        ("wasm-fpga-uart/src", ["src/WasmFpgaUart.vhd"]),
        (
            "wasm-fpga-uart/tb",
            [
                "tb/tb_FileIo.vhd",
                "tb/tb_pkg_helper.vhd",
                "tb/tb_pkg.vhd",
                "tb/tb_std_logic_1164_additions.vhd",
                "tb/tb_Types.vhd",
                "tb/tb_WasmFpgaUart.vhd",
                "tb/tb_WbRam.vhd",
            ],
        ),
        ("wasm-fpga-uart", ["CHANGELOG.md", "AUTHORS", "LICENSE"]),
    ],
    setup_requires=[],
    install_requires=[],
    entry_points={},
)
