
//--------------------------------------------------------------------------------------------------------
// Module  : fpga_top_usb_cdc
// Type    : synthesizable, fpga top
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: example for usb_cdc_top
//--------------------------------------------------------------------------------------------------------

module fpga_top_usb_cdc (
    // clock and reset
    input  wire        clk50mhz,     // connect to a 50MHz oscillator
    input  wire        button,       // connect to a reset button, 0 is pressed, 1 is unpressed. If you don’t have a button, tie this signal to 1.
    // USB signals
    output wire        usb_dp_pull,  // connect to USB D+ by an 1.5k resistor
    inout              usb_dp,       // connect to USB D+
    inout              usb_dn        // connect to USB D-
);




//-------------------------------------------------------------------------------------------------------------------------------------
// The USB controller core needs a 60MHz clock, this PLL module is to convert clk50mhz to clk60mhz
// This PLL module is only available on Altera Cyclone IV E.
// If you use other FPGA families, please use their compatible primitives or IP-cores to generate clk60mhz
//-------------------------------------------------------------------------------------------------------------------------------------
wire [3:0] subwire0;
wire       clk60mhz;
wire       clk_locked;
altpll altpll_i (
    .inclk       ( {1'b0, clk50mhz}     ),
    .clk         ( {subwire0, clk60mhz} ),
    .locked      ( clk_locked           ),
    .activeclock (),    .areset (1'b0),    .clkbad (),    .clkena ({6{1'b1}}),    .clkloss (),    .clkswitch (1'b0),    .configupdate (1'b0),    .enable0 (),    .enable1 (),    .extclk (),    .extclkena ({4{1'b1}}),    .fbin (1'b1),    .fbmimicbidir (),    .fbout (),    .fref (),    .icdrclk (),    .pfdena (1'b1),    .phasecounterselect ({4{1'b1}}),    .phasedone (),    .phasestep (1'b1),    .phaseupdown (1'b1),    .pllena (1'b1),    .scanaclr (1'b0),    .scanclk (1'b0),    .scanclkena (1'b1),    .scandata (1'b0),    .scandataout (),    .scandone (),    .scanread (1'b0),    .scanwrite (1'b0),    .sclkout0 (),    .sclkout1 (),    .vcooverrange (),    .vcounderrange () );
defparam altpll_i.bandwidth_type = "AUTO",    altpll_i.clk0_divide_by = 5,    altpll_i.clk0_duty_cycle = 50,    altpll_i.clk0_multiply_by = 6,    altpll_i.clk0_phase_shift = "0",    altpll_i.compensate_clock = "CLK0",    altpll_i.inclk0_input_frequency = 40000,    altpll_i.intended_device_family = "Cyclone IV E",    altpll_i.lpm_hint = "CBX_MODULE_PREFIX=pll",    altpll_i.lpm_type = "altpll",    altpll_i.operation_mode = "NORMAL",    altpll_i.pll_type = "AUTO",    altpll_i.port_activeclock = "PORT_UNUSED",    altpll_i.port_areset = "PORT_UNUSED",    altpll_i.port_clkbad0 = "PORT_UNUSED",    altpll_i.port_clkbad1 = "PORT_UNUSED",    altpll_i.port_clkloss = "PORT_UNUSED",    altpll_i.port_clkswitch = "PORT_UNUSED",    altpll_i.port_configupdate = "PORT_UNUSED",    altpll_i.port_fbin = "PORT_UNUSED",    altpll_i.port_inclk0 = "PORT_USED",    altpll_i.port_inclk1 = "PORT_UNUSED",    altpll_i.port_locked = "PORT_USED",    altpll_i.port_pfdena = "PORT_UNUSED",    altpll_i.port_phasecounterselect = "PORT_UNUSED",    altpll_i.port_phasedone = "PORT_UNUSED",    altpll_i.port_phasestep = "PORT_UNUSED",    altpll_i.port_phaseupdown = "PORT_UNUSED",    altpll_i.port_pllena = "PORT_UNUSED",    altpll_i.port_scanaclr = "PORT_UNUSED",    altpll_i.port_scanclk = "PORT_UNUSED",    altpll_i.port_scanclkena = "PORT_UNUSED",    altpll_i.port_scandata = "PORT_UNUSED",    altpll_i.port_scandataout = "PORT_UNUSED",    altpll_i.port_scandone = "PORT_UNUSED",    altpll_i.port_scanread = "PORT_UNUSED",    altpll_i.port_scanwrite = "PORT_UNUSED",    altpll_i.port_clk0 = "PORT_USED",    altpll_i.port_clk1 = "PORT_UNUSED",    altpll_i.port_clk2 = "PORT_UNUSED",    altpll_i.port_clk3 = "PORT_UNUSED",    altpll_i.port_clk4 = "PORT_UNUSED",    altpll_i.port_clk5 = "PORT_UNUSED",    altpll_i.port_clkena0 = "PORT_UNUSED",    altpll_i.port_clkena1 = "PORT_UNUSED",    altpll_i.port_clkena2 = "PORT_UNUSED",    altpll_i.port_clkena3 = "PORT_UNUSED",    altpll_i.port_clkena4 = "PORT_UNUSED",    altpll_i.port_clkena5 = "PORT_UNUSED",    altpll_i.port_extclk0 = "PORT_UNUSED",    altpll_i.port_extclk1 = "PORT_UNUSED",    altpll_i.port_extclk2 = "PORT_UNUSED",    altpll_i.port_extclk3 = "PORT_UNUSED",    altpll_i.self_reset_on_loss_lock = "OFF",    altpll_i.width_clock = 5;




//-------------------------------------------------------------------------------------------------------------------------------------
// use USB-CDC device to implement a COM-port (i.e., USB-UART)
// the behavior is simply loopback. When using minicom/hyperterminal/serial-assistant to send data from the host to the device, the data will be returned.
//-------------------------------------------------------------------------------------------------------------------------------------

wire [ 7:0] recv_data;
wire        recv_valid;

usb_cdc_top usb_cdc_serial_i (
    .rstn            ( clk_locked & button ),
    .clk             ( clk60mhz            ),
    // USB signals
    .usb_dp_pull     ( usb_dp_pull         ),
    .usb_dp          ( usb_dp              ),
    .usb_dn          ( usb_dn              ),
    // CDC receive data (host-to-device)
    .recv_data       ( recv_data           ),   // received data byte
    .recv_valid      ( recv_valid          ),   // when recv_valid=1 pulses, a data byte is received on recv_data
    // CDC send data (device-to-host)
    .send_data       ( recv_data           ),   // connect recv_data to send_data to achieve loopback 
    .send_valid      ( recv_valid          ),   // connect recv_valid to send_valid to achieve loopback 
    .send_ready      (                     )    // ignore send_ready, ignore the situation that the send buffer is full (send_ready=0)
);


endmodule