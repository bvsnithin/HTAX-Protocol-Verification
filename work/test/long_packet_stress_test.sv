///////////////////////////////////////////////////////////////////////////
// Texas A&M University
// CSCE 616 Hardware Design Verification
// Created by  : Prof. Quinn and Saumil Gogri
///////////////////////////////////////////////////////////////////////////

class long_packet_stress_test extends base_test;

	`uvm_component_utils(long_packet_stress_test)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this,"tb.vsequencer.run_phase", "default_sequence", long_packet_stress_vsequence::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_type_name(),"Starting long packet stress test - targeting long packet bug scenarios",UVM_NONE)
	endtask : run_phase

endclass : long_packet_stress_test



///////////////////////////// VIRTUAL SEQUENCE ///////////////////////////

class long_packet_stress_vsequence extends htax_base_vseq;

	`uvm_object_utils(long_packet_stress_vsequence)

	function new (string name = "long_packet_stress_vsequence");
		super.new(name);
	endfunction : new

	task body();
		`uvm_info(get_type_name(),"**** Long Packet Stress Virtual Sequence Started ****", UVM_NONE)
		
		// Many long packets - stress buffer capacity
		`uvm_info(get_type_name(),"High volume long packets", UVM_NONE)
		repeat(100) begin
			automatic int port = $urandom_range(0,3);
			`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
				length inside {[40:63]};    // Only long packets
				vc inside {[1:3]};          // All possible VCs
				dest_port inside {[0:3]};   // All destinations
				delay inside {[1:10]};      // Varied delays
			})
		end
		
		// Long packets with specific VC contention
		`uvm_info(get_type_name(),"Long packets with VC contention", UVM_NONE)
		repeat(30) begin
			fork
				// Multiple long packets on same VC
				begin
					htax_packet_c req0;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[port], {
						length inside {[50:63]};    // Very long
						vc == 1;                    // Same VC
						dest_port inside {[0:3]};
						delay inside {[1:5]};
					})
				end
				begin
					htax_packet_c req1;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[port], {
						length inside {[45:60]};    // Long
						vc == 1;                    // Same VC - potential conflict
						dest_port inside {[0:3]};
						delay inside {[1:5]};
					})
				end
				begin
					htax_packet_c req2;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req2, p_sequencer.htax_seqr[port], {
						length inside {[55:63]};    // Very long
						vc == 1;                    // Same VC - more conflict
						dest_port inside {[0:3]};
						delay inside {[1:5]};
					})
				end
			join
		end
		
		// Long packets causing buffer saturation
		`uvm_info(get_type_name(),"Long packet buffer saturation", UVM_NONE)
		repeat(25) begin
			automatic int target_dest = $urandom_range(0,3);
			fork
				// All ports send maximum length packets to same destination
				begin
					htax_packet_c req0;
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
						length inside {[60:63]};    // Maximum length
						vc inside {[1:2]};
						dest_port == target_dest;
						delay inside {[1:3]};
					})
				end
				begin
					htax_packet_c req1;
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[1], {
						length inside {[58:63]};
						vc inside {[2:3]};
						dest_port == target_dest;
						delay inside {[1:4]};
					})
				end
				begin
					htax_packet_c req2;
					`uvm_do_on_with(req2, p_sequencer.htax_seqr[2], {
						length inside {[55:63]};
						vc inside {[1:3]};
						dest_port == target_dest;
						delay inside {[1:3]};
					})
				end
				begin
					htax_packet_c req3;
					`uvm_do_on_with(req3, p_sequencer.htax_seqr[3], {
						length inside {[60:63]};
						vc inside {[1:3]};
						dest_port == target_dest;
						delay inside {[1:5]};
					})
				end
			join
			#($urandom_range(10,30)); // Longer pause for buffer recovery
		end
		
		// Long packets with different timing patterns  
		`uvm_info(get_type_name(),"Long packets with varied timing", UVM_NONE)
		repeat(60) begin
			fork
				// Fast long packets
				begin
					htax_packet_c req0;
					automatic int port = $urandom_range(0,1);
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[port], {
						length inside {[40:50]};
						vc inside {[1:3]};
						dest_port inside {[0:3]};
						delay inside {[1:3]};       // Fast injection
					})
				end
				// Slow long packets
				begin
					htax_packet_c req1;
					automatic int port = $urandom_range(2,3);
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[port], {
						length inside {[55:63]};
						vc inside {[1:3]};
						dest_port inside {[0:3]};
						delay inside {[15:20]};     // Slow injection
					})
				end
			join
		end
		
		// Maximum length packets with minimum delays - extreme stress
		`uvm_info(get_type_name(),"Maximum length packet flooding", UVM_NONE)
		repeat(20) begin
			fork
				begin
					repeat(50) begin
						htax_packet_c req0;
						`uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
							length == 63;           // Maximum possible
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay inside {[1:2]};   // Near maximum rate
						})
					end
				end
				begin
					repeat(50) begin
						htax_packet_c req1;
						`uvm_do_on_with(req1, p_sequencer.htax_seqr[1], {
							length == 63;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay inside {[1:2]};
						})
					end
				end
				begin
					repeat(50) begin
						htax_packet_c req2;
						`uvm_do_on_with(req2, p_sequencer.htax_seqr[2], {
							length == 63;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay inside {[1:2]};
						})
					end
				end
				begin
					repeat(50) begin
						htax_packet_c req3;
						`uvm_do_on_with(req3, p_sequencer.htax_seqr[3], {
							length == 63;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay inside {[1:2]};
						})
					end
				end
			join
		end
		
		// Long packet chains - testing credit flow control
		`uvm_info(get_type_name(),"Long packet chains for credit testing", UVM_NONE)
		repeat(15) begin
			// Create chains of long packets on each VC
			fork
				begin
					// VC 1 chain
					repeat(30) begin
						htax_packet_c req0;
						automatic int port = $urandom_range(0,3);
						`uvm_do_on_with(req0, p_sequencer.htax_seqr[port], {
							length inside {[55:63]};
							vc == 1;
							dest_port inside {[0:3]};
							delay inside {[1:3]};
						})
						#($urandom_range(5,10));
					end
				end
				begin
					// VC 2 chain
					repeat(30) begin
						htax_packet_c req1;
						automatic int port = $urandom_range(0,3);
						`uvm_do_on_with(req1, p_sequencer.htax_seqr[port], {
							length inside {[50:63]};
							vc == 2;
							dest_port inside {[0:3]};
							delay inside {[1:3]};
						})
						#($urandom_range(5,10));
					end
				end
				begin
					// VC 3 chain
					repeat(30) begin
						htax_packet_c req2;
						automatic int port = $urandom_range(0,3);
						`uvm_do_on_with(req2, p_sequencer.htax_seqr[port], {
							length inside {[45:63]};
							vc == 3;
							dest_port inside {[0:3]};
							delay inside {[1:3]};
						})
						#($urandom_range(5,10));
					end
				end
			join
		end
		
		// Systematic coverage completion for long packets
		`uvm_info(get_type_name(),"Long packet coverage completion", UVM_NONE)
		
		// Hit all mid-range lengths with all VC/dest combinations
		for (int len = 21; len <= 39; len++) begin
			for (int vc_val = 1; vc_val <= 3; vc_val++) begin
				for (int dest = 0; dest <= 3; dest++) begin
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
						length == len;
						vc == vc_val;
						dest_port == dest;
						delay inside {[1:8]};
					})
				end
			end
		end
		
		// Hit all long lengths with all VC/dest combinations  
		for (int len = 40; len <= 63; len++) begin
			for (int vc_val = 1; vc_val <= 3; vc_val++) begin
				for (int dest = 0; dest <= 3; dest++) begin
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
						length == len;
						vc == vc_val;
						dest_port == dest;
						delay inside {[1:12]};
					})
				end
			end
		end
		
		// Maximum Stress - Back-to-Back packets for Coverage
		`uvm_info(get_type_name(),"Maximum Stress - Back-to-Back packets", UVM_NONE)
		repeat(20) begin
			fork
				begin
					htax_packet_c req0;
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
						length inside {[10:20]};
						vc inside {[1:3]};
						dest_port == 0;
						delay == 1;
					})
				end
				begin
					htax_packet_c req1;
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[1], {
						length inside {[10:20]};
						vc inside {[1:3]};
						dest_port == 0;
						delay == 1;
					})
				end
				begin
					htax_packet_c req2;
					`uvm_do_on_with(req2, p_sequencer.htax_seqr[2], {
						length inside {[10:20]};
						vc inside {[1:3]};
						dest_port == 0;
						delay == 1;
					})
				end
				begin
					htax_packet_c req3;
					`uvm_do_on_with(req3, p_sequencer.htax_seqr[3], {
						length inside {[10:20]};
						vc inside {[1:3]};
						dest_port == 0;
						delay == 1;
					})
				end
			join
		end
		
		`uvm_info(get_type_name(),"**** Long Packet Stress Virtual Sequence Completed ****", UVM_NONE)
	endtask : body

endclass : long_packet_stress_vsequence