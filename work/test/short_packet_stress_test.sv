///////////////////////////////////////////////////////////////////////////
// Texas A&M University
// CSCE 616 Hardware Design Verification
// Created by  : Prof. Quinn and Saumil Gogri
///////////////////////////////////////////////////////////////////////////

class short_packet_stress_test extends base_test;

	`uvm_component_utils(short_packet_stress_test)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this,"tb.vsequencer.run_phase", "default_sequence", short_packet_stress_vsequence::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_type_name(),"Starting short packet stress test - targeting short packet bug scenarios",UVM_NONE)
	endtask : run_phase

endclass : short_packet_stress_test



///////////////////////////// VIRTUAL SEQUENCE ///////////////////////////

class short_packet_stress_vsequence extends htax_base_vseq;

	`uvm_object_utils(short_packet_stress_vsequence)

	function new (string name = "short_packet_stress_vsequence");
		super.new(name);
	endfunction : new

	task body();
		`uvm_info(get_type_name(),"**** Short Packet Stress Virtual Sequence Started ****", UVM_NONE)
		
		// Phase 1: Many short packets with minimal delays - stress buffer handling
		`uvm_info(get_type_name(),"High volume short packets with minimal delays", UVM_NONE)
		repeat(200) begin
			automatic int port = $urandom_range(0,3);
			`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
				length inside {[3:10]};     // Only short packets
				vc inside {[1:3]};          // All possible VCs
				dest_port inside {[0:3]};   // All destinations
				delay inside {[1:3]};       // Minimal delays for high throughput
			})
		end
		
		// Phase 2: Short packets with specific VC patterns
		`uvm_info(get_type_name(),"Short packets with VC-specific patterns", UVM_NONE)
		repeat(50) begin
			fork
				// VC 1 traffic
				begin
					htax_packet_c req0;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[port], {
						length inside {[3:5]};      // Very short
						vc == 1;                    // Specific VC
						dest_port inside {[0:3]};
						delay inside {[1:2]};       // Fast
					})
				end
				// VC 2 traffic  
				begin
					htax_packet_c req1;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[port], {
						length inside {[6:8]};      // Medium short
						vc == 2;                    // Different VC
						dest_port inside {[0:3]};
						delay inside {[2:4]};
					})
				end
				// VC 3 traffic
				begin
					htax_packet_c req2;
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req2, p_sequencer.htax_seqr[port], {
						length inside {[8:10]};     // Larger short
						vc == 3;                    // Third VC
						dest_port inside {[0:3]};
						delay inside {[1:5]};
					})
				end
			join
		end
		
		// Phase 3: Short packet flooding - all ports to same destination
		`uvm_info(get_type_name(),"Short packet congestion patterns", UVM_NONE)
		repeat(30) begin
			automatic int target_dest = $urandom_range(0,3);
			fork
				// Port 0 -> target
				begin
					htax_packet_c req0;
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
						length inside {[3:6]};
						vc inside {[1:2]};
						dest_port == target_dest;
						delay inside {[1:2]};
					})
				end
				// Port 1 -> target
				begin
					htax_packet_c req1;
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[1], {
						length inside {[4:7]};
						vc inside {[2:3]};
						dest_port == target_dest;
						delay inside {[1:3]};
					})
				end
				// Port 2 -> target
				begin
					htax_packet_c req2;
					`uvm_do_on_with(req2, p_sequencer.htax_seqr[2], {
						length inside {[5:8]};
						vc inside {[1:3]};
						dest_port == target_dest;
						delay inside {[1:2]};
					})
				end
				// Port 3 -> target
				begin
					htax_packet_c req3;
					`uvm_do_on_with(req3, p_sequencer.htax_seqr[3], {
						length inside {[3:10]};
						vc inside {[1:3]};
						dest_port == target_dest;
						delay inside {[1:4]};
					})
				end
			join
			#($urandom_range(5,15)); // Brief pause between congestion bursts
		end
		
		// Phase 4: Short packets with varied timing patterns
		`uvm_info(get_type_name(),"Short packets with timing variations", UVM_NONE)
		repeat(100) begin
			fork
				// Fast short packets
				begin
					htax_packet_c req0;
					automatic int port = $urandom_range(0,1);
					`uvm_do_on_with(req0, p_sequencer.htax_seqr[port], {
						length inside {[3:5]};
						vc inside {[1:3]};
						dest_port inside {[0:3]};
						delay == 1;                 // Fastest possible
					})
				end
				// Slower short packets  
				begin
					htax_packet_c req1;
					automatic int port = $urandom_range(2,3);
					`uvm_do_on_with(req1, p_sequencer.htax_seqr[port], {
						length inside {[7:10]};
						vc inside {[1:3]};
						dest_port inside {[0:3]};
						delay inside {[10:20]};     // Much slower
					})
				end
			join
		end
		
		// Phase 5: Extreme short packet stress - minimal size, maximal rate
		`uvm_info(get_type_name(),"Extreme short packet flooding", UVM_NONE)
		repeat(50) begin
			fork
				begin
					repeat(10) begin
						htax_packet_c req0;
						`uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
							length == 3;            // Minimum possible
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay == 1;             // Maximum rate
						})
					end
				end
				begin
					repeat(10) begin
						htax_packet_c req1;
						`uvm_do_on_with(req1, p_sequencer.htax_seqr[1], {
							length == 3;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay == 1;
						})
					end
				end
				begin
					repeat(10) begin
						htax_packet_c req2;
						`uvm_do_on_with(req2, p_sequencer.htax_seqr[2], {
							length == 3;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay == 1;
						})
					end
				end
				begin
					repeat(10) begin
						htax_packet_c req3;
						`uvm_do_on_with(req3, p_sequencer.htax_seqr[3], {
							length == 3;
							vc inside {[1:3]};
							dest_port inside {[0:3]};
							delay == 1;
						})
					end
				end
			join
		end
		
		// Phase 6: Systematic coverage completion for short packets
		`uvm_info(get_type_name(),"Short packet coverage completion", UVM_NONE)
		
		// Hit all short lengths with all VC/dest combinations
		for (int len = 3; len <= 10; len++) begin
			for (int vc_val = 1; vc_val <= 3; vc_val++) begin
				for (int dest = 0; dest <= 3; dest++) begin
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
						length == len;
						vc == vc_val;
						dest_port == dest;
						delay inside {[1:10]};
					})
				end
			end
		end
		
		// Additional missing short length bins
		for (int len = 11; len <= 20; len++) begin
			for (int vc_val = 1; vc_val <= 3; vc_val++) begin
				for (int dest = 0; dest <= 3; dest++) begin
					automatic int port = $urandom_range(0,3);
					`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {
						length == len;
						vc == vc_val;
						dest_port == dest;
						delay inside {[1:5]};
					})
				end
			end
		end

		// Phase 7: Random packets
		`uvm_info(get_type_name(),"Phase 7: Random packets", UVM_NONE)
		repeat(400) begin
			automatic int port = $urandom_range(0,3);
			`uvm_do_on_with(req, p_sequencer.htax_seqr[port], {})
		end


		
		`uvm_info(get_type_name(),"**** Short Packet Stress Virtual Sequence Completed ****", UVM_NONE)
	endtask : body

endclass : short_packet_stress_vsequence