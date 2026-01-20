

class random_test extends base_test;

    `uvm_component_utils(random_test)  //Registration

    //Constructor
    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction: new

    //Build phase
    function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this,"tb.vsequencer.run_phase", "default_sequence", random_test_vsequence::type_id::get());
        super.build_phase(phase);
    endfunction: build_phase

    //Run Phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info(get_type_name,"Starting random test",UVM_NONE);
    endtask: run_phase

endclass: random_test

class random_test_vsequence extends htax_base_vseq;

    `uvm_object_utils(random_test_vsequence)

    // rand int port;

    function new(string name = "random_test_vsequence");
        super.new(name);
    endfunction: new

    task body();

        fork
            // Short packets on port 0
            begin
                htax_packet_c req0;
                repeat(5) begin
                    `uvm_info(get_type_name(),"**** [FORK 0] Random Test Virtual Sequence has started ****", UVM_NONE)
                    `uvm_do_on_with(req0, p_sequencer.htax_seqr[0], {
                        req0.length inside {[3:10]};
                    })
                end
            end

            // Long packets on port 1
            begin
                htax_packet_c req1; 
                repeat(5) begin
                    `uvm_info(get_type_name(),"**** [FORK 1] Random Test Virtual Sequence has started ****", UVM_NONE)
                    `uvm_do_on_with(req1,p_sequencer.htax_seqr[1],{
                        req1.length inside {[45:63]};
                    })
                end
            end

            begin
                htax_packet_c req2;
                repeat(5) begin
                    `uvm_info(get_type_name(),"**** [FORK 2] Random Test Virtual Sequence has started ****", UVM_NONE)
                    `uvm_do_on_with(req2, p_sequencer.htax_seqr[2],{
                        req2.dest_port == 0;
                        req2.length inside {[15:40]};
                    })
                end
            end

            begin
                htax_packet_c req3;
                repeat(10) begin
                    `uvm_info(get_type_name(),"**** [FORK 3] Random Test Virtual Sequence has started ****", UVM_NONE)
                    `uvm_do_on_with(req3, p_sequencer.htax_seqr[3],{
                        req3.delay inside {[15:20]};
                    })
                end
            end
        join

                // repeat(5) begin
                //     `uvm_info(get_type_name(),"**** [FORK 0] Random Test Virtual Sequence has started ****", UVM_NONE)
                //     `uvm_do_on_with(req, p_sequencer.htax_seqr[0], {
                //         req.length inside {[3:10]};
                //     })
                // end

                // repeat(5) begin
                //     `uvm_info(get_type_name(),"**** [FORK 1] Random Test Virtual Sequence has started ****", UVM_NONE)
                //     `uvm_do_on_with(req,p_sequencer.htax_seqr[1],{
                //         req.length inside {[45:63]};
                //     })
                // end
                
                // repeat(5) begin
                //     `uvm_info(get_type_name(),"**** [FORK 2] Random Test Virtual Sequence has started ****", UVM_NONE)
                //     `uvm_do_on_with(req, p_sequencer.htax_seqr[2],{
                //         req.dest_port == 0;
                //         req.length inside {[15:40]};
                //     })
                // end
                
                // repeat(10) begin
                //     `uvm_info(get_type_name(),"**** [FORK 3] Random Test Virtual Sequence has started ****", UVM_NONE)
                //     `uvm_do_on_with(req, p_sequencer.htax_seqr[3],{
                //         req.delay inside {[15:20]};
                //     })
                // end
    endtask: body




endclass //random_test_vsequence extends htax_base_vseq