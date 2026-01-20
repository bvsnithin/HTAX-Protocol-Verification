class htax_sequencer_c extends uvm_sequencer #(htax_packet_c);
	
	`uvm_component_utils(htax_sequencer_c)

	function new (string name, uvm_component parent);
		super.new(name,parent);
		`uvm_info(get_type_name(), "**** htax_sequencer_c Constructor Called ****", UVM_NONE)
	endfunction : new

endclass : htax_sequencer_c
